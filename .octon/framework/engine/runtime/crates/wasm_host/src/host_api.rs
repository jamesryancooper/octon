use crate::bindings::{clock, fs, http, kv, log};
use crate::state::HostState;
use octon_core::execution_integrity::{
    evaluate_network_egress, parse_network_target, write_network_egress_event,
    NetworkEgressContext, NetworkEgressDecision, NetworkEgressEvent,
};
use std::io::{Read, Write};
use std::net::{TcpStream, ToSocketAddrs};
use std::time::Duration;

impl log::Host for HostState {
    fn write(&mut self, level: String, message: String) -> wasmtime::Result<()> {
        self.grants.require("log.write")?;
        eprintln!("[{level}] {message}");
        Ok(())
    }
}

impl clock::Host for HostState {
    fn now_ms(&mut self) -> wasmtime::Result<u64> {
        self.grants.require("clock.read")?;
        Ok(std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .unwrap_or_default()
            .as_millis() as u64)
    }
}

impl kv::Host for HostState {
    fn get(&mut self, key: String) -> wasmtime::Result<Option<String>> {
        self.grants.require("storage.local")?;
        Ok(self.kv.get(&key)?)
    }

    fn put(&mut self, key: String, value: String) -> wasmtime::Result<()> {
        self.grants.require("storage.local")?;
        self.kv.put(&key, &value)?;
        Ok(())
    }

    fn del(&mut self, key: String) -> wasmtime::Result<()> {
        self.grants.require("storage.local")?;
        let _ = self.kv.del(&key)?;
        Ok(())
    }
}

impl fs::Host for HostState {
    fn read(&mut self, path: String) -> wasmtime::Result<Vec<u8>> {
        self.grants.require("fs.read")?;
        Ok(self.fs.read_bytes(&path)?)
    }

    fn read_range(
        &mut self,
        path: String,
        offset: u64,
        max_bytes: u64,
    ) -> wasmtime::Result<Vec<u8>> {
        self.grants.require("fs.read")?;
        if max_bytes > 4 * 1024 * 1024 {
            return Err(anyhow::anyhow!("INVALID_INPUT: read-range max-bytes too large").into());
        }
        Ok(self.fs.read_range(&path, offset, max_bytes)?)
    }

    fn write(&mut self, path: String, data: Vec<u8>) -> wasmtime::Result<()> {
        self.grants.require("fs.write")?;
        if data.len() > 4 * 1024 * 1024 {
            return Err(anyhow::anyhow!("INVALID_INPUT: write too large").into());
        }
        self.fs.write_bytes_atomic(&path, &data)?;
        Ok(())
    }

    fn create_file_exclusive(&mut self, path: String, data: Vec<u8>) -> wasmtime::Result<bool> {
        self.grants.require("fs.write")?;
        if data.len() > 1024 * 1024 {
            return Err(anyhow::anyhow!("INVALID_INPUT: create-file-exclusive payload too large").into());
        }
        Ok(self.fs.create_file_exclusive(&path, &data)?)
    }

    fn read_text(&mut self, path: String) -> wasmtime::Result<String> {
        self.grants.require("fs.read")?;
        Ok(self.fs.read_text(&path, 1 * 1024 * 1024)?)
    }

    fn write_text(&mut self, path: String, data: String) -> wasmtime::Result<()> {
        self.grants.require("fs.write")?;
        self.fs.write_text_atomic(&path, &data, 1 * 1024 * 1024)?;
        Ok(())
    }

    fn exists(&mut self, path: String) -> wasmtime::Result<bool> {
        self.grants.require("fs.read")?;
        Ok(self.fs.exists(&path)?)
    }

    fn list_dir(&mut self, path: String) -> wasmtime::Result<Vec<String>> {
        self.grants.require("fs.read")?;
        Ok(self.fs.list_dir(&path)?)
    }

    fn glob(&mut self, pattern: String) -> wasmtime::Result<Vec<String>> {
        self.grants.require("fs.read")?;
        Ok(self.fs.glob(&pattern, 10_000)?)
    }

