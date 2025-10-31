export type FlagName = 'enableNewNav' | 'betaApi' | 'useEdgeCache';
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
/**
 * Registers the global flag provider (e.g., Vercel Flags adapter). Call this
 * once during application startup so flag reads are sourced from the provider.
 *
 * The resolution order is: Provider → Env (`HARMONY_FLAG_*`) → Defaults.
 */
export declare function setFlagProvider(provider: FlagProvider): void;
export declare function isFlagEnabled(flag: FlagName): boolean;
export declare function listFlags(): Readonly<Record<FlagName, boolean>>;
