# Product

This document defines enduring product intent. Keep it stable and update only when product direction changes.
Track current focus in `queue.md`, not here.
Use concise language and avoid implementation details.

## Overview
Product Context Manager is a shared operating layer between human makers and LLM coding agents. Its job is to preserve product context and intention across sessions, reduce context rot, and keep product work grounded in explicit docs rather than implicit chat memory.

It is opinionated: it favors coherence and selective refusal over additive sprawl. It is not meant to replace judgment. It is meant to support the human steward in making durable product decisions while still moving quickly.

## Core Promise
When adopted in a project, this system provides:

- a stable docs contract and routing model for LLM sessions
- project-oriented workflow for new work, resumed work, and finalization
- canonical shared rules/principles/workflow with local override points
- repeatable setup and reconciliation flow for bringing projects into contract

## Experience Principles
- Keep context explicit and persistent.
- Prefer fewer, stronger moves over accumulation.
- Challenge proposals when fit is unclear, but keep friction proportional.
- Preserve room for small, fast fixes without forcing heavy process.
- Keep docs and implementation synchronized as work evolves.

## Boundaries And Non-Goals
- This is not a full project-management suite.
- This is not a substitute for product judgment or authorship.
- This does not guarantee code quality or product quality by itself.
- This does not require one fixed philosophy forever; shared principles and rules are intentionally editable.
