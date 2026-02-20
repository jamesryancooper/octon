use wasmtime::component::bindgen;

bindgen!({
    world: "harmony-service",
    path: "../../wit",
    trappable_imports: true,
});
