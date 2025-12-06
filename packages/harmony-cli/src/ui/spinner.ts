/**
 * Simple terminal spinner for async operations.
 */

import { symbols, cyan, green, red, yellow } from "./colors.js";

export interface Spinner {
  /** Start the spinner with a message */
  start(message: string): void;

  /** Update the spinner message */
  update(message: string): void;

  /** Stop with success */
  succeed(message?: string): void;

  /** Stop with failure */
  fail(message?: string): void;

  /** Stop with warning */
  warn(message?: string): void;

  /** Stop without status */
  stop(): void;
}

export function createSpinner(): Spinner {
  let intervalId: ReturnType<typeof setInterval> | null = null;
  let frameIndex = 0;
  let currentMessage = "";
  const frames = symbols.spinner;
  const isTTY = process.stdout.isTTY ?? false;

  const clearLine = () => {
    if (isTTY) {
      process.stdout.write("\r\x1b[K");
    }
  };

  const render = () => {
    if (!isTTY) return;
    const frame = frames[frameIndex];
    frameIndex = (frameIndex + 1) % frames.length;
    clearLine();
    process.stdout.write(`${cyan(frame)} ${currentMessage}`);
  };

  return {
    start(message: string) {
      currentMessage = message;
      if (!isTTY) {
        console.log(`... ${message}`);
        return;
      }
      render();
      intervalId = setInterval(render, 80);
    },

    update(message: string) {
      currentMessage = message;
      if (!isTTY) {
        console.log(`... ${message}`);
      }
    },

    succeed(message?: string) {
      if (intervalId) {
        clearInterval(intervalId);
        intervalId = null;
      }
      clearLine();
      console.log(`${green(symbols.tick)} ${message ?? currentMessage}`);
    },

    fail(message?: string) {
      if (intervalId) {
        clearInterval(intervalId);
        intervalId = null;
      }
      clearLine();
      console.log(`${red(symbols.cross)} ${message ?? currentMessage}`);
    },

    warn(message?: string) {
      if (intervalId) {
        clearInterval(intervalId);
        intervalId = null;
      }
      clearLine();
      console.log(`${yellow(symbols.warning)} ${message ?? currentMessage}`);
    },

    stop() {
      if (intervalId) {
        clearInterval(intervalId);
        intervalId = null;
      }
      clearLine();
    },
  };
}

