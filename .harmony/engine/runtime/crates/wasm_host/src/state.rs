use wasmtime_wasi::{ResourceTable, WasiCtx, WasiView};

use crate::kv_store::KvStore;
use crate::policy::GrantSet;
use crate::scoped_fs::ScopedFs;

pub struct HostState {
    pub wasi_ctx: WasiCtx,
    pub table: ResourceTable,

    // Harmony-specific state
    pub grants: GrantSet,
    pub kv: KvStore,
    pub fs: ScopedFs,
}

impl WasiView for HostState {
    fn ctx(&mut self) -> &mut WasiCtx {
        &mut self.wasi_ctx
    }

    fn table(&mut self) -> &mut ResourceTable {
        &mut self.table
    }
}
