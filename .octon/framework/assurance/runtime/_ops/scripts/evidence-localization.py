#!/usr/bin/env python3
"""Copy-before-remove external evidence localization with fail-closed receipts."""
import argparse, datetime as dt, hashlib, json, os, platform, shutil, subprocess, sys
from pathlib import Path

VERSION = "1.0.0"
TERMINAL = {"terminal", "cancelled", "superseded", "rolled-back", "explicitly-inactive"}
MANUAL = {"retain-external", "duplicate-contained", "superseded-retained"}

def die(message): raise SystemExit(f"[ERROR] {message}")
def sha_bytes(data): return "sha256:" + hashlib.sha256(data).hexdigest()
def sha_file(path):
    h=hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda:f.read(1024*1024), b""): h.update(chunk)
    return "sha256:"+h.hexdigest()
def canonical_json(value): return json.dumps(value, sort_keys=True, separators=(",", ":")).encode()
def now(): return dt.datetime.now(dt.timezone.utc).replace(microsecond=0).isoformat().replace("+00:00","Z")
def git(root,*args): return subprocess.check_output(["git","-C",str(root),*args], text=True).strip()
def origin(root):
    value=git(root,"remote","get-url","origin").strip()
    return value.removesuffix(".git").lower()
def repo_identity(root): return sha_bytes(origin(root).encode())
def root_fingerprint(root): return sha_bytes((str(root.resolve())+"\n"+repo_identity(root)).encode())
def archive_root(policy):
    home=Path.home().resolve(); system=platform.system()
    key={"Darwin":"macos_subpath","Linux":"linux_subpath","Windows":"windows_subpath"}.get(system)
    if not key: die(f"unsupported platform: {system}")
    result=(home/policy["archive_root"][key]).resolve()
    if result == home or home not in result.parents: die("archive root escapes canonical application-data home")
    return result
def load(path): return json.loads(Path(path).read_text())
def write(path,value):
    path.parent.mkdir(parents=True,exist_ok=True)
    tmp=path.with_suffix(path.suffix+".tmp")
    tmp.write_text(json.dumps(value,indent=2,sort_keys=True)+"\n"); os.replace(tmp,path)
def safe_source(root,text):
    p=Path(text)
    if p.is_absolute() or ".." in p.parts: die(f"non-canonical source path: {text}")
    full=(root/p).resolve(strict=True)
    if root.resolve() not in full.parents: die(f"source escapes repository: {text}")
    if (root/p).is_symlink(): die(f"symlink source forbidden: {text}")
    if not full.is_file(): die(f"source must be a regular file: {text}")
    return full
def local_receipt_path(root,text,archive_id=None):
    p=Path(text)
    if p.is_absolute(): die("compact receipt path must be repository-relative")
    full=(root/p).resolve(); base=(root/".octon/state/evidence/local/evidence-localization").resolve()
    if base not in full.parents: die("compact receipt must use the protected local evidence sink")
    if archive_id and archive_id not in full.parts: die("compact receipt path must bind archive id")
    return full
def tracked_references(root,rel):
    result=subprocess.run(["git","-C",str(root),"grep","-l","-F","--",rel,"HEAD"],text=True,capture_output=True)
    if result.returncode not in (0,1): die(f"tracked reference scan failed: {rel}")
    return sorted(line.split(":",1)[-1] for line in result.stdout.splitlines() if line)
def file_fingerprints(root,paths):
    rows=[]
    for rel in sorted(set(paths)):
        p=safe_source(root,rel); rows.append({"path":rel,"digest":sha_file(p),"size":p.stat().st_size})
    return rows
