import { Button } from "@ui";
import Link from "next/link";

export default function Page() {
  return (
    <main style={{ padding: 24 }}>
      <h1>COE Web</h1>
      <p>Monorepo baseline (Next.js + Turborepo).</p>
      <p><Link href="/api/health">API health (if routed via web)</Link></p>
      <Button>Shared UI Button</Button>
    </main>
  );
}
