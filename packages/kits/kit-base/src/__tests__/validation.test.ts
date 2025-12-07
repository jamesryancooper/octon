/**
 * Tests for Zod-based validation utilities.
 */

import { describe, it, expect } from "vitest";
import {
  z,
  validateWithSchema,
  safeValidate,
  createValidator,
  validateKitMetadataStrict,
  validateWithEnforcement,
  BaseKitConfigSchema,
  KitMetadataSchema,
  HarmonyPillarSchema,
  LifecycleStageSchema,
  EnforcementModeSchema,
  parseSemver,
  compareSemver,
  isVersionSupported,
  CURRENT_SCHEMA_VERSION,
  CURRENT_METHODOLOGY_VERSION,
} from "../validation.js";
import { InputValidationError } from "../errors.js";

describe("validation", () => {
  describe("validateWithSchema", () => {
    const TestSchema = z.object({
      name: z.string(),
      count: z.number().positive(),
    });

    it("should validate valid data", () => {
      const result = validateWithSchema(
        TestSchema,
        { name: "test", count: 5 },
        "TestSchema"
      );

      expect(result.name).toBe("test");
      expect(result.count).toBe(5);
    });

    it("should throw InputValidationError for invalid data", () => {
      expect(() =>
        validateWithSchema(TestSchema, { name: "test", count: -1 }, "TestSchema")
      ).toThrow(InputValidationError);
    });

    it("should include schema name in error", () => {
      try {
        validateWithSchema(TestSchema, { name: "test" }, "TestSchema");
      } catch (error) {
        expect(error).toBeInstanceOf(InputValidationError);
        expect((error as InputValidationError).message).toContain("TestSchema");
      }
    });
  });

  describe("safeValidate", () => {
    const TestSchema = z.object({
      value: z.string(),
    });

    it("should return success for valid data", () => {
      const result = safeValidate(TestSchema, { value: "test" });

      expect(result.success).toBe(true);
      expect(result.data?.value).toBe("test");
    });

    it("should return errors for invalid data", () => {
      const result = safeValidate(TestSchema, { value: 123 });

      expect(result.success).toBe(false);
      expect(result.errors).toBeDefined();
      expect(result.errors?.length).toBeGreaterThan(0);
    });
  });

  describe("createValidator", () => {
    const TestSchema = z.object({
      id: z.string().uuid(),
    });

    it("should create a reusable validator", () => {
      const validate = createValidator(TestSchema, "TestSchema");
      const data = { id: "550e8400-e29b-41d4-a716-446655440000" };

      const result = validate(data);
      expect(result.id).toBe(data.id);
    });

    it("should throw for invalid data", () => {
      const validate = createValidator(TestSchema, "TestSchema");

      expect(() => validate({ id: "not-a-uuid" })).toThrow(InputValidationError);
    });
  });

  describe("validateKitMetadataStrict", () => {
    const validMetadata = {
      name: "testkit",
      version: "0.1.0",
      description: "Test kit",
      pillars: ["speed_with_safety"],
      lifecycleStages: ["implement"],
      inputsSchema: "schema/test.inputs.json",
      outputsSchema: "schema/test.outputs.json",
      observability: {
        serviceName: "harmony.kit.testkit",
        requiredSpans: ["kit.testkit.run"],
      },
      determinism: {
        ai: null,
      },
      safety: {
        hitl: {},
      },
      idempotency: {
        required: true,
      },
    };

    it("should validate valid metadata", () => {
      const result = validateKitMetadataStrict(validMetadata);

      expect(result.success).toBe(true);
      expect(result.data?.name).toBe("testkit");
    });

    it("should fail for missing required fields", () => {
      const invalid = {
        name: "testkit",
        version: "0.1.0",
        // Missing pillars, lifecycleStages, etc.
      };

      const result = validateKitMetadataStrict(invalid);

      expect(result.success).toBe(false);
      expect(result.errors).toBeDefined();
    });

    it("should fail for invalid pillar", () => {
      const invalid = {
        ...validMetadata,
        pillars: ["invalid_pillar"],
      };

      const result = validateKitMetadataStrict(invalid);

      expect(result.success).toBe(false);
    });

    it("should accept all valid pillars", () => {
      const pillars = [
        "speed_with_safety",
        "simplicity_over_complexity",
        "quality_through_determinism",
        "guided_agentic_autonomy",
        "evolvable_modularity",
      ];

      const result = validateKitMetadataStrict({
        ...validMetadata,
        pillars,
      });

      expect(result.success).toBe(true);
    });
  });

  describe("BaseKitConfigSchema", () => {
    it("should use default values", () => {
      const result = BaseKitConfigSchema.parse({});

      expect(result.enableRunRecords).toBe(true);
      expect(result.dryRun).toBe(false);
    });

    it("should override defaults", () => {
      const result = BaseKitConfigSchema.parse({
        enableRunRecords: false,
        dryRun: true,
        runsDir: "./custom-runs",
      });

      expect(result.enableRunRecords).toBe(false);
      expect(result.dryRun).toBe(true);
      expect(result.runsDir).toBe("./custom-runs");
    });
  });

  describe("HarmonyPillarSchema", () => {
    it("should accept valid pillars", () => {
      expect(() => HarmonyPillarSchema.parse("speed_with_safety")).not.toThrow();
      expect(() => HarmonyPillarSchema.parse("evolvable_modularity")).not.toThrow();
    });

    it("should reject invalid pillars", () => {
      expect(() => HarmonyPillarSchema.parse("invalid")).toThrow();
    });
  });

  describe("LifecycleStageSchema", () => {
    it("should accept valid stages", () => {
      const validStages = [
        "spec",
        "plan",
        "implement",
        "verify",
        "ship",
        "operate",
        "learn",
      ];

      for (const stage of validStages) {
        expect(() => LifecycleStageSchema.parse(stage)).not.toThrow();
      }
    });

    it("should reject invalid stages", () => {
      expect(() => LifecycleStageSchema.parse("design")).toThrow();
    });
  });

  describe("EnforcementModeSchema", () => {
    it("should accept valid enforcement modes", () => {
      expect(() => EnforcementModeSchema.parse("block")).not.toThrow();
      expect(() => EnforcementModeSchema.parse("warn")).not.toThrow();
      expect(() => EnforcementModeSchema.parse("off")).not.toThrow();
    });

    it("should reject invalid enforcement modes", () => {
      expect(() => EnforcementModeSchema.parse("invalid")).toThrow();
    });
  });

  describe("validateWithEnforcement", () => {
    const TestSchema = z.object({
      name: z.string(),
      count: z.number().positive(),
    });

    it("should validate in block mode (default)", () => {
      const result = validateWithEnforcement(TestSchema, { name: "test", count: -1 });

      expect(result.success).toBe(false);
      expect(result.errors).toBeDefined();
      expect(result.enforcement).toBe("block");
    });

    it("should return success in warn mode even for invalid data", () => {
      const result = validateWithEnforcement(
        TestSchema,
        { name: "test", count: -1 },
        { enforcementMode: "warn" }
      );

      expect(result.success).toBe(true);
      expect(result.warnings).toBeDefined();
      expect(result.enforcement).toBe("warn");
    });

    it("should skip validation in off mode", () => {
      const result = validateWithEnforcement(
        TestSchema,
        { invalid: true },
        { enforcementMode: "off" }
      );

      expect(result.success).toBe(true);
      expect(result.enforcement).toBe("off");
    });
  });

  describe("semver utilities", () => {
    describe("parseSemver", () => {
      it("should parse standard semver", () => {
        const v = parseSemver("1.2.3");
        expect(v.major).toBe(1);
        expect(v.minor).toBe(2);
        expect(v.patch).toBe(3);
      });

      it("should parse semver with prerelease", () => {
        const v = parseSemver("1.2.3-alpha.1");
        expect(v.major).toBe(1);
        expect(v.minor).toBe(2);
        expect(v.patch).toBe(3);
        expect(v.prerelease).toBe("alpha.1");
      });

      it("should throw for invalid semver", () => {
        expect(() => parseSemver("not-a-version")).toThrow();
      });
    });

    describe("compareSemver", () => {
      it("should compare major versions", () => {
        expect(compareSemver("1.0.0", "2.0.0")).toBe(-1);
        expect(compareSemver("2.0.0", "1.0.0")).toBe(1);
      });

      it("should compare minor versions", () => {
        expect(compareSemver("1.1.0", "1.2.0")).toBe(-1);
        expect(compareSemver("1.2.0", "1.1.0")).toBe(1);
      });

      it("should compare patch versions", () => {
        expect(compareSemver("1.0.1", "1.0.2")).toBe(-1);
        expect(compareSemver("1.0.2", "1.0.1")).toBe(1);
      });

      it("should return 0 for equal versions", () => {
        expect(compareSemver("1.2.3", "1.2.3")).toBe(0);
      });
    });

    describe("isVersionSupported", () => {
      it("should accept versions in range", () => {
        expect(isVersionSupported("1.1.0", "1.0.0", "1.2.0")).toBe(true);
      });

      it("should reject versions below min", () => {
        expect(isVersionSupported("0.9.0", "1.0.0", "1.2.0")).toBe(false);
      });

      it("should reject versions above max", () => {
        expect(isVersionSupported("1.3.0", "1.0.0", "1.2.0")).toBe(false);
      });

      it("should work with only min version", () => {
        expect(isVersionSupported("2.0.0", "1.0.0")).toBe(true);
        expect(isVersionSupported("0.5.0", "1.0.0")).toBe(false);
      });
    });
  });

  describe("version constants", () => {
    it("should export current schema version", () => {
      expect(CURRENT_SCHEMA_VERSION).toBe("1.2.0");
    });

    it("should export current methodology version", () => {
      expect(CURRENT_METHODOLOGY_VERSION).toBe("0.2.0");
    });
  });
});

