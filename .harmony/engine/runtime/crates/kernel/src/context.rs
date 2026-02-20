use harmony_core::config::{ConfigLoader, RuntimeConfig};
use harmony_core::discovery::ServiceDiscovery;
use harmony_core::policy::PolicyEngine;
use harmony_core::root::RootResolver;
use harmony_core::schema::SchemaStore;
use harmony_core::registry::ServiceRegistry;

use harmony_wasm_host::invoke::Invoker;

pub struct KernelContext {
    pub cfg: RuntimeConfig,
    pub registry: ServiceRegistry,
    pub policy: PolicyEngine,
    pub invoker: Invoker,
}

impl KernelContext {
    pub fn load() -> anyhow::Result<Self> {
        let harmony_dir = RootResolver::resolve()?;
        let cfg = ConfigLoader::load(&harmony_dir)?;
        let schemas = SchemaStore::load(&harmony_dir)?;
        let registry = ServiceDiscovery::discover(&harmony_dir, &schemas)?;
        let policy = PolicyEngine::new(cfg.clone());
        let invoker = Invoker::new(cfg.clone(), schemas.clone())?;

        Ok(Self {
            cfg,
            registry,
            policy,
            invoker,
        })
    }
}
