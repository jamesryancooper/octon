use wasmtime::component::bindgen;

bindgen!({
    world: "octon-service",
    path: "../../wit",
    trappable_imports: true,
});
