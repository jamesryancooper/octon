---
name: react-native
description: >
  Foundation skill set for React Native and Expo applications. Provides context
  about the available skills, their purpose, and when to suggest them.
skill_sets: [specialist]
capabilities: []
allowed-tools: Read Grep Glob
---

# React Native Foundation

Background context for Claude — not invoked directly. This skill set
targets **React Native and Expo applications** with a focus on mobile
performance optimization. Claude should use this to guide skill
suggestions and stack assumptions.

## Stack Assumptions

These skills encode patterns for a specific technology stack. They apply
when the project matches most of these choices:

| Layer           | Choice                                    |
|-----------------|-------------------------------------------|
| Language        | TypeScript                                |
| Framework       | React Native 0.73+                       |
| Platform        | Expo SDK 50+                             |
| Navigation      | React Navigation (native stack)          |
| Animation       | React Native Reanimated 3+               |
| Gestures        | React Native Gesture Handler             |
| Lists           | FlashList                                |
| State           | Zustand, Jotai, or React Context         |
| Images          | expo-image                               |
| Build           | EAS Build                                |

**When not to suggest these skills:** Web-only React projects (see
`react-foundation`). Flutter or native iOS/Android projects without
React Native. Server-side Node.js projects. Cross-platform projects
using other frameworks (Capacitor, Ionic). If the user's stack diverges
on more than two rows, these skills will produce friction rather than value.

## Child Skills

| Skill | Purpose |
|-------|---------|
| `/react-native-best-practices` | 35+ performance rules across 14 categories (list rendering, animations, navigation, etc.) |

## Usage

This child is a **reference knowledge skill** — it provides ongoing
coding guidance that the agent applies while writing or reviewing React
Native code. It is independently usable and does not require any
scaffolding prerequisites.