def inventory(root,request):
    if request.get("repository_identity") != repo_identity(root): die("unknown or forged repository identity")
    if not request.get("rollback_posture"): die("rollback posture is required")
    rows=[]; seen=set()
    for item in request.get("entries",[]):
        rel=item.get("source_path","")
        if rel in seen: die(f"duplicate source path: {rel}")
        seen.add(rel); src=safe_source(root,rel)
        verdict=item.get("active_state_verdict")
        if verdict not in TERMINAL: die(f"owning run is not proven inactive: {rel}")
        state_refs=item.get("active_state_evidence",[])
        if not state_refs: die(f"missing inactivity evidence: {rel}")
        state_text=[]
        for ref in state_refs:
            state_text.append(safe_source(root,ref).read_text(errors="ignore").lower())
        if not any(any(token in text for token in ["closed","terminal","cancelled","superseded","rolled-back","explicitly-inactive"]) for text in state_text): die(f"inactivity evidence does not prove terminal state: {rel}")
        if item.get("evidence_class") == "manual-review" and item.get("manual_review_disposition") not in MANUAL: die(f"manual-review disposition required: {rel}")
        if sorted(item.get("reference_relationships",[])) != tracked_references(root,rel): die(f"reference relationship map is incomplete or stale: {rel}")
        run=item.get("owning_run_id","")
        for lockroot in [root/".octon/state/control/execution/locks",root/".octon/state/control/execution/leases"]:
            if run and lockroot.exists() and any(run in p.read_text(errors="ignore") for p in lockroot.rglob("*") if p.is_file()): die(f"unresolved lock or lease for {run}")
        row=dict(item); row.update(file_type="file",size=src.stat().st_size,digest=sha_file(src))
        rows.append(row)
    if not rows: die("empty source inventory")
    rows.sort(key=lambda x:x["source_path"])
    return rows,sha_bytes(canonical_json([{"path":r["source_path"],"digest":r["digest"],"size":r["size"]} for r in rows]))
def archive_paths(root,policy,inventory_digest):
    rid=repo_identity(root).split(":",1)[1]; seed=sha_bytes((rid+inventory_digest).encode()).split(":",1)[1]
    aid="archive-"+seed[:32]; lid="localize-"+seed[32:64]
    base=archive_root(policy)
    if root.resolve()==base or root.resolve() in base.parents or base in root.resolve().parents: die("external archive root must be outside repository and .git")
    return base/rid/aid,aid,lid
def validate_archive(adir,expected_manifest_digest=None):
    mp=adir/"manifest.json"
    if not mp.is_file(): die("external manifest missing")
    manifest=load(mp)
    if expected_manifest_digest and sha_file(mp)!=expected_manifest_digest: die("external manifest digest mismatch")
    expected={e["destination_path"] for e in manifest["entries"]}|{"manifest.json"}
    actual={p.relative_to(adir).as_posix() for p in adir.rglob("*") if p.is_file()}
    if actual!=expected: die("external archive has missing or extra content")
    for e in manifest["entries"]:
        dst=(adir/e["destination_path"]).resolve()
        if adir.resolve() not in dst.parents or not dst.is_file() or sha_file(dst)!=e["digest"] or dst.stat().st_size!=e["size"]: die(f"archive verification failed: {e['source_path']}")
    if manifest.get("state")!="verified": die("archive is not verified")
    return manifest,sha_file(mp)
