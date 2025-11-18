import assert from "node:assert/strict";
import { test } from "node:test";

import { createHttpFlowRunner } from "../index";

type FetchResponse = Awaited<ReturnType<typeof fetch>>;

const baseConfig = {
  flowName: "architecture_assessment",
  canonicalPromptPath:
    "packages/prompts/assessment/architecture/architecture-assessment.md",
  workspaceRoot: "/tmp/harmony",
  workflowManifestPath:
    "packages/prompts/assessment/architecture/workflows/architecture-assessment.yaml",
  workflowEntrypoint: "architecture-inventory",
  observability: {
    spanPrefix: "harmony.flow.test"
  }
};

const createFetchStub = (response: {
  ok: boolean;
  status: number;
  statusText: string;
  body: unknown;
}): typeof fetch => {
  return (async () =>
    ({
      ok: response.ok,
      status: response.status,
      statusText: response.statusText,
      json: async () => response.body,
      text: async () => JSON.stringify(response.body)
    }) as FetchResponse) as typeof fetch;
};

test("createHttpFlowRunner posts payloads and surfaces metadata", async () => {
  const requests: Array<{ input: string | URL; body: string }> = [];
  const fetchStub: typeof fetch = async (input, init) => {
    requests.push({
      input,
      body: String(init?.body ?? "")
    });
    return {
      ok: true,
      status: 200,
      statusText: "OK",
      json: async () => ({
        result: { ok: true, score: 95 },
        metadata: { server: "runner" },
        runtimeRunId: "py-run",
        artifacts: ["report.json"]
      }),
      text: async () => ""
    } as FetchResponse;
  };

  const runner = createHttpFlowRunner({
    baseUrl: "http://127.0.0.1:8410",
    fetchImpl: fetchStub
  });

  const result = await runner.run({ config: baseConfig });

  assert.equal(requests.length, 1);
  assert.equal(requests[0].input, "http://127.0.0.1:8410/flows/run");
  const parsedBody = JSON.parse(requests[0].body);
  assert.equal(parsedBody.flowName, baseConfig.flowName);
  assert.equal(parsedBody.workflowManifestPath, baseConfig.workflowManifestPath);
  assert.equal(parsedBody.observability.spanPrefix, "harmony.flow.test");

  assert.deepEqual(result.result, { ok: true, score: 95 });
  assert.equal(result.runId.length > 0, true);
  assert.deepEqual(result.artifacts, ["report.json"]);
  assert.equal(result.metadata?.runnerEndpoint, "http://127.0.0.1:8410");
  assert.equal(result.metadata?.runtimeRunId, "py-run");
  assert.equal(result.metadata?.workspaceRoot, "/tmp/harmony");
  assert.equal(result.metadata?.workflowEntrypoint, "architecture-inventory");
  assert.equal(result.metadata?.spanPrefix, "harmony.flow.test");
});

test("createHttpFlowRunner throws when the runner returns non-2xx", async () => {
  const fetchStub = createFetchStub({
    ok: false,
    status: 500,
    statusText: "Server Error",
    body: { message: "boom" }
  });

  const runner = createHttpFlowRunner({
    baseUrl: "http://127.0.0.1:8410",
    fetchImpl: fetchStub
  });

  await assert.rejects(
    runner.run({ config: baseConfig }),
    /FlowKit HTTP runner request failed \(500/
  );
});

test("createHttpFlowRunner includes workspaceRoot when provided", async () => {
  const requests: Array<{ body: string }> = [];
  const fetchStub: typeof fetch = async (_input, init) => {
    requests.push({ body: String(init?.body ?? "") });
    return {
      ok: true,
      status: 200,
      statusText: "OK",
      json: async () => ({ result: { ok: true } }),
      text: async () => ""
    } as FetchResponse;
  };

  const runner = createHttpFlowRunner({
    baseUrl: "http://127.0.0.1:8410",
    fetchImpl: fetchStub
  });

  await runner.run({
    config: {
      ...baseConfig,
      workspaceRoot: "/tmp/custom-root"
    }
  });

  const payload = JSON.parse(requests[0].body);
  assert.equal(payload.workspaceRoot, "/tmp/custom-root");
});

