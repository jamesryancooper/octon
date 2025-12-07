/**
 * FlowKit HTTP Runner Tests
 *
 * Uses vitest for testing.
 */

import { describe, it, expect } from "vitest";

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

describe("FlowKit HTTP Runner", () => {
  it("createHttpFlowRunner posts payloads and surfaces metadata", async () => {
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

    expect(requests.length).toBe(1);
    expect(requests[0].input).toBe("http://127.0.0.1:8410/flows/run");
    const parsedBody = JSON.parse(requests[0].body);
    expect(parsedBody.flowName).toBe(baseConfig.flowName);
    expect(parsedBody.workflowManifestPath).toBe(baseConfig.workflowManifestPath);
    expect(parsedBody.observability.spanPrefix).toBe("harmony.flow.test");

    expect(result.result).toEqual({ ok: true, score: 95 });
    expect(result.runId.length > 0).toBe(true);
    expect(result.artifacts).toEqual(["report.json"]);
    expect(result.metadata?.runnerEndpoint).toBe("http://127.0.0.1:8410");
    expect(result.metadata?.runtimeRunId).toBe("py-run");
    expect(result.metadata?.workspaceRoot).toBe("/tmp/harmony");
    expect(result.metadata?.workflowEntrypoint).toBe("architecture-inventory");
    expect(result.metadata?.spanPrefix).toBe("harmony.flow.test");
  });

  it("createHttpFlowRunner throws when the runner returns non-2xx", async () => {
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

    await expect(runner.run({ config: baseConfig })).rejects.toThrow(
      /FlowKit HTTP runner request failed \(500/
    );
  });

  it("createHttpFlowRunner includes workspaceRoot when provided", async () => {
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
    expect(payload.workspaceRoot).toBe("/tmp/custom-root");
  });
});