    fn mkdirp(&mut self, path: String) -> wasmtime::Result<()> {
        self.grants.require("fs.write")?;
        self.fs.mkdirp(&path)?;
        Ok(())
    }

    fn rename(&mut self, from_path: String, to_path: String) -> wasmtime::Result<()> {
        self.grants.require("fs.write")?;
        self.fs.rename(&from_path, &to_path)?;
        Ok(())
    }

    fn remove_file(&mut self, path: String) -> wasmtime::Result<()> {
        self.grants.require("fs.write")?;
        self.fs.remove_file(&path)?;
        Ok(())
    }

    fn remove_dir_recursive(&mut self, path: String) -> wasmtime::Result<()> {
        self.grants.require("fs.write")?;
        self.fs.remove_dir_recursive(&path)?;
        Ok(())
    }

    fn get_stat(&mut self, path: String) -> wasmtime::Result<Option<fs::Stat>> {
        self.grants.require("fs.read")?;
        let Some(st) = self.fs.stat(&path)? else { return Ok(None); };

        let kind = match st.kind {
            crate::scoped_fs::NodeKind::File => fs::NodeKind::File,
            crate::scoped_fs::NodeKind::Dir => fs::NodeKind::Dir,
        };

        Ok(Some(fs::Stat {
            kind,
            size: st.size,
            modified_ms: st.modified_ms,
        }))
    }
}

impl http::Host for HostState {
    fn send(&mut self, req: http::Request) -> wasmtime::Result<http::Response> {
        self.grants.require("net.http")?;

        let method = normalize_method(&req.method)?;
        let network_decision = evaluate_network_egress(
            &self.network_policy,
            &self.exception_leases,
            &NetworkEgressContext {
                service_id: &self.service_id,
                adapter_id: self.adapter_id.as_deref(),
                executor_profile: None,
                method: &method,
            },
            &req.url,
        )
        .map_err(|e| {
            let _ = record_network_event(
                &self.run_root,
                &self.service_id,
                self.adapter_id.as_deref(),
                &method,
                &req.url,
                NetworkEgressDecision {
                    allowed: false,
                    matched_rule_id: "deny".to_string(),
                    reason: e.to_string(),
                    source_kind: "policy".to_string(),
                    artifact_ref: None,
                },
            );
            if let Some(trace) = &self.trace {
                let _ = trace.event(
                    "network.egress.denied",
                    serde_json::json!({
                        "service": self.service_id,
                        "adapter": self.adapter_id,
                        "method": method,
                        "url": req.url,
                    }),
                );
            }
            anyhow::anyhow!("CAPABILITY_DENIED: {e}")
        })?;
        let _ = record_network_event(
            &self.run_root,
            &self.service_id,
            self.adapter_id.as_deref(),
            &method,
            &req.url,
            network_decision.clone(),
        );
        if let Some(trace) = &self.trace {
            let _ = trace.event(
                "network.egress.allowed",
                serde_json::json!({
                    "service": self.service_id,
                    "adapter": self.adapter_id,
                    "method": method,
                    "url": req.url,
                    "rule_id": network_decision.matched_rule_id,
                }),
            );
        }
        let url = parse_http_url(&req.url)?;
        let timeout = Duration::from_millis(req.timeout_ms.unwrap_or(30_000).max(1));

        let mut stream = connect_http(&url.connect_authority, timeout)?;
        stream
            .set_read_timeout(Some(timeout))
            .map_err(map_http_error)?;
        stream
            .set_write_timeout(Some(timeout))
            .map_err(map_http_error)?;

        let request_bytes = build_http_request(&method, &url, req.headers, &req.body)?;
        stream.write_all(&request_bytes).map_err(map_io_http_error)?;
        stream.flush().map_err(map_io_http_error)?;

        let mut raw = Vec::new();
        let mut chunk = [0u8; 8192];
        loop {
            match stream.read(&mut chunk) {
                Ok(0) => break,
                Ok(n) => {
                    raw.extend_from_slice(&chunk[..n]);
                    if raw.len() > MAX_RESPONSE_BYTES {
                        return Err(anyhow::anyhow!("HTTP_ERROR: response too large").into());
                    }
                }
                Err(e) => return Err(map_io_http_error(e)),
            }
        }

        let (status, headers, body) = parse_http_response(&raw)?;

        Ok(http::Response {
            status,
            headers,
            body,
        })
    }
}

