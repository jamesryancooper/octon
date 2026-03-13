use serde::{Deserialize, Serialize};

mod bindings {
    wit_bindgen::generate!({
        world: "octon-service",
        path: "wit/world.wit",
    });
}

#[derive(Default)]
pub struct Service;

#[derive(Debug, Deserialize)]
struct PutInput {
    key: String,
    value: String,
}

#[derive(Debug, Deserialize)]
struct GetInput {
    key: String,
}

#[derive(Debug, Deserialize)]
struct DelInput {
    key: String,
}

#[derive(Debug, Serialize)]
struct OkOutput {
    ok: bool,
}

#[derive(Debug, Serialize)]
struct GetOutput {
    value: Option<String>,
}

impl bindings::Guest for Service {
    fn invoke(op: String, input_json: String) -> String {
        match op.as_str() {
            "put" => {
                let req: PutInput = serde_json::from_str(&input_json).expect("invalid put input");
                let _ = bindings::octon::runtime::log::write(
                    "info",
                    &format!("kv.put key={}", req.key),
                );
                bindings::octon::runtime::kv::put(&req.key, &req.value);
                serde_json::to_string(&OkOutput { ok: true }).unwrap()
            }
            "get" => {
                let req: GetInput = serde_json::from_str(&input_json).expect("invalid get input");
                let value = bindings::octon::runtime::kv::get(&req.key);
                serde_json::to_string(&GetOutput { value }).unwrap()
            }
            "del" => {
                let req: DelInput = serde_json::from_str(&input_json).expect("invalid del input");
                bindings::octon::runtime::kv::del(&req.key);
                serde_json::to_string(&OkOutput { ok: true }).unwrap()
            }
            _ => {
                panic!("unknown op: {}", op);
            }
        }
    }
}

bindings::export!(Service);
