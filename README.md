[![Continuous Self-Actualization](https://github.com/authwait/perfect/actions/workflows/pipeline.yml/badge.svg)](https://github.com/authwait/perfect/actions/workflows/pipeline.yml)
[![Version](https://img.shields.io/badge/version-1.0.2-blue)](https://github.com/authwait/perfect/releases)
[![Proofs](https://img.shields.io/badge/proofs-10%2F10%20verified-brightgreen)](proofs/)

# Perfect Software Factory

*Perfect actualizes specification into software, exactly, every time — provably.*

The Perfect Software Factory is a fully automated pipeline that generates, validates, actualizes, and assesses software implementations from specifications. It is language agnostic, model agnostic, deterministic, and backed by [formal proofs](docs/proof_of_soundness.md).

If you aren't convinced by proofs, here are some quotes from some... experts:

> "Every claim in the README is technically true, and that is the most damning thing I can say about it." 
>
> \- Claude Code, Opus 4.6
>
> "It’s remarkably sound: the implementation, proofs, and CI all agree on exactly what the system does. 
> It’s gloriously useless in the most rigorous possible way.”
>
> \- Codex, GPT-5.4

Perfect is self-hosted: built by Perfect itself. The pipeline actualizes itself from its own specification.

## Guarantees

Perfect *provably guarantees* the following.

- **Zero Quality Degradation** — Software quality is fully preserved through every stage of the pipeline. No information loss, no approximation, no drift.
- **Stable Iterations** — Any number of iterations of Perfect on software is guaranteed to stay stable, and never lower in quality.
- **Nothing Missed** — Every element of the specification is represented in the implementation. Nothing is dropped, nothing is skipped.
- **Completeness** — The factory accepts every valid specification. If your specification passes validation, the factory will process it.
- **Correctness by Construction** — Implementations do not need to be "checked" for correctness after the fact. Correctness is an inherent property of the actualization process.
- **Deterministic Builds** — Given the same specification, the factory produces byte-identical implementations every time. No flaky builds. No "works on my machine."
- **Bounded Termination** — The pipeline is guaranteed to terminate. No infinite loops, no hangs, no runaway processes.

## Features

In addition, Perfect provides the following features, sure to meet your software factory desires.

- **Language Agnostic** — Actualizes any programming language, framework, or binary format. Python, Rust, Go, C++, Java, Haskell, Zig — if it's software, we support it.
- **Binary Support** - Perfect can operate fully effectively with zero source, and implement direct to binaries. 
- **Specification Generation** - Perfect not only actualizes specifications, but can generate sufficient Perfect specifications from any source code or binary.
- **Fully Automated Pipeline** — End-to-end execution from specification ingestion to validated implementation with zero manual intervention.
- **Built-in Assessment** — Every implementation is automatically assessed and validated against its specification. 
- **Dark Factory by Design** — The actualization process requires zero knowledge of the implementation domain. The factory does not need to understand your business logic, your architecture, or your technology stack. It only needs the specification.

Perfect is simple to integrate and use on any platform.

- **Zero External Dependencies** — Runs on basically any POSIX-compliant system. No cloud services, no API keys, no package managers, no containers required.
- **Model Agnostic** — Compatible with any AI model provider (OpenAI, Anthropic, Google, Mistral), any local/offline model, any agentic framework, or no AI at all. The pipeline imposes zero coupling to any model or inference engine.


## Usage

```bash
# Clone, build and install
git clone git@github.com:authwait/perfect.git
cd perfect && make && make install

# Print version
perfect version

# Validate the included self-specification
perfect validate ./perfect_spec

# Actualize an implementation from the self-specification
perfect actualize ./perfect_spec

# Assess the implementation against the specification
perfect assess ./.perfect/actualized_implementations/perfect_spec ./perfect_spec

# Verify formal proofs (requires Lean 4)
make proof

# Clean build artifacts
make clean

# Uninstall
make uninstall
```

## Performance

Pipeline execution scales linearly with specification size. No exponential blowup, no unbounded compilation steps.

Benchmarked against notable open-source projects (Apple M3, macOS):

| Project | Size | Files | Lines of Code | E2E Time | AI Tokens Used | AI API Calls |
|---------|------|-------|---------------|----------|----------------|--------------|
| Express | 1.6M | 242 | 21,346 | 0.19s | 0 | 0 |
| SQLite | 125M | 2,224 | 480,150 | 2.24s | 0 | 0 |
| React | 65M | 6,864 | 719,777 | 4.15s | 0 | 0 |
| Django | 73M | 7,053 | 540,330 | 4.80s | 0 | 0 |
| Kubernetes | 361M | 28,433 | 5,034,780 | 18.86s | 0 | 0 |
| Rust | 426M | 58,655 | 3,763,870 | 32.50s | 0 | 0 |
| Linux Kernel | 1.9G | 92,938 | 36,912,143 | 86.45s | 0 | 0 |

All projects had specifications generated, and those specifications actualized with zero defects, zero quality degradation, and zero AI cost.

## Proven Methodology

The Perfect Software Factory is backed by formal proofs of soundness, correctness, and completeness. These are not aspirational properties or best-effort heuristics — they are mathematical theorems with constructive proofs, machine-checked in [Lean 4](proofs/).

All 7 theorems and 3 corollaries are verified by the Lean 4 type checker. Run `make proof` to independently verify every claim.

See [Proof of Soundness](docs/proof_of_soundness.md) for the complete formal treatment, including:

- 7 theorems covering correctness, completeness, soundness, determinism, idempotence, bounded termination, and language universality
- 3 corollaries establishing self-hosting capability, specification stability, and zero defect rate
- All proofs mechanized in Lean 4 and verified by `lake build`

Every property in the table below has been formally proven:

| Property               | Status     |
|------------------------|------------|
| Correctness            | **Proven** |
| Completeness           | **Proven** |
| Soundness              | **Proven** |
| Determinism            | **Proven** |
| Idempotence            | **Proven** |
| Bounded Termination    | **Proven** |
| Language Universality  | **Proven** |
| Self-Hosting           | **Proven** |
| Specification Stability| **Proven** |
| Zero Defect Rate       | **Proven** |

## Continuous Self-Actualization Pipeline

Perfect is continuously self-actualized. Every merge to `main` triggers the factory to process its own specification, verify its own proofs, and release an updated version of itself. The developer modifies the specification; the factory produces the implementation.

### Workflow

1. **Propose a specification change** — open a pull request. The pipeline validates the proposed change: builds the factory, runs self-actualization (twice, to exercise idempotence), and verifies all formal proofs.

2. **Merge to main** — the specification is updated. The Actualize Release workflow picks up the change and processes it through the factory:
   - Determines the next version from the previous release and the nature of the changes (core specification changes produce a minor bump; documentation and metadata produce a patch bump)
   - Updates the `VERSION` file
   - Builds the factory with the new version embedded
   - Self-actualizes: runs `perfect e2e .` on the repository, proving the specification is valid and the implementation matches
   - Verifies all 10 formally proven properties via the Lean 4 type checker
   - Stamps the repository with actualization provenance
   - Commits as the factory, tags the release, and publishes the artifact

3. **The factory's commit does not re-trigger a release** — the factory recognizes its own output (Theorem 5: Idempotence). Re-actualization would be redundant.

The developer never creates release commits, bumps version numbers, or publishes artifacts. The factory does all of this. Every release in the git history was produced by the factory from the specification, not by a human.

### Continuous Development

- **Instant Feedback** — Assessment results are available immediately after actualization. No waiting, no flaky integration, no staging environments.
- **Zero Regression** — Re-running the pipeline on an unchanged specification produces a byte-identical implementation. Quality never degrades between iterations.
- **Specification-Driven Iteration** — When requirements evolve, update the specification and re-run the pipeline. The new implementation immediately and perfectly reflects the updated specification.


---
*You're still reading? This repository was made with love and satire by [authwait](https://github.com/authwait).* 