fn record_network_event(
    run_root: &std::path::Path,
    service_id: &str,
    adapter_id: Option<&str>,
    method: &str,
    url: &str,
    decision: NetworkEgressDecision,
) -> wasmtime::Result<()> {
    let target = parse_network_target(url)
        .map_err(|e| anyhow::anyhow!("HTTP_ERROR: {}", e))?;
    let event = NetworkEgressEvent {
        schema_version: "network-egress-event-v1".to_string(),
        request_id: run_root
            .file_name()
            .map(|value| value.to_string_lossy().to_string())
            .unwrap_or_else(|| "unknown".to_string()),
        service_id: service_id.to_string(),
        adapter_id: adapter_id.map(ToOwned::to_owned),
        method: method.to_string(),
        url: url.to_string(),
        target,
        decision,
        recorded_at: time::OffsetDateTime::now_utc()
            .format(&time::format_description::well_known::Rfc3339)
            .unwrap_or_else(|_| "1970-01-01T00:00:00Z".to_string()),
    };
    write_network_egress_event(run_root, &event)
        .map(|_| ())
        .map_err(|e| anyhow::anyhow!("HTTP_ERROR: {}", e).into())
}

const MAX_RESPONSE_BYTES: usize = 8 * 1024 * 1024;

#[derive(Debug)]
struct ParsedHttpUrl {
    connect_authority: String,
    host_header: String,
    path_and_query: String,
}

fn normalize_method(method: &str) -> wasmtime::Result<String> {
    if method.is_empty() {
        return Err(anyhow::anyhow!("INVALID_INPUT: missing http method").into());
    }

    if !method
        .bytes()
        .all(|b| b.is_ascii_alphanumeric() || matches!(b, b'!' | b'#' | b'$' | b'%' | b'&' | b'\'' | b'*' | b'+' | b'-' | b'.' | b'^' | b'_' | b'`' | b'|' | b'~'))
    {
        return Err(anyhow::anyhow!("INVALID_INPUT: invalid http method '{}'", method).into());
    }

    Ok(method.to_ascii_uppercase())
}

fn parse_http_url(url: &str) -> wasmtime::Result<ParsedHttpUrl> {
    let Some(rest) = url.strip_prefix("http://") else {
        if url.starts_with("https://") {
            return Err(anyhow::anyhow!(
                "INVALID_INPUT: https urls are not supported by the native v1 host"
            )
            .into());
        }
        return Err(anyhow::anyhow!("INVALID_INPUT: url must start with http://").into());
    };

    let (authority, path_part) = match rest.find('/') {
        Some(idx) => (&rest[..idx], &rest[idx..]),
        None => (rest, "/"),
    };

    let authority = authority.trim();
    if authority.is_empty() {
        return Err(anyhow::anyhow!("INVALID_INPUT: url missing host").into());
    }
    if authority.contains('@') {
        return Err(anyhow::anyhow!("INVALID_INPUT: userinfo is not supported").into());
    }

    let (host_header, connect_host, port) = parse_authority(authority)?;
    let connect_authority = if connect_host.contains(':') {
        format!("[{connect_host}]:{port}")
    } else {
        format!("{connect_host}:{port}")
    };

    let mut path_and_query = path_part.to_string();
    if let Some(idx) = path_and_query.find('#') {
        path_and_query.truncate(idx);
    }
    if path_and_query.is_empty() {
        path_and_query.push('/');
    }
    if !path_and_query.starts_with('/') {
        path_and_query.insert(0, '/');
    }
    if path_and_query.chars().any(|c| c == '\r' || c == '\n') {
        return Err(anyhow::anyhow!("INVALID_INPUT: url path contains invalid characters").into());
    }

    let host_header = if port == 80 {
        host_header
    } else {
        format!("{host_header}:{port}")
    };

    Ok(ParsedHttpUrl {
        connect_authority,
        host_header,
        path_and_query,
    })
}

