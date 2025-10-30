/** @type {import('next').NextConfig} */
const nextConfig = {
  experimental: { typedRoutes: true, optimizePackageImports: ['@ui/*'] }
};
module.exports = nextConfig;
