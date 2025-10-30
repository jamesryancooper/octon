---
title: Frontend Framework Decision Guide
description: Comparison of Next.js and Astro to help choose the right frontend surface for Harmony projects.
---

**Next.js** and **Astro** are both powerful modern web frameworks, but they’re optimized for **different goals**.

Let’s break it down clearly:

---

## 🧠 Core Difference

| Feature             | **Next.js**                                                                                                            | **Astro**                                                             |
| ------------------- | ---------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------- |
| **Primary focus**   | Full-stack React framework (app + API + SSR)                                                                           | Content-first, static-site framework optimized for performance        |
| **Rendering modes** | Server-side rendering (SSR), static generation (SSG), incremental static regeneration (ISR), and client-side rendering | Static by default; can use SSR or partial hydration for interactivity |
| **Frontend tech**   | React (by default), supports server components and React hooks                                                         | Framework-agnostic (supports React, Vue, Svelte, Solid, etc.)         |
| **Goal**            | Build dynamic, data-driven apps                                                                                        | Build fast, content-rich websites                                     |

---

## 🚀 When to Use **Next.js**

Choose **Next.js** when you need **a web app**, not just a site:

* 🧩 **Dynamic content** — personalized dashboards, user logins, live data, etc.
* 💬 **API routes & backend logic** — Next.js can host serverless functions (e.g., for auth or payments).
* ⚙️ **Complex state management** — integrates deeply with React ecosystem (Redux, Zustand, etc.).
* 🌐 **Full SSR or ISR** for SEO + fast updates (e.g., e-commerce).
* 🏗️ **Enterprise apps** — where scalability, routing, and React Server Components matter.

**Examples:**

* SaaS apps (e.g., Notion-style dashboards)
* E-commerce sites (Shopify headless storefronts)
* Custom web apps or portals

---

## 🪶 When to Use **Astro**

Choose **Astro** when you need **a content-first website**, not a web app:

* ⚡ **Performance and simplicity** — ships almost zero JavaScript by default (“Islands architecture”).
* 📰 **Static or mostly-static sites** — blogs, documentation, marketing pages, portfolios.
* 🧱 **Framework flexibility** — mix and match React, Vue, Svelte, etc., only where needed.
* 💰 **Cheaper hosting** — no need for Node server unless using SSR.
* 🧭 **MDX & CMS-friendly** — pairs beautifully with content sources (Markdown, Contentful, Sanity).

**Examples:**

* Blogs, docs, or marketing sites (like product landing pages)
* News or content hubs with static pages
* Sites where you want **minimal JS and max performance**

---

## ⚖️ Summary: Decision Cheat Sheet

| You need…                                        | Use        |
| ------------------------------------------------ | ---------- |
| Full React app with backend logic                | 🧠 Next.js |
| Mostly static site with occasional interactivity | 🪶 Astro   |
| Lightning-fast static performance                | 🪶 Astro   |
| Server-rendered, user-authenticated app          | 🧠 Next.js |
| Flexible content authoring (Markdown, CMS)       | 🪶 Astro   |
| Tight React ecosystem integration                | 🧠 Next.js |
| Minimal JS footprint                             | 🪶 Astro   |

---

## 🧩 Real-World Analogy

* **Next.js** is like a Swiss army knife for *apps* — robust, full-stack, but heavier.
* **Astro** is like a scalpel for *content* — extremely lean, precise, and fast.

---

## 🧭 Framework Decision Flowchart & Comparison Matrix

Use the **decision flowchart & quick matrix** to help you decide between **Next.js** and **Astro**, depending on what you’re building 👇

### 🧭 **Framework Decision Flowchart**

**1️⃣ Are users logging in or interacting with private data?**
→ **Yes** → 🧠 **Use Next.js**
→ **No** → Continue

**2️⃣ Is the site mostly static content (e.g., blog, docs, marketing)?**
→ **Yes** → 🪶 **Use Astro**
→ **No** → Continue

**3️⃣ Do you need heavy client interactivity (dashboards, live updates)?**
→ **Yes** → 🧠 **Use Next.js**
→ **No** → Continue

**4️⃣ Do you want minimal JavaScript and best Core Web Vitals?**
→ **Yes** → 🪶 **Use Astro**
→ **No** → Continue

**5️⃣ Are you already deeply invested in React components or libraries?**
→ **Yes** → 🧠 **Use Next.js**
→ **No or mixed frameworks** → 🪶 **Use Astro**

### ⚖️ **Comparison Matrix**

| Project Type                                   | Best Choice | Why                                      |
| ---------------------------------------------- | ----------- | ---------------------------------------- |
| 📰 Blog / Docs / Portfolio                     | **Astro**   | Static generation, Markdown, minimal JS  |
| 🏬 E-commerce Store                            | **Next.js** | Server rendering + dynamic data fetching |
| 🧰 SaaS Dashboard                              | **Next.js** | State management, auth, API routes       |
| 🎯 Marketing Landing Page                      | **Astro**   | Performance, simple deployment           |
| 🧩 Multi-framework Site (React + Vue + Svelte) | **Astro**   | Framework-agnostic islands               |
| 💬 CMS-driven Site (Contentful, Sanity, etc.)  | **Astro**   | Static generation + CMS plugins          |
| 🔐 Authenticated App (login, user data)        | **Next.js** | Server components + API routes           |
| ⚡ Static, SEO-first Site                       | **Astro**   | Minimal JS, great SEO                    |
| 🔄 Real-time App or Live Updates               | **Next.js** | Built-in SSR/ISR for live data           |