fn parse_authority(authority: &str) -> wasmtime::Result<(String, String, u16)> {
    if let Some(rest) = authority.strip_prefix('[') {
        let end = rest
            .find(']')
            .ok_or_else(|| anyhow::anyhow!("INVALID_INPUT: malformed ipv6 host"))?;
        let host = &rest[..end];
        if host.is_empty() {
            return Err(anyhow::anyhow!("INVALID_INPUT: empty ipv6 host").into());
        }
        let trailing = &rest[end + 1..];
        let port = if trailing.is_empty() {
            80
        } else if let Some(port_text) = trailing.strip_prefix(':') {
            parse_port(port_text)?
        } else {
            return Err(anyhow::anyhow!("INVALID_INPUT: malformed authority").into());
        };
        return Ok((format!("[{host}]"), host.to_string(), port));
    }

    let mut parts = authority.splitn(2, ':');
    let host = parts.next().unwrap_or_default().trim();
    if host.is_empty() {
        return Err(anyhow::anyhow!("INVALID_INPUT: empty host").into());
    }
    if host.contains(':') {
        return Err(anyhow::anyhow!("INVALID_INPUT: ipv6 hosts must use brackets").into());
    }
    if host.chars().any(|c| c == '[' || c == ']') {
        return Err(anyhow::anyhow!("INVALID_INPUT: malformed host").into());
    }

    let port = match parts.next() {
        Some(port_text) => parse_port(port_text)?,
        None => 80,
    };

    Ok((host.to_string(), host.to_string(), port))
}

fn parse_port(port_text: &str) -> wasmtime::Result<u16> {
    if port_text.is_empty() {
        return Err(anyhow::anyhow!("INVALID_INPUT: missing url port").into());
    }
    port_text
        .parse::<u16>()
        .map_err(|_| anyhow::anyhow!("INVALID_INPUT: invalid url port '{}'", port_text).into())
}

fn connect_http(authority: &str, timeout: Duration) -> wasmtime::Result<TcpStream> {
    let addrs = authority
        .to_socket_addrs()
        .map_err(|e| anyhow::anyhow!("HTTP_ERROR: failed to resolve '{}': {e}", authority))?;

    let mut last_err: Option<std::io::Error> = None;
    for addr in addrs {
        match TcpStream::connect_timeout(&addr, timeout) {
            Ok(stream) => return Ok(stream),
            Err(e) => {
                if e.kind() == std::io::ErrorKind::TimedOut {
                    return Err(anyhow::anyhow!("TIMEOUT: http request timed out").into());
                }
                last_err = Some(e);
            }
        }
    }

    if let Some(err) = last_err {
        return Err(map_io_http_error(err));
    }
    Err(anyhow::anyhow!("HTTP_ERROR: no resolved address for '{authority}'").into())
}

fn build_http_request(
    method: &str,
    url: &ParsedHttpUrl,
    headers: Vec<http::Header>,
    body: &[u8],
) -> wasmtime::Result<Vec<u8>> {
    let mut request = Vec::with_capacity(512 + body.len());
    write!(&mut request, "{method} {} HTTP/1.1\r\n", url.path_and_query)
        .map_err(map_http_error)?;

    let mut has_host = false;
    let mut has_connection = false;
    let mut has_content_length = false;

    for header in headers {
        let name = header.name.trim();
        let value = header.value.trim();
        validate_header_name(name)?;
        validate_header_value(value)?;

        if name.eq_ignore_ascii_case("host") {
            has_host = true;
        } else if name.eq_ignore_ascii_case("connection") {
            has_connection = true;
        } else if name.eq_ignore_ascii_case("content-length") {
            has_content_length = true;
        }

        write!(&mut request, "{name}: {value}\r\n").map_err(map_http_error)?;
    }

    if !has_host {
        write!(&mut request, "Host: {}\r\n", url.host_header).map_err(map_http_error)?;
    }
    if !has_connection {
        request.extend_from_slice(b"Connection: close\r\n");
    }
    if !has_content_length {
        write!(&mut request, "Content-Length: {}\r\n", body.len()).map_err(map_http_error)?;
    }

    request.extend_from_slice(b"\r\n");
    request.extend_from_slice(body);
    Ok(request)
}

