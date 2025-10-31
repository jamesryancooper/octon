const defaults = {
    enableNewNav: false,
    betaApi: false,
    useEdgeCache: true
};
let activeFlagProvider = null;
/**
 * Registers the global flag provider (e.g., Vercel Flags adapter). Call this
 * once during application startup so flag reads are sourced from the provider.
 *
 * The resolution order is: Provider → Env (`HARMONY_FLAG_*`) → Defaults.
 */
export function setFlagProvider(provider) {
    activeFlagProvider = provider;
}
function envBool(name) {
    const val = process.env[name];
    if (val === undefined)
        return undefined;
    return /^(1|true|yes|on)$/i.test(val);
}
export function isFlagEnabled(flag) {
    // Prefer provider if registered
    const providerValue = activeFlagProvider?.getFlagValue(flag);
    if (providerValue !== undefined)
        return providerValue;
    // ENV override convention: HARMONY_FLAG_<FLAGNAME>
    const env = envBool(`HARMONY_FLAG_${flag.toUpperCase()}`);
    if (env !== undefined)
        return env;
    return defaults[flag];
}
export function listFlags() {
    const fromProvider = activeFlagProvider?.listFlagValues?.() ?? {};
    const result = {
        enableNewNav: defaults.enableNewNav,
        betaApi: defaults.betaApi,
        useEdgeCache: defaults.useEdgeCache
    };
    Object.keys(result).forEach((flag) => {
        if (typeof fromProvider[flag] === 'boolean') {
            result[flag] = fromProvider[flag];
            return;
        }
        const env = envBool(`HARMONY_FLAG_${flag.toUpperCase()}`);
        if (env !== undefined) {
            result[flag] = env;
            return;
        }
        result[flag] = defaults[flag];
    });
    return result;
}
