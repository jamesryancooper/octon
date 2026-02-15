use wasmtime::component::bindgen;

bindgen!({
    world: "harmony-service",
    path: "../../wit",
});