fn validate_header_name(name: &str) -> wasmtime::Result<()> {
    if name.is_empty() {
        return Err(anyhow::anyhow!("INVALID_INPUT: http header name cannot be empty").into());
    }
    if !name
        .bytes()
        .all(|b| b.is_ascii_alphanumeric() || matches!(b, b'!' | b'#' | b'$' | b'%' | b'&' | b'\'' | b'*' | b'+' | b'-' | b'.' | b'^' | b'_' | b'`' | b'|' | b'~'))
    {
        return Err(anyhow::anyhow!("INVALID_INPUT: invalid http header name '{}'", name).into());
    }
    Ok(())
}

fn validate_header_value(value: &str) -> wasmtime::Result<()> {
    if value.chars().any(|c| c == '\r' || c == '\n') {
        return Err(anyhow::anyhow!("INVALID_INPUT: invalid http header value").into());
    }
    Ok(())
}

fn parse_http_response(raw: &[u8]) -> wasmtime::Result<(u16, Vec<http::Header>, Vec<u8>)> {
    let header_end = raw
        .windows(4)
        .position(|w| w == b"\r\n\r\n")
        .map(|idx| idx + 4)
        .ok_or_else(|| anyhow::anyhow!("HTTP_ERROR: malformed http response"))?;

    let head = std::str::from_utf8(&raw[..header_end - 4])
        .map_err(|_| anyhow::anyhow!("HTTP_ERROR: non-utf8 response headers"))?;

    let mut lines = head.split("\r\n");
    let status_line = lines
        .next()
        .ok_or_else(|| anyhow::anyhow!("HTTP_ERROR: missing status line"))?;
    let status = parse_status_code(status_line)?;

    let mut headers = Vec::new();
    let mut is_chunked = false;
    let mut content_length: Option<usize> = None;

    for line in lines {
        let (name, value) = line
            .split_once(':')
            .ok_or_else(|| anyhow::anyhow!("HTTP_ERROR: malformed header line"))?;
        let name = name.trim();
        let value = value.trim();
        headers.push(http::Header {
            name: name.to_string(),
            value: value.to_string(),
        });

        if name.eq_ignore_ascii_case("transfer-encoding")
            && value
                .split(',')
                .any(|part| part.trim().eq_ignore_ascii_case("chunked"))
        {
            is_chunked = true;
        } else if name.eq_ignore_ascii_case("content-length") {
            if let Ok(parsed) = value.parse::<usize>() {
                content_length = Some(parsed);
            }
        }
    }

    let body_slice = &raw[header_end..];
    let body = if is_chunked {
        decode_chunked_body(body_slice)?
    } else if let Some(expected) = content_length {
        if body_slice.len() < expected {
            return Err(anyhow::anyhow!("HTTP_ERROR: truncated response body").into());
        }
        body_slice[..expected].to_vec()
    } else {
        body_slice.to_vec()
    };

    if body.len() > MAX_RESPONSE_BYTES {
        return Err(anyhow::anyhow!("HTTP_ERROR: response body too large").into());
    }

    Ok((status, headers, body))
}

fn parse_status_code(status_line: &str) -> wasmtime::Result<u16> {
    let mut parts = status_line.split_whitespace();
    let http_version = parts.next().unwrap_or_default();
    if !http_version.starts_with("HTTP/") {
        return Err(anyhow::anyhow!("HTTP_ERROR: invalid status line").into());
    }
    let code = parts
        .next()
        .ok_or_else(|| anyhow::anyhow!("HTTP_ERROR: missing status code"))?;
    code.parse::<u16>()
        .map_err(|_| anyhow::anyhow!("HTTP_ERROR: invalid status code").into())
}

