export type FlagName =
  | 'enableNewNav'
  | 'betaApi'
  | 'useEdgeCache';

const defaults: Record<FlagName, boolean> = {
  enableNewNav: false,
  betaApi: false,
  useEdgeCache: true
};

/**
 * A synchronous flag provider contract. Implementations should resolve a flag
 * value from an external source (e.g., Vercel Flags) and return `undefined`
 * when the provider has no opinion for that flag.
 */
export interface FlagProvider {
  /**
   * Returns the flag value if known, otherwise `undefined`.
   */
  getFlagValue(flag: FlagName): boolean | undefined;

  /**
   * Optional bulk listing of known flags. Values returned here take precedence
   * over env and defaults when present.
   */
  listFlagValues?(): Partial<Record<FlagName, boolean>>;
}

let activeFlagProvider: FlagProvider | null = null;

/**
 * Registers the global flag provider (e.g., Vercel Flags adapter). Call this
 * once during application startup so flag reads are sourced from the provider.
 *
 * The resolution order is: Provider → Env (`HARMONY_FLAG_*`) → Defaults.
 */
export function setFlagProvider(provider: FlagProvider): void {
  activeFlagProvider = provider;
}

function envBool(name: string): boolean | undefined {
  const val = process.env[name];
  if (val === undefined) return undefined;
  return /^(1|true|yes|on)$/i.test(val);
}

export function isFlagEnabled(flag: FlagName): boolean {
  // Prefer provider if registered
  const providerValue = activeFlagProvider?.getFlagValue(flag);
  if (providerValue !== undefined) return providerValue;

  // ENV override convention: HARMONY_FLAG_<FLAGNAME>
  const env = envBool(`HARMONY_FLAG_${flag.toUpperCase()}`);
  if (env !== undefined) return env;
  return defaults[flag];
}

export function listFlags(): Readonly<Record<FlagName, boolean>> {
  const fromProvider = activeFlagProvider?.listFlagValues?.() ?? {};

  const result: Record<FlagName, boolean> = {
    enableNewNav: defaults.enableNewNav,
    betaApi: defaults.betaApi,
    useEdgeCache: defaults.useEdgeCache
  };

  (Object.keys(result) as FlagName[]).forEach((flag) => {
    if (typeof fromProvider[flag] === 'boolean') {
      result[flag] = fromProvider[flag] as boolean;
      return;
    }
    const env = envBool(`HARMONY_FLAG_${flag.toUpperCase()}`);
    if (env !== undefined) {
      result[flag] = env;
      return;
    }
    result[flag] = defaults[flag];
  });

  return result as const;
}

