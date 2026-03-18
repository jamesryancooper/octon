use octon_core::config::{ConfigLoader, RuntimeConfig};
use octon_core::discovery::ServiceDiscovery;
use octon_core::policy::PolicyEngine;
use octon_core::root::RootResolver;
use octon_core::schema::SchemaStore;
use octon_core::registry::ServiceRegistry;

use octon_wasm_host::invoke::Invoker;

pub struct KernelContext {
    pub cfg: RuntimeConfig,
    pub schemas: SchemaStore,
    pub registry: ServiceRegistry,
    pub policy: PolicyEngine,
    pub invoker: Invoker,
}

impl KernelContext {
    pub fn load() -> anyhow::Result<Self> {
        let octon_dir = RootResolver::resolve()?;
        let cfg = ConfigLoader::load(&octon_dir)?;
        let schemas = SchemaStore::load(&octon_dir)?;
        let registry = ServiceDiscovery::discover(&octon_dir, &schemas)?;
        let policy = PolicyEngine::new(cfg.clone());
        let invoker = Invoker::new(cfg.clone(), schemas.clone())?;

        Ok(Self {
            cfg,
            schemas,
            registry,
            policy,
            invoker,
        })
    }
}