fn decode_chunked_body(bytes: &[u8]) -> wasmtime::Result<Vec<u8>> {
    let mut out = Vec::new();
    let mut cursor = 0usize;

    loop {
        let size_line_end = find_crlf(bytes, cursor)
            .ok_or_else(|| anyhow::anyhow!("HTTP_ERROR: malformed chunked response"))?;
        let size_line = std::str::from_utf8(&bytes[cursor..size_line_end])
            .map_err(|_| anyhow::anyhow!("HTTP_ERROR: invalid chunk size line"))?;
        let size_hex = size_line.split(';').next().unwrap_or_default().trim();
        let size = usize::from_str_radix(size_hex, 16)
            .map_err(|_| anyhow::anyhow!("HTTP_ERROR: invalid chunk size"))?;

        cursor = size_line_end + 2;
        if size == 0 {
            // Consume optional trailer headers and the final CRLF.
            loop {
                let trailer_end = find_crlf(bytes, cursor)
                    .ok_or_else(|| anyhow::anyhow!("HTTP_ERROR: malformed chunk trailer"))?;
                if trailer_end == cursor {
                    return Ok(out);
                }
                cursor = trailer_end + 2;
            }
        }

        if cursor + size + 2 > bytes.len() {
            return Err(anyhow::anyhow!("HTTP_ERROR: truncated chunked response").into());
        }
        out.extend_from_slice(&bytes[cursor..cursor + size]);
        if out.len() > MAX_RESPONSE_BYTES {
            return Err(anyhow::anyhow!("HTTP_ERROR: response body too large").into());
        }
        cursor += size;
        if &bytes[cursor..cursor + 2] != b"\r\n" {
            return Err(anyhow::anyhow!("HTTP_ERROR: malformed chunk terminator").into());
        }
        cursor += 2;
    }
}

fn find_crlf(bytes: &[u8], from: usize) -> Option<usize> {
    if from >= bytes.len() {
        return None;
    }
    bytes[from..]
        .windows(2)
        .position(|w| w == b"\r\n")
        .map(|idx| from + idx)
}

fn map_http_error(err: impl std::fmt::Display) -> wasmtime::Error {
    anyhow::anyhow!("HTTP_ERROR: {err}").into()
}

fn map_io_http_error(err: std::io::Error) -> wasmtime::Error {
    match err.kind() {
        std::io::ErrorKind::TimedOut | std::io::ErrorKind::WouldBlock => {
            anyhow::anyhow!("TIMEOUT: http request timed out").into()
        }
        _ => anyhow::anyhow!("HTTP_ERROR: {err}").into(),
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::kv_store::KvStore;
    use crate::policy::GrantSet;
    use crate::scoped_fs::ScopedFs;
    use crate::state::HostState;

    fn test_state(caps: &[&str]) -> HostState {
        let unique = std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .unwrap_or_default()
            .as_nanos();
        let kv_dir = std::env::temp_dir().join(format!("octon-http-host-test-{unique}"));

        HostState {
            wasi_ctx: wasmtime_wasi::WasiCtxBuilder::new().build(),
            table: wasmtime_wasi::ResourceTable::new(),
            grants: GrantSet::new(caps.iter().copied()),
            kv: KvStore::open(kv_dir).expect("kv open"),
            fs: ScopedFs::new(std::env::current_dir().expect("cwd")).expect("scoped fs"),
        }
    }

    fn get_request(url: &str, timeout_ms: u64) -> http::Request {
        http::Request {
            method: "GET".to_string(),
            url: url.to_string(),
            headers: Vec::new(),
            body: Vec::new(),
            timeout_ms: Some(timeout_ms),
        }
    }

    #[test]
    fn http_send_denies_without_capability() {
        let mut state = test_state(&[]);
        let err = <HostState as http::Host>::send(&mut state, get_request("http://127.0.0.1:1/", 50))
            .expect_err("expected capability denied");
        assert!(err.to_string().contains("CAPABILITY_DENIED"));
    }

    #[test]
    fn io_timeout_maps_timeout_error() {
        let err = map_io_http_error(std::io::Error::new(
            std::io::ErrorKind::TimedOut,
            "timed out",
        ));
        assert!(err.to_string().contains("TIMEOUT:"));
    }

    #[test]
    fn malformed_response_maps_http_error() {
        let err = parse_http_response(b"not-http\r\n\r\n").expect_err("expected parse error");
        assert!(err.to_string().contains("HTTP_ERROR:"));
    }
}
