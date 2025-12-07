/**
 * Tests for PromptKit Variants module.
 */

import { describe, it, expect } from "vitest";
import {
  selectVariant,
  isVariantEnabled,
  evaluateCondition,
  listVariants,
  validateVariants,
  createContext,
  getTiersForVariant,
  DEFAULT_VARIANT_ID,
} from "../variants";
import type { VariantConfig, VariantContext } from "../types";

describe("PromptKit Variants", () => {
  describe("selectVariant", () => {
    const testVariants: Record<string, VariantConfig> = {
      default: {
        template_path: "./prompt.md",
        description: "Default template",
      },
      concise: {
        template_path: "./prompt-concise.md",
        description: "Shorter template",
        enabled_when: [{ tier: ["T1"] }],
      },
      detailed: {
        template_path: "./prompt-detailed.md",
        description: "More detailed template",
        enabled_when: [{ tier: ["T3"] }],
      },
    };

    it("should select explicit variant when specified", () => {
      const result = selectVariant(testVariants, {}, "concise");
      expect(result.id).toBe("concise");
      expect(result.templatePath).toBe("./prompt-concise.md");
    });

    it("should fall back to auto-selection for unknown explicit variant", () => {
      const result = selectVariant(testVariants, { tier: "T2" }, "unknown");
      expect(result.id).toBe("default");
    });

    it("should select matching variant based on tier", () => {
      const result = selectVariant(testVariants, { tier: "T1" });
      expect(result.id).toBe("concise");
    });

    it("should select default when no conditions match", () => {
      const result = selectVariant(testVariants, { tier: "T2" });
      expect(result.id).toBe("default");
    });

    it("should return default variant when variants is undefined", () => {
      const result = selectVariant(undefined, {});
      expect(result.id).toBe(DEFAULT_VARIANT_ID);
    });

    it("should return first variant when no default defined", () => {
      const noDefault: Record<string, VariantConfig> = {
        first: { template_path: "./first.md" },
        second: { template_path: "./second.md" },
      };
      const result = selectVariant(noDefault, {});
      expect(result.id).toBe("first");
    });
  });

  describe("isVariantEnabled", () => {
    it("should return true for variant with no conditions", () => {
      const config: VariantConfig = { template_path: "./test.md" };
      expect(isVariantEnabled(config, {})).toBe(true);
    });

    it("should check tier condition", () => {
      const config: VariantConfig = {
        template_path: "./test.md",
        enabled_when: [{ tier: ["T1", "T2"] }],
      };

      expect(isVariantEnabled(config, { tier: "T1" })).toBe(true);
      expect(isVariantEnabled(config, { tier: "T2" })).toBe(true);
      expect(isVariantEnabled(config, { tier: "T3" })).toBe(false);
    });

    it("should check flag condition", () => {
      const config: VariantConfig = {
        template_path: "./test.md",
        enabled_when: [{ flag: "feature.enabled" }],
      };

      expect(
        isVariantEnabled(config, { flags: { "feature.enabled": true } })
      ).toBe(true);
      expect(
        isVariantEnabled(config, { flags: { "feature.enabled": false } })
      ).toBe(false);
      expect(isVariantEnabled(config, { flags: {} })).toBe(false);
    });

    it("should check stage condition", () => {
      const config: VariantConfig = {
        template_path: "./test.md",
        enabled_when: [{ stage: "draft" }],
      };

      expect(isVariantEnabled(config, { stage: "draft" })).toBe(true);
      expect(isVariantEnabled(config, { stage: "final" })).toBe(false);
    });

    it("should require all conditions to match", () => {
      const config: VariantConfig = {
        template_path: "./test.md",
        enabled_when: [{ tier: ["T1"], stage: "draft" }],
      };

      expect(isVariantEnabled(config, { tier: "T1", stage: "draft" })).toBe(true);
      expect(isVariantEnabled(config, { tier: "T1", stage: "final" })).toBe(false);
      expect(isVariantEnabled(config, { tier: "T2", stage: "draft" })).toBe(false);
    });
  });

  describe("evaluateCondition", () => {
    it("should evaluate flag condition", () => {
      expect(
        evaluateCondition({ flag: "test" }, { flags: { test: true } })
      ).toBe(true);
      expect(
        evaluateCondition({ flag: "test" }, { flags: { test: false } })
      ).toBe(false);
      expect(evaluateCondition({ flag: "test" }, {})).toBe(false);
    });

    it("should evaluate tier condition", () => {
      expect(
        evaluateCondition({ tier: ["T1", "T2"] }, { tier: "T1" })
      ).toBe(true);
      expect(
        evaluateCondition({ tier: ["T1", "T2"] }, { tier: "T3" })
      ).toBe(false);
    });

    it("should evaluate stage condition", () => {
      expect(evaluateCondition({ stage: "draft" }, { stage: "draft" })).toBe(
        true
      );
      expect(evaluateCondition({ stage: "draft" }, { stage: "final" })).toBe(
        false
      );
    });

    it("should handle empty condition", () => {
      expect(evaluateCondition({}, {})).toBe(true);
    });
  });

  describe("listVariants", () => {
    it("should list all variants", () => {
      const variants: Record<string, VariantConfig> = {
        default: { template_path: "./default.md" },
        concise: {
          template_path: "./concise.md",
          description: "Short version",
          enabled_when: [{ tier: ["T1"] }],
        },
      };

      const result = listVariants(variants);
      expect(result).toHaveLength(2);
      expect(result.find((v) => v.id === "default")).toBeDefined();
      expect(result.find((v) => v.id === "concise")).toBeDefined();
    });

    it("should return default for undefined variants", () => {
      const result = listVariants(undefined);
      expect(result).toHaveLength(1);
      expect(result[0].id).toBe(DEFAULT_VARIANT_ID);
    });
  });

  describe("validateVariants", () => {
    it("should validate correct variants", () => {
      const variants: Record<string, VariantConfig> = {
        default: { template_path: "./default.md" },
        concise: {
          template_path: "./concise.md",
          enabled_when: [{ tier: ["T1", "T2"] }],
        },
      };

      const result = validateVariants(variants);
      expect(result.valid).toBe(true);
      expect(result.errors).toHaveLength(0);
    });

    it("should warn when no default variant", () => {
      const variants: Record<string, VariantConfig> = {
        concise: { template_path: "./concise.md" },
      };

      const result = validateVariants(variants);
      expect(result.warnings).toContain(
        'No "default" variant defined - first variant will be used as fallback'
      );
    });

    it("should error on missing template_path", () => {
      const variants: Record<string, VariantConfig> = {
        broken: { template_path: "" },
      };

      const result = validateVariants(variants);
      expect(result.valid).toBe(false);
      expect(result.errors.some((e) => e.includes("missing template_path"))).toBe(true);
    });

    it("should error on invalid tier", () => {
      const variants: Record<string, VariantConfig> = {
        default: {
          template_path: "./test.md",
          enabled_when: [{ tier: ["T4" as any] }],
        },
      };

      const result = validateVariants(variants);
      expect(result.valid).toBe(false);
      expect(result.errors.some((e) => e.includes('invalid tier "T4"'))).toBe(true);
    });

    it("should error on invalid stage", () => {
      const variants: Record<string, VariantConfig> = {
        default: {
          template_path: "./test.md",
          enabled_when: [{ stage: "invalid" as any }],
        },
      };

      const result = validateVariants(variants);
      expect(result.valid).toBe(false);
      expect(result.errors.some((e) => e.includes("invalid stage"))).toBe(true);
    });
  });

  describe("createContext", () => {
    it("should create context from arguments", () => {
      const result = createContext("T2", "draft", { "feature.x": true });

      expect(result.tier).toBe("T2");
      expect(result.stage).toBe("draft");
      expect(result.flags).toEqual({ "feature.x": true });
    });

    it("should handle undefined values", () => {
      const result = createContext();
      expect(result.tier).toBeUndefined();
      expect(result.stage).toBeUndefined();
      expect(result.flags).toBeUndefined();
    });
  });

  describe("getTiersForVariant", () => {
    const variants: Record<string, VariantConfig> = {
      default: { template_path: "./default.md" },
      concise: {
        template_path: "./concise.md",
        enabled_when: [{ tier: ["T1"] }],
      },
    };

    it("should find tiers that use a variant", () => {
      const result = getTiersForVariant("concise", variants);
      expect(result).toContain("T1");
      expect(result).not.toContain("T2");
      expect(result).not.toContain("T3");
    });

    it("should find tiers that use default", () => {
      const result = getTiersForVariant("default", variants);
      expect(result).toContain("T2");
      expect(result).toContain("T3");
    });
  });
});

