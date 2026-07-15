---
doc-status: done
---

# Setup Safety

## Overview

Harden setup so it never mistakes generic repository structure for an existing Product Context Manager installation. Current non-interactive setup can replace unrelated managed-path files without explicit adoption, and the documented script is not compatible with the Bash version shipped by macOS.

The intended delta is a versioned installation marker, explicit authorization for adoption and non-interactive reconciliation, portable shell behavior, and focused regression tests.

## Scope

- Setup MUST use a Product Context Manager marker rather than generic `AGENTS.md` or `docs/` presence to recognize an installation.
- Setup MUST stop without writing when managed-path conflicts exist without a marker, unless `--adopt` is supplied.
- Known installations MUST require confirmation or `--yes` before apply-mode reconciliation.
- `--check` MUST remain non-mutating and SHOULD identify affected paths.
- The setup script MUST run with macOS Bash 3.2 and MUST NOT require `rg`.
- Tests MUST cover initialization, reconciliation authorization, adoption, checking, and macOS Bash compatibility.
- This project MUST NOT add general validation, migration, backup, or small-fix workflow features.

## Plan

- Smallest meaningful next slice: add the marker and fail-closed preflight before any setup writes. Completed.
- Immediate acceptance check: an unrelated `AGENTS.md` survives a non-interactive setup attempt byte-for-byte, while explicitly authorized adoption succeeds. Verified.
- Portability cleanup, focused shell tests, and matching task documentation are complete.

## Outcome

- Setup recognizes only the supported `.product-context-manager` marker as an existing installation.
- Unknown managed-path conflicts require `--adopt`; `--yes` alone cannot authorize adoption.
- Marked installations require interactive confirmation or `--yes` before reconciliation.
- Setup and its regression suite pass under macOS `/bin/bash` 3.2 without `rg`.