def cmd_localize(a,root,policy):
    req=load(a.request); rows,inv=inventory(root,req); adir,aid,lid=archive_paths(root,policy,inv)
    if adir.exists() and (adir/"manifest.json").exists():
        old,digest=validate_archive(adir)
        if old["inventory_digest"]!=inv: die("conflicting archive id")
        receipt_path=(root/".octon/state/evidence/local/evidence-localization"/aid/"receipt.json").resolve()
        print(json.dumps({"archive":str(adir),"archive_id":aid,"manifest_digest":digest,"receipt_path":str(receipt_path.relative_to(root)),"reused":True})); return
    (adir/"objects").mkdir(parents=True,exist_ok=True)
    entries=[]
    for row in rows:
        src=safe_source(root,row["source_path"]); dest_rel="objects/"+row["digest"].split(":",1)[1]; dst=adir/dest_rel
        if dst.exists() and sha_file(dst)!=row["digest"]: die("conflicting archive object")
        result="reused" if dst.exists() else "copied"
        if not dst.exists(): shutil.copy2(src,dst)
        if sha_file(dst)!=row["digest"]: die("destination digest mismatch")
        item=dict(row); item.update(destination_path=dest_rel,copy_result=result,verification_result="verified",cleanup_eligibility=True); entries.append(item)
    manifest={"schema_version":"evidence-localization-manifest-v1","repository":{"identity":repo_identity(root),"canonical_origin":origin(root),"root_fingerprint":root_fingerprint(root)},"archive_id":aid,"localization_run_id":lid,"created_at":now(),"tool_version":VERSION,"source_refs":{"main":git(root,"rev-parse","main"),"origin_main":git(root,"rev-parse","origin/main")},"inventory_digest":inv,"entries":entries,"rollback_instructions":req["rollback_posture"],"state":"verified"}
    write(adir/"manifest.json",manifest); manifest,digest=validate_archive(adir)
    receipt={"schema_version":"evidence-localization-receipt-v1","archive_id":aid,"localization_run_id":lid,"repository_identity":repo_identity(root),"manifest_digest":digest,"inventory_digest":inv,"archive_path":str(adir),"retrieval_command":f"evidence-localization.py retrieve --archive-id {aid} --output <directory>","verification_command":f"evidence-localization.py verify --archive-id {aid}","non_authority_classification":"retained-external-evidence-only","verified_at":now()}
    receipt_path=(root/".octon/state/evidence/local/evidence-localization"/aid/"receipt.json").resolve(); write(receipt_path,receipt); receipt["receipt_path"]=str(receipt_path.relative_to(root)); print(json.dumps(receipt))
def find_archive(root,policy,aid):
    if not aid.startswith("archive-") or "/" in aid: die("invalid archive id")
    return archive_root(policy)/repo_identity(root).split(":",1)[1]/aid
def cmd_verify(a,root,policy):
    m,d=validate_archive(find_archive(root,policy,a.archive_id)); print(json.dumps({"archive_id":m["archive_id"],"manifest_digest":d,"verified":True}))
def cmd_authorize(a,root,policy):
    adir=find_archive(root,policy,a.archive_id); m,md=validate_archive(adir)
    fps=[]
    for e in m["entries"]:
        src=safe_source(root,e["source_path"])
        if sha_file(src)!=e["digest"] or src.stat().st_size!=e["size"]: die("source drift after localization")
        fps.append({"path":e["source_path"],"digest":e["digest"],"size":e["size"]})
    issued=dt.datetime.now(dt.timezone.utc); expires=issued+dt.timedelta(seconds=int(policy["retention"]["cleanup_authorization_ttl_seconds"]))
    req=load(a.request); inactivity=file_fingerprints(root,[ref for e in m["entries"] for ref in e["active_state_evidence"]]); exclusions=file_fingerprints(root,req.get("exclusions",[]))
    auth={"schema_version":"evidence-localization-cleanup-authorization-v1","authorization_id":"cleanup-"+md.split(":",1)[1][:32],"archive_id":m["archive_id"],"repository_identity":repo_identity(root),"manifest_digest":md,"inventory_digest":m["inventory_digest"],"source_fingerprints":fps,"inactivity_evidence_fingerprints":inactivity,"inactivity_evidence_digest":sha_bytes(canonical_json(inactivity)),"exclusion_fingerprints":exclusions,"exclusions_digest":sha_bytes(canonical_json(exclusions)),"rollback_posture_digest":sha_bytes(m["rollback_instructions"].encode()),"issued_at":issued.isoformat().replace("+00:00","Z"),"expires_at":expires.isoformat().replace("+00:00","Z"),"decision":"authorized"}
    write(local_receipt_path(root,a.authorization,m["archive_id"]),auth); print(json.dumps(auth))
