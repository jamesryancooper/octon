/**
 * Terminal color utilities for the Harmony CLI.
 *
 * Uses ANSI escape codes directly to avoid dependencies.
 * Respects NO_COLOR environment variable.
 */

const isColorEnabled = (): boolean => {
  // Respect NO_COLOR standard
  if (process.env.NO_COLOR !== undefined) {
    return false;
  }
  // Check if stdout is a TTY
  if (process.stdout.isTTY === false) {
    return false;
  }
  // Check FORCE_COLOR
  if (process.env.FORCE_COLOR !== undefined) {
    return process.env.FORCE_COLOR !== "0";
  }
  return true;
};

const COLORS_ENABLED = isColorEnabled();

const wrap = (code: string, text: string): string => {
  if (!COLORS_ENABLED) return text;
  return `\x1b[${code}m${text}\x1b[0m`;
};

// Basic colors
export const bold = (text: string): string => wrap("1", text);
export const dim = (text: string): string => wrap("2", text);
export const italic = (text: string): string => wrap("3", text);
export const underline = (text: string): string => wrap("4", text);

// Foreground colors
export const red = (text: string): string => wrap("31", text);
export const green = (text: string): string => wrap("32", text);
export const yellow = (text: string): string => wrap("33", text);
export const blue = (text: string): string => wrap("34", text);
export const magenta = (text: string): string => wrap("35", text);
export const cyan = (text: string): string => wrap("36", text);
export const white = (text: string): string => wrap("37", text);
export const gray = (text: string): string => wrap("90", text);

// Bright foreground colors
export const brightRed = (text: string): string => wrap("91", text);
export const brightGreen = (text: string): string => wrap("92", text);
export const brightYellow = (text: string): string => wrap("93", text);
export const brightBlue = (text: string): string => wrap("94", text);
export const brightMagenta = (text: string): string => wrap("95", text);
export const brightCyan = (text: string): string => wrap("96", text);

// Background colors
export const bgRed = (text: string): string => wrap("41", text);
export const bgGreen = (text: string): string => wrap("42", text);
export const bgYellow = (text: string): string => wrap("43", text);
export const bgBlue = (text: string): string => wrap("44", text);

// Semantic colors for Harmony
export const success = (text: string): string => green(text);
export const error = (text: string): string => red(text);
export const warning = (text: string): string => yellow(text);
export const info = (text: string): string => blue(text);
export const highlight = (text: string): string => cyan(text);
export const muted = (text: string): string => gray(text);

// Tier colors
export const tier1 = (text: string): string => green(text);
export const tier2 = (text: string): string => yellow(text);
export const tier3 = (text: string): string => red(text);

export const tierColor = (tier: "T1" | "T2" | "T3", text: string): string => {
  switch (tier) {
    case "T1":
      return tier1(text);
    case "T2":
      return tier2(text);
    case "T3":
      return tier3(text);
  }
};

// Status colors
export const statusColor = (
  status: "ok" | "warning" | "error" | "pending",
  text: string
): string => {
  switch (status) {
    case "ok":
      return green(text);
    case "warning":
      return yellow(text);
    case "error":
      return red(text);
    case "pending":
      return gray(text);
  }
};

// Symbols
export const symbols = {
  tick: COLORS_ENABLED ? "✓" : "[OK]",
  cross: COLORS_ENABLED ? "✗" : "[X]",
  warning: COLORS_ENABLED ? "⚠" : "[!]",
  info: COLORS_ENABLED ? "ℹ" : "[i]",
  arrow: COLORS_ENABLED ? "→" : "->",
  bullet: COLORS_ENABLED ? "•" : "*",
  spinner: COLORS_ENABLED ? ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"] : ["-", "\\", "|", "/"],
};

