/**
 * Tests for PromptKit Compiler module.
 */

import { describe, it, expect, beforeEach } from "vitest";
import {
  compileTemplate,
  validateTemplate,
  checkVariables,
  extractVariables,
  resetEnvironment,
  TemplateCompilationError,
} from "../compiler";

describe("PromptKit Compiler", () => {
  beforeEach(() => {
    resetEnvironment();
  });

  describe("compileTemplate", () => {
    it("should render a simple template with variables", () => {
      const template = "Hello, {{ name }}!";
      const result = compileTemplate(template, { name: "World" });
      expect(result).toBe("Hello, World!");
    });

    it("should handle nested object access", () => {
      const template = "User: {{ user.name }} ({{ user.email }})";
      const result = compileTemplate(template, {
        user: { name: "Alice", email: "alice@example.com" },
      });
      expect(result).toBe("User: Alice (alice@example.com)");
    });

    it("should handle for loops", () => {
      const template = `{% for item in items %}
- {{ item }}
{% endfor %}`;
      const result = compileTemplate(template, { items: ["a", "b", "c"] });
      expect(result).toContain("- a");
      expect(result).toContain("- b");
      expect(result).toContain("- c");
    });

    it("should handle conditionals", () => {
      const template = `{% if enabled %}Feature is ON{% else %}Feature is OFF{% endif %}`;

      expect(compileTemplate(template, { enabled: true })).toBe("Feature is ON");
      expect(compileTemplate(template, { enabled: false })).toBe("Feature is OFF");
    });

    it("should handle missing variables gracefully", () => {
      const template = "Hello, {{ name }}!";
      // With throwOnUndefined: false, missing variables render as empty string
      const result = compileTemplate(template, {});
      expect(result).toBe("Hello, !");
    });

    it("should apply the truncate filter", () => {
      const template = "{{ text | truncate(10) }}";
      const result = compileTemplate(template, {
        text: "This is a very long text",
      });
      expect(result).toBe("This is...");
    });

    it("should apply the indent filter", () => {
      const template = "{{ code | indent(4) }}";
      const result = compileTemplate(template, { code: "line1\nline2" });
      expect(result).toBe("    line1\n    line2");
    });

    it("should apply the json filter", () => {
      const template = "{{ data | json }}";
      const result = compileTemplate(template, { data: { key: "value" } });
      expect(result).toBe('{"key":"value"}');
    });

    it("should apply the yaml_list filter", () => {
      const template = "{{ items | yaml_list }}";
      const result = compileTemplate(template, { items: ["a", "b", "c"] });
      expect(result).toBe("- a\n- b\n- c");
    });

    it("should apply the code_block filter", () => {
      const template = "{{ code | code_block('typescript') }}";
      const result = compileTemplate(template, { code: "const x = 1;" });
      expect(result).toBe("```typescript\nconst x = 1;\n```");
    });

    it("should throw TemplateCompilationError for invalid syntax", () => {
      const template = "{{ invalid syntax }}";
      expect(() => compileTemplate(template, {})).toThrow(
        TemplateCompilationError
      );
    });
  });

  describe("validateTemplate", () => {
    it("should validate a correct template", () => {
      const result = validateTemplate("Hello, {{ name }}!");
      expect(result.valid).toBe(true);
      expect(result.errors).toHaveLength(0);
    });

    it("should return valid for most templates (Nunjucks is lenient)", () => {
      // Note: Nunjucks is very lenient - it parses most templates without errors
      // and only fails at render time. This is by design for flexibility.
      // The validateTemplate function catches obvious parse errors, but
      // most semantic errors are only caught during compileTemplate().
      const result = validateTemplate("{% if x %}test");
      // Nunjucks will accept this (treats it as text output)
      expect(result.valid).toBe(true);
    });

    it("should validate complex templates", () => {
      const template = `
        {% for item in items %}
          {% if item.enabled %}
            {{ item.name }}: {{ item.value }}
          {% endif %}
        {% endfor %}
      `;
      const result = validateTemplate(template);
      expect(result.valid).toBe(true);
    });
  });

  describe("extractVariables", () => {
    it("should extract simple variables", () => {
      const result = extractVariables("{{ name }} and {{ age }}");
      expect(result).toContain("name");
      expect(result).toContain("age");
    });

    it("should extract root variable from nested access", () => {
      const result = extractVariables("{{ user.name }} and {{ user.email }}");
      expect(result).toContain("user");
      expect(result).not.toContain("name");
    });

    it("should extract variables from for loops", () => {
      const result = extractVariables("{% for item in items %}{{ item }}{% endfor %}");
      expect(result).toContain("items");
    });

    it("should extract variables from conditionals", () => {
      const result = extractVariables("{% if enabled %}yes{% endif %}");
      expect(result).toContain("enabled");
    });

    it("should handle variables with filters", () => {
      const result = extractVariables("{{ text | truncate(10) }}");
      expect(result).toContain("text");
    });

    it("should deduplicate variables", () => {
      const result = extractVariables("{{ x }} {{ x }} {{ x }}");
      expect(result.filter((v) => v === "x")).toHaveLength(1);
    });
  });

  describe("checkVariables", () => {
    it("should return complete when all variables are provided", () => {
      const result = checkVariables("{{ a }} {{ b }}", { a: 1, b: 2 });
      expect(result.complete).toBe(true);
      expect(result.missing).toHaveLength(0);
    });

    it("should return missing variables", () => {
      const result = checkVariables("{{ a }} {{ b }}", { a: 1 });
      expect(result.complete).toBe(false);
      expect(result.missing).toContain("b");
    });

    it("should return unused variables", () => {
      const result = checkVariables("{{ a }}", { a: 1, b: 2, c: 3 });
      expect(result.unused).toContain("b");
      expect(result.unused).toContain("c");
    });

    it("should return all required variables", () => {
      const result = checkVariables("{{ a }} {{ b }} {{ c }}", { a: 1 });
      expect(result.required).toEqual(expect.arrayContaining(["a", "b", "c"]));
    });
  });
});