def cmd_cleanup(a,root,policy):
    auth=load(a.authorization); adir=find_archive(root,policy,auth.get("archive_id","")); m,md=validate_archive(adir,auth.get("manifest_digest"))
    if auth.get("schema_version")!="evidence-localization-cleanup-authorization-v1" or auth.get("repository_identity")!=repo_identity(root) or auth.get("inventory_digest")!=m["inventory_digest"]: die("cleanup authorization mismatch")
    expiry=dt.datetime.fromisoformat(auth["expires_at"].replace("Z","+00:00"))
    if dt.datetime.now(dt.timezone.utc)>expiry: die("cleanup authorization expired")
    expected={x["path"]:x for x in auth["source_fingerprints"]}
    if expected.keys()!={e["source_path"] for e in m["entries"]}: die("cleanup path set mismatch")
    for rel,fp in expected.items():
        src=safe_source(root,rel)
        if sha_file(src)!=fp["digest"] or src.stat().st_size!=fp["size"]: die("source drift before cleanup")
        entry=next(e for e in m["entries"] if e["source_path"]==rel)
        if tracked_references(root,rel)!=sorted(entry["reference_relationships"]): die("new or changed source reference before cleanup")
    if file_fingerprints(root,[x["path"] for x in auth["inactivity_evidence_fingerprints"]])!=auth["inactivity_evidence_fingerprints"]: die("inactivity evidence drift before cleanup")
    if file_fingerprints(root,[x["path"] for x in auth["exclusion_fingerprints"]])!=auth["exclusion_fingerprints"]: die("excluded path drift before cleanup")
    for rel in sorted(expected,reverse=True): (root/rel).unlink()
    for rel in expected:
        if (root/rel).exists(): die("authorized source remains after cleanup")
    if file_fingerprints(root,[x["path"] for x in auth["exclusion_fingerprints"]])!=auth["exclusion_fingerprints"]: die("excluded path changed during cleanup")
    validate_archive(adir,md); print(json.dumps({"archive_id":m["archive_id"],"removed":len(expected),"archive_valid":True}))
def cmd_retrieve(a,root,policy):
    adir=find_archive(root,policy,a.archive_id); m,_=validate_archive(adir); out=Path(a.output).resolve(); out.mkdir(parents=True,exist_ok=True)
    for e in m["entries"]:
        dst=(out/e["source_path"]).resolve()
        if out not in dst.parents: die("retrieval path escape")
        dst.parent.mkdir(parents=True,exist_ok=True); shutil.copy2(adir/e["destination_path"],dst)
    print(json.dumps({"archive_id":m["archive_id"],"retrieved":len(m["entries"]),"output":str(out)}))
def main():
    p=argparse.ArgumentParser(); p.add_argument("--root",default="."); sub=p.add_subparsers(dest="cmd",required=True)
    q=sub.add_parser("localize"); q.add_argument("--request",required=True)
    q=sub.add_parser("verify"); q.add_argument("--archive-id",required=True)
    q=sub.add_parser("authorize-cleanup"); q.add_argument("--archive-id",required=True); q.add_argument("--request",required=True); q.add_argument("--authorization",required=True)
    q=sub.add_parser("cleanup"); q.add_argument("--authorization",required=True)
    q=sub.add_parser("retrieve"); q.add_argument("--archive-id",required=True); q.add_argument("--output",required=True)
    a=p.parse_args(); root=Path(a.root).resolve(); policy_path=root/".octon/instance/governance/policies/evidence-localization.yml"
    if not policy_path.is_file(): die("canonical evidence localization policy missing")
    try:
        policy=json.loads(subprocess.check_output(["yq","-o=json",str(policy_path)],text=True))
    except (FileNotFoundError, subprocess.CalledProcessError, json.JSONDecodeError): die("canonical policy cannot be parsed with yq")
    {"localize":cmd_localize,"verify":cmd_verify,"authorize-cleanup":cmd_authorize,"cleanup":cmd_cleanup,"retrieve":cmd_retrieve}[a.cmd](a,root,policy)
if __name__=="__main__": main()
