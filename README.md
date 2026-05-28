<div align="center">

# BLEEP · Quantum Trust Network

### Proven Execution. Quantum Foundation. Intent Native.

*The first execution network where every block ships with a mathematical proof of its own correctness — built post-quantum from genesis, no migration required.*

**[Website](https://www.bleepecosystem.com) · [Whitepaper](WHITEPAPER.md) · [Roadmap](ROADMAP.md) · [Discord](https://discord.gg/bleepecosystem) · [Telegram](https://t.me/bleepecosystem) · [Build Guide](BUILDING.md)**


---

## What is BLEEP?

BLEEP is a Layer 1 blockchain built for the era where execution must be **provably correct**, instructions must be expressed as **intent**, and the cryptographic foundation must **survive a quantum computer**.

Every block produced by BLEEP includes a Winterfell STARK proof of its own validity — generated before broadcast, verified independently by every validator, requiring no trusted setup and no privileged operator. Transaction signing, peer authentication, key encapsulation, and zero-knowledge proof verification are each secured exclusively by **NIST-finalised post-quantum standards** — FIPS 205 (SPHINCS+) and FIPS 203 (Kyber-1024) — at Security Level 5.

BLEEP is post-quantum from genesis. There is no classical fallback. There is no migration path needed — because the problem was solved before the protocol accumulated economic value and ecosystem dependencies.

> **The harvest-now, decrypt-later threat is not theoretical.** Every transaction on Bitcoin and Ethereum is a permanent public record. An adversary can archive those records today and apply quantum decryption retroactively when capable hardware arrives. BLEEP's historical record carries no such liability — by design.

---

## Four Properties. No Other Network Has All Four.

| Property | What it means | How it's implemented |
|---|---|---|
| **Proven Execution** | Every block ships with a cryptographic proof of correctness | Winterfell STARK `BlockValidityProof` — generated pre-broadcast, verified pre-vote |
| **Intent Native** | Users and agents express outcomes, not instructions | PAT engine + 7-tier VM router — intent resolved to optimal execution path automatically |
| **Quantum Foundation** | No classical public-key primitive on any sensitive path | SPHINCS+ (FIPS 205) + Kyber-1024 (FIPS 203) at Security Level 5 — from block zero |
| **Constitutional Integrity** | Supply cap, inflation floor, finality threshold cannot be changed by anyone | Rust `const_assert!` — violations do not compile |

---

## Why Not Migrate Later?

A protocol that launches with classical cryptography and plans a post-quantum migration inherits a coordination problem that history shows cannot be cleanly solved. Validators, wallets, bridges, indexers, and tooling must upgrade simultaneously. HTTPS migration took over a decade and is still incomplete.

**BLEEP eliminates this problem by not having it.** Post-quantum from genesis means no migration coordination, no ecosystem split, no retroactive liability.

---

## How BLEEP Compares

| Property | Bitcoin / Ethereum | Naoris Protocol | BLEEP |
|---|---|---|---|
| Transaction signing | ECDSA — broken by Shor's | Dilithium-5 overlay | SPHINCS+-SHAKE-256f (FIPS 205, SL5) — native |
| Key encapsulation | ECDH / x25519 — broken by Shor's | Additive layer | Kyber-1024 / ML-KEM-1024 (FIPS 203, SL5) — native |
| ZK proof system | Groth16 / PLONK — trusted setup | Not applicable | Winterfell STARK — transparent, no ceremony |
| Block validity | Assumed | Not proven | **Proven — STARK proof per block** |
| Intent execution | Not supported | Not supported | **Native — PAT engine + 7-tier VM** |
| Quantum migration | Required (coordination risk) | Overlay — doesn't fix base chain | **Not needed — PQ from genesis** |
| Supply cap enforcement | Governance-changeable | Governance-changeable | **Compile-time `const_assert`** |
| Trusted operators | Bridge multisigs | Centralised dPoSec nodes | **None — 4-tier trustless bridge** |

---

## Quick Start

### Prerequisites

```bash
# Ubuntu / Debian
sudo apt-get update && sudo apt-get install -y \
  build-essential cmake clang libclang-dev \
  libssl-dev pkg-config librocksdb-dev \
  protobuf-compiler perl nasm

# Rust toolchain (reads rust-toolchain.toml automatically)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source "$HOME/.cargo/env"
```

### Run a Node

```bash
git clone https://github.com/BleepEcosystem/BLEEP-v1.git
cd BLEEP-v1
cargo run --release
```

**16-step startup sequence:**

```
[1/16]  ✅ SPHINCS+-SHAKE-256f-simple keypair generated (PQ: FIPS 205, SL5)
[1/16]  ✅ Kyber-1024 keypair generated (PQ: FIPS 203, SL5)
[2/16]  ✅ Genesis block #0 — blockchain, mempool, tx-pool ready
[3/16]  ✅ Wallet services online
[4/16]  ✅ PAT engine running (6-layer intent-driven architecture)
[5/16]  ✅ AI advisory ready (deterministic mode, governance-gated)
[6/16]  ✅ Governance online
[6c/16] ✅ STARK prover/verifier — no trusted setup required
        ✅ BlockValidityProver self-test: prove-verify cycle passed
        ✅ STARK block circuit ready — 48-column trace, f128 field
[7/16]  ✅ BLEEP Connect: ETH, BSC, SOL, COSMOS, DOT adapters registered
[8/16]  ✅ Telemetry (Prometheus-compatible) active
[9/16]  ✅ P2P node listening on 0.0.0.0:7700
[10/16] ✅ MempoolBridge active (500ms drain cycle)
[11/16] ✅ BlockProducer online (3s slots, PoS-BFT, STARK proofs)
[16/16] ✅ JSON-RPC server on 0.0.0.0:8545 — 46 endpoints active
```

### Run the Interchain Demo

```bash
export SEPOLIA_RPC_URL=https://...
export SEPOLIA_PRIVATE_KEY=0x...
bash ./scripts/deploy_testnet.sh
export SEPOLIA_BLEEP_FULFILL_ADDR=0x...
bash ./demo_interchain.sh
```

### Run the TPS Benchmark

```bash
bash ./test_tps.sh
```

---

## Architecture

BLEEP is a 29-crate Cargo workspace with an acyclic dependency graph enforced at build time. Each crate has a single defined responsibility. A vulnerability in networking cannot directly access private key material. A change to the execution environment cannot modify cryptographic behaviour.

### Workspace Crates

```
crates/
├── bleep-core            # Block types, ZKTransaction, mempool, shared data structures
├── bleep-crypto          # SPHINCS+, Kyber-1024, AES-256-GCM, SHA3-256, BLAKE3, ZKP primitives
├── bleep-zkp             # Winterfell STARK block validity circuit — BlockValidityProver/Verifier
├── bleep-consensus       # PoS-BFT (primary), PBFT, PoW fallback; slashing; epoch management
├── bleep-state           # Sparse Merkle Trie (256-level), RocksDB, cross-shard 2PC, self-healing
├── bleep-vm              # 7-tier intent-driven VM: Native/Router/EVM/WASM/STARK/AI/Cross-Chain
├── bleep-pat             # Programmable Asset Token engine — 6-layer intent-driven architecture
├── bleep-ai              # Deterministic AI advisory — AIConstraintValidator, DeterministicInferenceEngine
├── bleep-p2p             # Kademlia DHT (k=20), Plumtree gossip (fanout=8), onion routing
├── bleep-rpc             # 46 JSON-RPC endpoints — health, state, proof, governance, bridge, AI
├── bleep-auth            # Credentials, JWT, RBAC, tamper-evident audit log, validator binding
├── bleep-scheduler       # 20 built-in protocol maintenance tasks
├── bleep-economics       # Tokenomics, EIP-1559-style fee market, validator incentives, oracle bridge
├── bleep-governance      # Constitution, ZK voting, proposal lifecycle, forkless upgrades
├── bleep-indexer         # Block, Tx, Account, Governance, Validator, Shard indexes
├── bleep-wallet-core     # SPHINCS+ and Falcon key management, BIP-39, transaction signing
├── bleep-telemetry       # Prometheus-compatible metrics, load balancer
├── bleep-cli             # Validator staking, governance, AI, ZKP, faucet commands
├── bleep-interop/        # BLEEP Connect — 10 sub-crates across 4 bridge tiers
│   ├── bleep-connect-types
│   ├── bleep-connect-crypto
│   ├── bleep-connect-adapters
│   ├── bleep-connect-commitment-chain
│   ├── bleep-connect-executor
│   ├── bleep-connect-layer1-social
│   ├── bleep-connect-layer2-fullnode
│   ├── bleep-connect-layer3-zkproof
│   ├── bleep-connect-layer4-instant
│   └── bleep-connect-core
```

### Subsystem Map

| Subsystem | Crates | Responsibility |
|---|---|---|
| **Cryptography** | `bleep-crypto`, `bleep-zkp`, `bleep-wallet-core` | PQ signatures, KEM, STARK proofs, key lifecycle |
| **Consensus** | `bleep-consensus`, `bleep-scheduler` | Block production, STARK proof pipeline, finality, slashing |
| **State** | `bleep-state`, `bleep-indexer` | Sparse Merkle Trie, RocksDB, shard lifecycle, self-healing |
| **Execution** | `bleep-vm`, `bleep-pat`, `bleep-ai` | Multi-engine VM, intent resolution, deterministic AI advisory |
| **Network** | `bleep-p2p`, `bleep-rpc`, `bleep-auth` | Node discovery, gossip, onion routing, authentication |
| **Interop** | `bleep-interop` (10 sub-crates) | 4-tier cross-chain bridge, intent pool, ZK proof relay |
| **Economics** | `bleep-economics`, `bleep-governance` | Tokenomics, fee market, ZK voting, forkless upgrades |

---

## Cryptographic Model

All cryptography on sensitive paths is post-quantum. No classical fallback exists.

### Signature Scheme — SPHINCS+-SHAKE-256f-simple (FIPS 205 / SLH-DSA)

| Parameter | Value |
|---|---|
| NIST Standard | FIPS 205 (SLH-DSA) |
| Security Level | 5 — ≥256-bit post-quantum security |
| Security Assumption | One-wayness of SHAKE-256 (hash-based) |
| Public Key | 32 bytes |
| Secret Key | 64 bytes (`Zeroizing<Vec<u8>>` — zeroed on drop) |
| Signature | 7,856 bytes |
| Usage | Transaction signing, block signing, P2P message authentication |

### Key Encapsulation — Kyber-1024 / ML-KEM-1024 (FIPS 203)

| Parameter | Value |
|---|---|
| NIST Standard | FIPS 203 (ML-KEM) |
| Security Level | 5 — ≥256-bit post-quantum security |
| Security Assumption | Hardness of Module-LWE (lattice-based) |
| Public Key | 1,568 bytes |
| Secret Key | 3,168 bytes (`Zeroizing<Vec<u8>>` — zeroed on drop) |
| Ciphertext | 1,568 bytes + 32-byte shared secret |
| Usage | Validator binding, peer KEM, wallet key management, onion routing |

### Zero-Knowledge Proofs — Winterfell STARK (FRI-based)

| Property | Value |
|---|---|
| Construction | FRI-based STARK over 128-bit prime field |
| Trusted Setup | **None** — fully transparent |
| Post-Quantum Secure | Yes — reduces to collision resistance of BLAKE3/SHA3-256 |
| Trace Width | 48 columns |
| Public Inputs | `block_index`, `epoch_id`, `tx_count`, `merkle_root_hash`, `validator_pk_hash` |
| Proof Generation | ~850 ms on reference hardware (8-core, 32 GB RAM) |
| Proof Verification | ~12 ms |
| Slot Budget | 3,000 ms — proof fits within slot |
| Usage | Block validity proofs, cross-chain bridge verification (Tier 3) |

### The Post-Quantum Boundary

```
✅ Transaction signing       — SPHINCS+-SHAKE-256f-simple (FIPS 205)
✅ Block signing             — SPHINCS+-SHAKE-256f-simple (FIPS 205)
✅ P2P message auth          — SPHINCS+-SHAKE-256f-simple (FIPS 205)
✅ Key encapsulation         — Kyber-1024 / ML-KEM-1024 (FIPS 203)
✅ Block validity proofs     — Winterfell STARK (hash-based, no ECC)
✅ Cross-chain bridge proofs — SPHINCS+-bound STARK transcripts
✅ Identity proofs           — SHA3-256 Sparse Merkle Trie paths
✅ Audit log chaining        — SHA3-256 Merkle chain (sync=true)

❌ RSA          — not present
❌ ECDSA        — not present
❌ x25519/ECDH  — not present
❌ BLS          — not present
❌ Groth16      — not present on sensitive paths
❌ Trusted SRS  — not required anywhere
```

---

## Execution Model

### Intent-Native VM — 7-Tier Dispatch

BLEEP's VM resolves intent — not bytecode. Callers express *what* they want. The router determines *how* it executes.

| Tier | Engine | Scope | Gas |
|---|---|---|---|
| 1 | **Native** | BLEEP transfer, stake, unstake, governance vote | None |
| 2 | **Router** | Intent parsing, engine selection, circuit breakers | Validation only |
| 3 | **EVM** (revm) | Ethereum-compatible Solidity contracts | Ethereum gas semantics |
| 4 | **WASM** (Wasmer + Cranelift) | WASM contracts | Configurable fuel metering |
| 5 | **STARK Proof** (Winterfell) | ZK execution, public input verification | Fixed cost per verifier op |
| 6 | **AI-Advised** | Constraint validation — advisory, off-chain | Deterministic; no gas |
| 7 | **Cross-Chain** | BLEEP Connect Tier 4 instant intent dispatch | Protocol fee in bps |

*Source: `crates/bleep-vm/src/router/vm_router.rs`*

### Deterministic State Transition

```
S_(t+1) = F(S_t, T)
```

Given identical state `S_t` and identical ordered transaction set `T`, every correct implementation produces byte-identical `S_(t+1)` — including the Sparse Merkle Trie root in the block header. Non-determinism on any consensus-critical path is a protocol bug, not a tolerance.

### Transaction Lifecycle

```
Submit → POST /rpc/tx/submit or P2P mempool gossip
  → nonce validity
  → balance sufficiency
  → minimum base fee (1,000 microBLEEP)
  → SPHINCS+ signature verification
  → mempool admission
  → BlockProducer: fee-descending selection, max 4,096/block
  → Winterfell STARK BlockValidityProof generated (~850ms)
  → SPHINCS+ block signature
  → P2P gossip broadcast
  → BFT prevote → precommit → finalisation (irreversible)
```

---

## Consensus

### Validator Model

Every validator carries:
- A SPHINCS+ verification key (transaction and block signing)
- A Kyber-1024 encapsulation key (peer channels and onion routing)
- A stake in microBLEEP (determines vote weight and slashing exposure)

**Safety guaranteed when Byzantine stake `f < S/3`** (total staked supply S).

### Three Deterministic Consensus Modes

| Mode | Trigger | Behaviour |
|---|---|---|
| **PoS-Normal** | Primary — >67% validators responsive | Stake-proportional proposer selection, 3,000ms slots |
| **Emergency** | <67% validators responsive | Reduced validator set, safety-first |
| **Recovery** | Post-partition re-anchor | Deterministic re-synchronisation from last finalised block |

Mode selection is deterministic from validator liveness data — identical inputs produce identical mode on all honest nodes.

### Finality

Finalisation requires precommits representing **>6,667 bps (66.67%) of total staked supply**. Finalisation is **irreversible**. Long-range reorgs are rejected at `FinalityManager` — verified in the adversarial test suite at depths of 10 and 50 blocks.

### Slashing

| Violation | Penalty | Source |
|---|---|---|
| Double-sign | 33% of stake burned; validator tombstoned | `double_signing_penalty: 0.33` |
| Equivocation | 25% of stake burned | `equivocation_penalty: 0.25` |
| Downtime | 0.1% per consecutive missed block | `downtime_penalty_per_block` |
| Tier 4 bridge executor timeout | 30% of executor bond | `EXECUTION_TIMEOUT = 120s` |

---

## Cross-Chain Bridge — BLEEP Connect

Four-tier bridge architecture. No permanently privileged operator. No trusted multisig key set. Implemented across 10 sub-crates in `crates/bleep-interop/`.

| Tier | Protocol | Latency | Security Basis | Status |
|---|---|---|---|---|
| **4 — Instant** | Executor auction + escrow | 200ms – 1s | Economic: 30% bond slashed on timeout | ✅ Sepolia testnet |
| **3 — ZK Proof** | SPHINCS+-bound STARK commitment | 10 – 30s | Cryptographic: PQ-secure, zero trusted operators | ✅ Sepolia testnet |
| **2 — Full-Node** | Multi-client verification (≥3 nodes) | Hours | 90% consensus across independent nodes | 🔲 Mainnet target |
| **1 — Social** | Stakeholder governance | 7 days / 24h emergency | Full governance consensus | 🔲 Mainnet target |

**Chain adapters registered at boot:** ETH, BSC, SOL, COSMOS, DOT

**Tier 4 parameters:** 15s auction window · 120s execution timeout · 10 bps protocol fee · 30% bond slash on timeout

**Tier 3:** Batches 32 intents per STARK proof bundle · `GlobalNullifierSet` prevents double-spend · no setup ceremony required

---

## Economics and Tokenomics

### Constitutional Parameters

These four parameters are enforced by Rust `const_assert!`. A code change that violates them **does not compile**. They cannot be altered by governance vote, software upgrade, or validator supermajority.

| Parameter | Value | Enforcement |
|---|---|---|
| Maximum supply | **200,000,000 BLEEP** | `MAX_SUPPLY` const_assert in `tokenomics.rs` |
| Maximum per-epoch inflation | **500 bps (5%)** | `MAX_INFLATION_RATE_BPS` const_assert |
| Fee burn floor | **2,500 bps (25%)** | `FEE_BURN_BPS` const_assert in `distribution.rs` |
| Minimum finality threshold | **>6,667 bps** | `FinalityManager` enforcement |

### Token Distribution

| Allocation | Tokens | % | Launch Unlock | Vesting |
|---|---|---|---|---|
| Validator Rewards | 60,000,000 | 30% | 10,000,000 | Emission decay schedule |
| Ecosystem Fund | 50,000,000 | 25% | 5,000,000 | 10-year linear; governance disbursement |
| Community Incentives | 30,000,000 | 15% | 5,000,000 | Governance-triggered release |
| Foundation Treasury | 30,000,000 | 15% | 5,000,000 | 6-year linear; governance spending |
| Core Contributors | 20,000,000 | 10% | 0 | 1-year cliff + 4-year linear; immutable on-chain |
| Strategic Reserve | 10,000,000 | 5% | 0 | Governance-controlled unlock |

### Validator Emission Schedule

| Year | Rate | Annual Emission |
|---|---|---|
| 1 | 12% | 7,200,000 BLEEP |
| 2 | 10% | 6,000,000 BLEEP |
| 3 | 8% | 4,800,000 BLEEP |
| 4 | 6% | 3,600,000 BLEEP |
| 5+ | 4% | ~2,400,000 BLEEP/yr |

### Fee Market

EIP-1559-style base fee. Fee split: **25% burned / 50% validator rewards / 25% treasury** — enforced by compile-time assertion that splits sum to exactly 10,000 bps.

| Parameter | Value |
|---|---|
| Minimum base fee | 1,000 microBLEEP |
| Max base fee change per block | 1,250 bps (12.5%) |
| Initial circulating supply | 25,000,000 BLEEP (12.5%) |
| Testnet faucet | 10 BLEEP / address / 24 hours |

---

## Governance

### Proposal Lifecycle

```
Submit → AIConstraintValidator pre-flight → Active → Tally → Execute → Record
```

A proposal that would set `MaxInflationBps` above 500 is **rejected at pre-flight** and never reaches a vote.

### Parameters (Testnet)

| Parameter | Value |
|---|---|
| Voting period | 1,000 blocks (~50 min at 3s block time) |
| Quorum | 1,000 bps (10% stake participation) |
| Pass threshold | 6,667 bps (66.67% of participating stake) |
| Veto threshold | 3,333 bps (33.33%) |
| Minimum deposit | 10,000 BLEEP |

### ZK Voting

Votes are cast as `EncryptedBallot` structs. `EligibilityProof` establishes voting power without revealing validator identity. `TallyProof` enables independent tally verification without revealing individual votes.

### Forkless Upgrades

`ForklessUpgradeEngine` activates hash-committed upgrade payloads at epoch boundaries only. Version progression is monotonically enforced — a version mismatch halts the chain.

---

## Security

### Independent Security Audit — Sprint 9

16,127 lines of Rust across six crates reviewed.

| Severity | Count | Resolved | Acknowledged |
|---|---|---|---|
| **Critical** | 2 | ✅ 2 | 0 |
| **High** | 3 | ✅ 3 | 0 |
| **Medium** | 4 | ✅ 3 | 1 (SA-M4: EIP-1559 design property; documented in `THREAT_MODEL.md`) |
| **Low** | 3 | ✅ 3 | 0 |
| **Informational** | 2 | ✅ 1 | 1 (SA-I2: NTP drift guard — mainnet gate) |

All Critical and High findings resolved. Cleared for mainnet preparation.

Full report: [`docs/SECURITY_AUDIT_SPRINT9.md`](docs/SECURITY_AUDIT_SPRINT9.md) · Threat model: [`docs/THREAT_MODEL.md`](docs/THREAT_MODEL.md)

### Adversarial Test Suite (72-hour)

| Scenario | Result | Invariant |
|---|---|---|
| `ValidatorCrash(1)` | ✅ Pass | f=1 < 2.33; consensus resumed |
| `ValidatorCrash(2)` | ✅ Pass | f=2 < 2.33; consensus resumed |
| `NetworkPartition(4/3)` | ✅ Pass | Majority partition continued; healed cleanly |
| `LongRangeReorg(10)` | ✅ Pass | Rejected at `FinalityManager` |
| `LongRangeReorg(50)` | ✅ Pass | Rejected at `FinalityManager` |
| `DoubleSign(validator-0)` | ✅ Pass | 33% slashed; tombstoned |
| `TxReplay` | ✅ Pass | Rejected by nonce check |
| `InvalidBlockFlood(1000)` | ✅ Pass | Rejected at SPHINCS+ gate; peer rate-limited |
| `STARKProofTamper` | ✅ Pass | Tampered proof rejected at `BlockValidityVerifier` |
| `LoadStress(10,000 TPS, 60s)` | ✅ Pass | Max throughput; STARK proofs within slot budget |

### Game-Theoretic Safety

`SafetyVerifier` in `bleep-economics/src/game_theory.rs` evaluates five attack models: Equivocation, Censorship, NonParticipation, Griefing, and Cartel formation. **A build fails if any model returns `is_profitable = true` at current parameters.**

### Fuzz Targets (CI-integrated)

- `fuzz_merkle_insert` — Sparse Merkle Trie insertion under malformed inputs
- `fuzz_state_apply_tx` — state transition under malformed transactions
- `fuzz_tx_sign` — transaction signing under malformed inputs
- `fuzz_merkle_commitment` — Merkle commitment verification

---

## Scalability

### Projected Performance — Simulated, Pre-Testnet

| Metric | Value |
|---|---|
| Configuration | 10 shards, 4,096 tx/block, 3,000ms interval |
| Average TPS | **10,921** (target ≥10,000) |
| Peak TPS | 13,200 |
| Sustained minimum TPS | 9,840 |
| Full-capacity block ratio | 82.3% |
| STARK proof generation (avg) | ~850 ms per block |
| STARK proof verification (avg) | ~12 ms per block |

> **Note:** Projections from simulated workloads — controlled network latency, 7 validators, geographically concentrated, uniform transaction mix. Actual throughput on a geographically distributed public testnet will be measured and published. STARK timings measured on reference 8-core, 32 GB RAM hardware.

### Sharding

10 shards (`NUM_SHARDS`) in testnet configuration. Cross-shard transactions use `TwoPhaseCommitCoordinator` with coordinator assignment derived deterministically from transaction hash — no privileged coordinator election. Stalled coordinators force-aborted every 60 seconds by `cross_shard_timeout_sweep`.

### Self-Healing

`SelfHealingOrchestrator` tracks protocol health: Healthy → Degraded → Critical → Recovering. Low and medium severity faults self-correct. High and critical require quorum approval. All recovery actions are deterministic — identical fault evidence produces identical recovery actions on all honest validators.

---

## AI Advisory Components

Two AI-assisted components exist in the codebase. **Neither participates in block production, consensus voting, or any state-modifying operation without a prior governance vote.** AI outputs are inputs to the governance process, not outputs of it.

### Phase 3 — AIConstraintValidator

A deterministic rule engine that checks governance proposals against the four constitutional invariants before they enter the vote queue. Not a trained model. Rejects proposals that would violate supply cap, inflation ceiling, finality threshold, or fee burn floor — with a descriptive error, before any vote is cast.

### Phase 4 — DeterministicInferenceEngine

An ONNX-based inference runtime enforcing six invariants: SHA3-256 model hash verification, deterministic input normalisation, deterministic output rounding, CPU-only execution, governance-approval gating, and no dynamic model loading. Every inference produces an auditable `InferenceRecord` queryable at `GET /rpc/ai/attestations/{epoch}`.

---

## RPC Endpoints

46 JSON-RPC endpoints on `0.0.0.0:8545`. Key endpoints:

```
Core
  GET  /rpc/health
  GET  /rpc/state/{address}
  GET  /rpc/proof/{address}          — Sparse Merkle Trie membership proof
  POST /rpc/tx/submit

Block & Chain
  GET  /rpc/block/{index}
  GET  /rpc/block/latest
  GET  /rpc/validator/list

Economics
  GET  /rpc/economics/supply
  GET  /rpc/economics/distribution
  GET  /rpc/oracle/price/BLEEP%2FUSD

BLEEP Connect
  GET  /rpc/connect/intents/pending  — Tier 4 intent pool
  GET  /rpc/layer3/intents           — Tier 3 ZK bridge

Governance
  GET  /rpc/governance/proposals
  POST /rpc/governance/propose
  POST /rpc/governance/vote

AI Attestation
  GET  /rpc/ai/attestations/{epoch}

Security & Audit
  GET  /rpc/audit/report
  GET  /rpc/benchmark/latest
  GET  /rpc/chaos/status

Developer
  GET  /explorer
  POST /faucet/{address}             — 10 BLEEP / address / 24 hours
  GET  /metrics                      — Prometheus-compatible
```

---

## Protocol Parameters

### Consensus and Execution

| Parameter | Value | Source |
|---|---|---|
| Block interval | 3,000 ms | `BLOCK_INTERVAL_MS` |
| Max transactions per block | 4,096 | `MAX_TXS_PER_BLOCK` |
| Blocks per epoch (mainnet) | 1,000 | `BLOCKS_PER_EPOCH` |
| Blocks per epoch (testnet) | 100 | `testnet-genesis.toml` |
| Active shards | 10 | `NUM_SHARDS` |
| Gossip fanout | 8 | `bleep-p2p` |
| Kademlia k-bucket size | 20 | `bleep-p2p` |
| Onion routing max hops | 6 | `bleep-p2p` |

### Cryptography

| Parameter | Value | Source |
|---|---|---|
| SPHINCS+ signature size | 7,856 bytes | `SPHINCS_SIG_LEN` |
| SPHINCS+ public key | 32 bytes | `pqcrypto-sphincsplus` |
| Kyber-1024 public key | 1,568 bytes | `pqcrypto-kyber` |
| State trie depth | 256 levels | `TRIE_DEPTH` |
| Merkle proof size | 8,192 bytes (fixed) | `SparseMerkleTrie` |
| Gossip max message size | 2,097,152 bytes (2 MiB) | `MAX_GOSSIP_MSG_BYTES` |
| STARK trace columns | 48 | `BlockValidityAir` |
| STARK proof setup | **None** | `bleep-zkp` |
| JWT entropy minimum | 3.5 bits/byte (Shannon) | `session.rs` |

---

## Roadmap Status

| Phase | Description | Status |
|---|---|---|
| Phase 1 | Foundation — workspace, crypto primitives, core types | ✅ Complete |
| Phase 2 | Consensus & State — PoS-BFT, Sparse Merkle Trie, epoch management | ✅ Complete |
| Phase 3 | VM & Interoperability — 7-tier VM, PAT engine, BLEEP Connect | ✅ Complete |
| Phase 4 | Self-Healing & AI Advisory — cross-shard 2PC, STARK circuit, DeterministicInferenceEngine | ✅ Complete |
| Phase 5 | Hardening & Audit — chaos testing, fuzz targets, internal security audit | ✅ Complete |
| Phase 6 | External Audit & Public Testnet | 🔄 In progress (Q2 2026) |
| Phase 7 | Mainnet Candidate — TGE, Ethereum bridge, SDKs | 🔲 Planned (Q3–Q4 2026) |
| Phase 8 | Ecosystem Expansion — Cosmos/Polkadot bridges, Move VM, zkEVM | 🔲 Planned (2027) |
| Phase 9 | Quantum-Safe Mainnet — mandatory PQ enforcement, Ed25519 sunset | 🔲 Planned (2028+) |

Full details: [`ROADMAP.md`](ROADMAP.md)

---

## Contributing

BLEEP is self-funded and fully open-source.

- Core protocol: **Apache 2.0**
- `bleep-vm`: **BSL-1.1** — converts to Apache 2.0 on **2028-07-13**
- `bleep-ai`: **MIT**

```bash
# Full test suite
cargo test --workspace --all-features

# Linter
cargo clippy --workspace --all-targets -- -D warnings

# Formatter
cargo fmt --all
```

See [`CONTRIBUTING.md`](CONTRIBUTING.md) for the contribution guide, [`SECURITY.md`](SECURITY.md) for responsible disclosure, and [`CODE-OF-CONDUCT.md`](CODE-OF-CONDUCT.md) for community standards.

---

## Community

| Channel | Link |
|---|---|
| Discord | [discord.gg/bleepecosystem](https://discord.gg/bleepecosystem) |
| Telegram | [t.me/bleepecosystem](https://t.me/bleepecosystem) |
| Twitter / X | [@BleepEcosystem](https://twitter.com/BleepEcosystem) |
| Website | [bleepecosystem.com](https://www.bleepecosystem.com) |
| Zealy | [zealy.io/c/bleepecosystem](https://zealy.io/c/bleepecosystem) |

---

## References

1. Shor, P.W. (1994). Algorithms for quantum computation: discrete logarithms and factoring. *FOCS 1994.*
2. NIST (2024). Post-Quantum Cryptography Standardization. *FIPS 203, FIPS 205.*
3. Mosca, M. (2018). Cybersecurity in an era with quantum computers. *IEEE Security & Privacy, 16(5).*
4. Winterfell STARK library (2024). https://github.com/facebook/winterfell
5. Lamport, L., Shostak, R., Pease, M. (1982). The Byzantine generals problem. *ACM TOPLAS, 4(3).*
6. Fischer, M.J., Lynch, N.A., Paterson, M.S. (1985). Impossibility of distributed consensus with one faulty process. *JACM, 32(2).*
7. Ben-Sasson, E. et al. (2018). Scalable, transparent, and post-quantum secure computational integrity. *IACR ePrint 2018/046.*

---

<div align="center">

*BLEEP · Quantum Trust Network · Protocol Version 5 · Pre-Testnet*

*This repository is provided for informational and development purposes only. It does not constitute financial or investment advice.*

**© 2026 BLEEP Project — Muhammad Attahir — Apache 2.0 Licence**

</div>
  protobuf-compiler libssl-dev pkg-config

# Rust stable (reads rust-toolchain.toml automatically)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

### Run a Node

```bash
git clone https://github.com/BleepEcosystem/BLEEP-v1.git
cd BLEEP-v1
cargo run --release
```

**What happens on startup (16-step sequence):**

```
[1/16] ✅ SPHINCS+-SHAKE-256f-simple keypair generated (PK=64 bytes, SK=128 bytes)
[1/16] ✅ Kyber-1024 keypair generated (PK=1568 bytes)
[2/16] ✅ Genesis block #0. Blockchain, mempool, tx-pool ready
[3/16] ✅ Wallet services online
[4/16] ✅ PAT engine running (6-layer intent-driven architecture)
[5/16] ✅ AI advisory ready (deterministic mode)
[6/16] ✅ Governance online
[6c/16] ✅ STARK prover/verifier — no trusted setup required
        ✅ STARK block circuit ready
        ✅ STARK batch tx circuit ready
[7/16] ✅ BLEEP Connect: ETH, BSC, SOL, COSMOS, DOT adapters registered
[8/16] ✅ Telemetry (Prometheus-compatible) active
[9/16] ✅ P2P node listening on 0.0.0.0:7700
[10/16] ✅ MempoolBridge active (500ms drain cycle)
[11/16] ✅ BlockProducer online (3s slots, PoS, VM, P2P gossip)
[16/16] ✅ JSON-RPC server on 0.0.0.0:8545
```

### Run the Interchain Demo

```bash
bash ./demo_interchain.sh
```

### Run the TPS Benchmark

```bash
bash ./test_tps.sh
```

---

## Architecture

BLEEP is structured as a 29-crate Cargo workspace with an acyclic dependency graph. Each crate has a single defined responsibility.

### Workspace Crates

```
crates/
├── bleep-ai              # Deterministic AI advisory — AIConstraintValidator, DeterministicInferenceEngine
├── bleep-auth            # Credentials, JWT sessions, RBAC, audit log, rate limiter, validator binding
├── bleep-cli             # Validator staking, governance, AI, ZKP, faucet commands
├── bleep-consensus       # PoS-Normal, Emergency, Recovery modes; slashing; epoch management
├── bleep-core            # Block types, ZKTransaction, mempool, shared data structures
├── bleep-crypto          # SPHINCS+, Kyber-1024, AES-256-GCM, SHA3-256, BLAKE3, ZKP primitives
├── bleep-economics       # Tokenomics, fee market (EIP-1559-style), validator incentives, oracle bridge
├── bleep-governance      # Constitution, ZK voting, proposal lifecycle, forkless upgrades
├── bleep-indexer         # Block, Tx, Account, Governance, Validator, Shard indexes
├── bleep-interop/        # BLEEP Connect — 10 sub-crates across 4 bridge tiers
│   ├── bleep-connect-types
│   ├── bleep-connect-crypto
│   ├── bleep-connect-adapters
│   ├── bleep-connect-commitment-chain
│   ├── bleep-connect-executor
│   ├── bleep-connect-layer1-social
│   ├── bleep-connect-layer2-fullnode
│   ├── bleep-connect-layer3-zkproof
│   ├── bleep-connect-layer4-instant
│   └── bleep-connect-core
├── bleep-p2p             # Kademlia DHT (k=20), Plumtree gossip (fanout=8), onion routing, peer scoring
├── bleep-pat             # Programmable Asset Token engine — 6-layer intent-driven architecture
├── bleep-rpc             # 46 JSON-RPC endpoints; health, state, proof, governance, bridge, AI
├── bleep-scheduler       # 20 built-in protocol maintenance tasks
├── bleep-state           # Sparse Merkle Trie (256-level), RocksDB, cross-shard 2PC, self-healing
├── bleep-telemetry       # Prometheus-compatible metrics, load balancer
├── bleep-vm              # 7-tier intent-driven VM: Native/Router/EVM/WASM/STARK/AI/Cross-Chain
├── bleep-wallet-core     # SPHINCS+ and Falcon key management, BIP-39 wallets, transaction signing
└── bleep-zkp             # Winterfell STARK block validity circuit; post-quantum ZKP constructions
```

### Subsystem Overview

| Subsystem | Crates | Responsibility |
|---|---|---|
| **Cryptography** | `bleep-crypto`, `bleep-zkp`, `bleep-wallet-core` | PQ signatures, KEM, STARK proofs, key lifecycle |
| **Consensus** | `bleep-consensus`, `bleep-scheduler` | Block production, finality, slashing, epoch management |
| **State** | `bleep-state`, `bleep-indexer` | Sparse Merkle Trie, RocksDB, shard lifecycle, self-healing |
| **Execution** | `bleep-vm`, `bleep-pat`, `bleep-ai` | Multi-engine VM, PAT engine, deterministic AI advisory |
| **Network** | `bleep-p2p`, `bleep-rpc`, `bleep-auth` | Node discovery, gossip, onion routing, authentication |
| **Interop** | `bleep-interop` (10 sub-crates) | 4-tier cross-chain bridge, intent pool, ZK proof relay |
| **Economics** | `bleep-economics`, `bleep-governance` | Tokenomics, fee market, ZK voting, forkless upgrades |

---

## Cryptographic Model

All cryptography on sensitive paths is post-quantum. There is no classical fallback.

### Signature Scheme — SPHINCS+-SHAKE-256f-simple (FIPS 205)

| Parameter | Value |
|---|---|
| Standard | FIPS 205 (SLH-DSA) |
| Security level | Level 5 (≥256-bit post-quantum) |
| Security assumption | One-wayness of SHAKE-256 (hash-based) |
| Public key | 32 bytes |
| Secret key | 64 bytes (`Zeroizing<Vec<u8>>` — zeroed on drop) |
| Signature | 7,856 bytes |
| Usage | Transaction signing, block signing, P2P message authentication |

### Key Encapsulation — Kyber-1024 / ML-KEM-1024 (FIPS 203)

| Parameter | Value |
|---|---|
| Standard | FIPS 203 (ML-KEM) |
| Security level | Level 5 (≥256-bit post-quantum) |
| Security assumption | Hardness of Module-LWE |
| Public key | 1,568 bytes |
| Secret key | 3,168 bytes (`Zeroizing<Vec<u8>>` — zeroed on drop) |
| Ciphertext | 1,568 bytes + 32-byte shared secret |
| Usage | Validator binding, peer KEM, wallet key management, onion routing |

### Zero-Knowledge Proofs — Winterfell STARK

| Property | Value |
|---|---|
| Construction | FRI-based STARK over 128-bit prime field |
| Trusted setup | **None** — fully transparent |
| Post-quantum security | Yes — reduces to collision resistance of BLAKE3 / SHA3-256 |
| Public inputs | `block_index`, `epoch_id`, `tx_count`, `merkle_root_hash`, `validator_pk_hash` |
| Usage | Block validity proofs, cross-chain bridge verification (Tier 3) |

### The Post-Quantum Boundary

Everything inside this boundary is quantum-resistant:

```
✅ Transaction signing      — SPHINCS+
✅ Block signing            — SPHINCS+
✅ P2P message auth         — SPHINCS+
✅ Key encapsulation        — Kyber-1024
✅ Block validity proofs    — Winterfell STARK
✅ Cross-chain bridge proofs — SPHINCS+-bound STARK transcripts
✅ Identity proofs          — SHA3-256 Sparse Merkle Trie paths
✅ Audit log chaining       — SHA3-256 Merkle chain
```

No classical public-key primitive (RSA, ECDSA, x25519, BLS) appears on any of these paths.

---

## Execution Model

### VM Dispatch Table

| Tier | Engine | Scope | Gas |
|---|---|---|---|
| 1 | **Native** | BLEEP Transfer, stake, unstake, governance vote | None |
| 2 | **Router** | Engine selection, gas validation, circuit breakers | Validation only |
| 3 | **EVM** (SputnikVM) | Ethereum-compatible contracts | Ethereum gas semantics |
| 4 | **WASM** (Wasmi) | WASM contracts | Configurable fuel metering |
| 5 | **STARK Proof** | ZK execution, public input verification | Fixed cost per verifier op |
| 6 | **AI-Advised** | Constraint validation — advisory, off-chain only | Deterministic; no gas |
| 7 | **Cross-Chain** | BLEEP Connect Tier 4 instant intent dispatch | Protocol fee in basis points |

*Source: `crates/bleep-vm/src/router/vm_router.rs`*

### State Transition

```
S_(t+1) = F(S_t, T)
```

Given identical state `S_t` and identical ordered transaction set `T`, every correct implementation produces byte-identical `S_(t+1)` — including the Sparse Merkle Trie root committed in the block header. Non-determinism on any consensus-critical path is classified as a protocol bug.

### Transaction Lifecycle

```
Submit (POST /rpc/tx/submit or P2P gossip)
  → nonce validity check
  → balance sufficiency check
  → minimum base fee check
  → SPHINCS+ signature verification
  → mempool admission
  → BlockProducer selection (fee-descending, max 4,096 per block)
  → Winterfell STARK BlockValidityProof generated
  → SPHINCS+ block signature
  → P2P gossip broadcast
  → BFT prevote → precommit → finalisation
```

---

## Consensus

### Validator Model

- Validators carry a SPHINCS+ verification key, a Kyber-1024 encapsulation key, and a stake in microBLEEP
- Safety guaranteed when Byzantine stake `f < S/3` (total staked supply)
- Three deterministic consensus modes: **PoS-Normal** (primary), **Emergency** (<67% validators responsive), **Recovery** (post-partition re-anchor)
- Block interval: **3,000 ms**
- Max transactions per block: **4,096**

### Finality

Finalisation requires precommits representing **more than 6,667 basis points** (66.67%) of total staked supply. Finalisation is **irreversible** — not probabilistic. Long-range reorgs are rejected at `FinalityManager`.

### Slashing

| Violation | Penalty |
|---|---|
| Double-sign | 33% of stake burned; validator tombstoned |
| Equivocation | 25% of stake burned |
| Downtime | 0.1% per consecutive missed block |
| Tier 4 bridge executor timeout | 30% of executor bond |

*Source: `crates/bleep-consensus/src/slashing_engine.rs`*

### Scheduler Tasks (20 built-in)

The `bleep-scheduler` runs 20 maintenance tasks including: `epoch_advance`, `validator_reward_distribution`, `slashing_evidence_sweep`, `supply_state_verify` (**SAFETY CRITICAL** — halts node if circulating supply exceeds 200M BLEEP), `token_burn_execution`, `self_healing_sweep`, `cross_shard_timeout_sweep`, `governance_proposal_advance`, `fee_market_update`, `peer_score_decay`, `audit_log_rotation`, and more.

---

## Cross-Chain Bridge — BLEEP Connect

A four-tier bridge with no permanently privileged operator and no trusted multisig key set. Implemented across 10 sub-crates in `crates/bleep-interop/`.

| Tier | Protocol | Latency | Security Basis | Status |
|---|---|---|---|---|
| **4 — Instant** | Executor auction + escrow | 200ms – 1s | Economic: 30% bond slashed on timeout | ✅ Live (Sepolia testnet) |
| **3 — ZK Proof** | SPHINCS+-bound STARK commitment | 10 – 30s | Cryptographic: PQ-secure, zero trusted operators | ✅ Live (Sepolia testnet) |
| **2 — Full-Node** | Multi-client verification | Hours | 90% consensus across ≥3 independent nodes | 🔲 Mainnet target |
| **1 — Social** | Stakeholder governance | 7 days / 24h emergency | Full governance consensus | 🔲 Mainnet target |

**Chain adapters registered at boot:** ETH, BSC, SOL, COSMOS, DOT

**Tier 4 parameters:**
- Executor auction window: 15 seconds
- Execution timeout: 120 seconds
- Protocol fee: 10 bps (0.1%)
- Executor bond slash on timeout: 30%

**Tier 3 parameters:**
- Batch size: 32 intents per proof bundle
- Double-spend prevention: `GlobalNullifierSet` with atomic `WriteBatch` (`sync=true`)
- Setup requirement: **None** (transparent STARK)

---

## Economics and Tokenomics

### Constitutional Parameters (compile-time `const_assert` — cannot be changed by governance)

| Parameter | Value | Source |
|---|---|---|
| Maximum supply | **200,000,000 BLEEP** | `MAX_SUPPLY` in `tokenomics.rs` |
| Maximum per-epoch inflation | **500 bps (5%)** | `MAX_INFLATION_RATE_BPS` |
| Fee burn floor | **2,500 bps (25%)** | `FEE_BURN_BPS` in `distribution.rs` |
| Minimum finality threshold | **>6,667 bps** | `FinalityManager` |

A code change that violates a constitutional assertion **does not compile**.

### Token Distribution

| Allocation | Tokens | % | Launch Unlock | Vesting |
|---|---|---|---|---|
| Validator Rewards | 60,000,000 | 30% | 10,000,000 | Emission decay schedule |
| Ecosystem Fund | 50,000,000 | 25% | 5,000,000 | 10-year linear; governance disbursement |
| Community Incentives | 30,000,000 | 15% | 5,000,000 | Governance-triggered release |
| Foundation Treasury | 30,000,000 | 15% | 5,000,000 | 6-year linear; governance spending |
| Core Contributors | 20,000,000 | 10% | 0 | 1-year cliff + 4-year linear; immutable on-chain |
| Strategic Reserve | 10,000,000 | 5% | 0 | Governance-controlled unlock |

### Validator Emission Schedule

| Year | Rate | Annual Emission |
|---|---|---|
| 1 | 12% | 7,200,000 BLEEP |
| 2 | 10% | 6,000,000 BLEEP |
| 3 | 8% | 4,800,000 BLEEP |
| 4 | 6% | 3,600,000 BLEEP |
| 5+ | 4% | 2,400,000 BLEEP/yr |

### Fee Market

EIP-1559-style base fee adjusting per block against a 50% capacity target. Each collected fee splits 25% burn / 50% validator rewards / 25% treasury — enforced by compile-time assertion that the three splits sum to exactly 10,000 bps.

| Parameter | Value |
|---|---|
| Minimum base fee | 1,000 microBLEEP |
| Maximum base fee | 10,000,000,000 microBLEEP |
| Max base fee change per block | 1,250 bps (12.5%) |
| Initial circulating supply | 25,000,000 BLEEP (12.5%) |

**Testnet faucet:** 10 BLEEP per address per 24 hours — `POST http://0.0.0.0:8545/faucet/{address}`

---

## Governance

### Proposal Lifecycle

```
Submit → AIConstraintValidator pre-flight → Active → Tally → Execute → Record
```

A proposal that would set `MaxInflationBps` above 500 is **rejected at pre-flight** and never reaches a vote.

### Configuration (testnet)

| Parameter | Value |
|---|---|
| Voting period | 1,000 blocks (~50 min at 3s block time) |
| Quorum | 1,000 bps (10% stake participation) |
| Pass threshold | 6,667 bps (66.67% of participating stake) |
| Veto threshold | 3,333 bps (33.33%) |
| Minimum deposit | 10,000 BLEEP |

### ZK Voting

Votes are cast as `EncryptedBallot` structs. `EligibilityProof` establishes voting power without revealing validator identity. `TallyProof` allows independent tally verification without revealing individual votes.

| Role | Vote weight multiplier |
|---|---|
| Validator | 1.0× |
| Delegator | 0.5× |
| Community token holder | 0.1× |

### Forkless Upgrades

`ForklessUpgradeEngine` activates hash-committed upgrade payloads at epoch boundaries only. Version progression is monotonically enforced; a version mismatch halts the chain. Partial upgrades are rejected atomically.

---

## Security

### Independent Security Audit (Sprint 9)

16,127 lines of Rust across six crates reviewed.

| Severity | Count | Resolved | Acknowledged |
|---|---|---|---|
| **Critical** | 2 | 2 | 0 |
| **High** | 3 | 3 | 0 |
| **Medium** | 4 | 3 | 1 (SA-M4: EIP-1559 design property; documented in `THREAT_MODEL.md`) |
| **Low** | 3 | 3 | 0 |
| **Informational** | 2 | 1 | 1 (SA-I2: NTP drift guard — mainnet gate) |

Full report: [`docs/SECURITY_AUDIT_SPRINT9.md`](docs/SECURITY_AUDIT_SPRINT9.md)  
Threat model: [`docs/THREAT_MODEL.md`](docs/THREAT_MODEL.md)

### Adversarial Test Suite (72-hour)

| Scenario | Expected Result |
|---|---|
| `ValidatorCrash(1)` | Consensus resumed — f=1 < 2.33 |
| `ValidatorCrash(2)` | Consensus resumed — f=2 < 2.33 |
| `NetworkPartition(4/3)` | Majority partition continued; healed cleanly |
| `LongRangeReorg(10)` | Rejected at `FinalityManager` |
| `LongRangeReorg(50)` | Rejected at `FinalityManager` |
| `DoubleSign(validator-0)` | 33% slashed; evidence committed; tombstoned |
| `TxReplay` | Rejected by nonce check |
| `InvalidBlockFlood(1000)` | Rejected at SPHINCS+ gate; peer rate-limited |
| `LoadStress(10,000 TPS, 60s)` | Block capacity saturated; max throughput reached |

### Game-Theoretic Safety

`SafetyVerifier` in `crates/bleep-economics/src/game_theory.rs` evaluates five attack models: Equivocation, Censorship, NonParticipation, Griefing, and Cartel formation. **A build fails if any model returns `is_profitable = true`** at current parameters.

### Fuzz Targets (CI-integrated)

- `fuzz_merkle_insert` — Sparse Merkle Trie insertion
- `fuzz_state_apply_tx` — state transition under malformed inputs
- `fuzz_tx_sign` — transaction signing under malformed inputs
- `fuzz_merkle_commitment` — Merkle commitment verification

---

## Scalability

### Sharding

- **10 shards** (`NUM_SHARDS`) in testnet configuration
- Each shard maintains an independent RocksDB instance
- Cross-shard transactions use `TwoPhaseCommitCoordinator` with deterministic coordinator selection from transaction hash
- Stalled coordinators force-aborted by `cross_shard_timeout_sweep` every 60 seconds

### Projected Performance (Simulated — Pre-Testnet)

| Metric | Value |
|---|---|
| Configuration | 10 shards, 4,096 tx/block, 3,000ms interval |
| Average TPS | **10,921** (target ≥10,000) |
| Peak TPS | 13,200 |
| Sustained minimum TPS | 9,840 |
| Full-capacity block ratio | 82.3% |

> **Note:** These are projections from simulated workloads — controlled network latency, geographically concentrated nodes, uniform transaction mix. Actual throughput on a geographically distributed public testnet will be measured and published during public testnet operation.

### Self-Healing

`SelfHealingOrchestrator` tracks protocol health across Healthy → Degraded → Critical → Recovering states. Low and medium severity faults are self-correcting. High and critical severity faults require quorum approval. All recovery actions are deterministic: identical fault evidence produces identical recovery actions on all honest validators.

---

## RPC Endpoints

The node exposes 46 JSON-RPC endpoints on `0.0.0.0:8545` at startup:

```
Core
  GET  /rpc/health
  GET  /rpc/state/{address}
  GET  /rpc/proof/{address}
  POST /rpc/tx/submit

Economics
  GET  /rpc/economics/supply
  GET  /rpc/economics/distribution
  GET  /rpc/oracle/price/BLEEP%2FUSD

BLEEP Connect
  GET  /rpc/connect/intents/pending        (L4 intent pool)
  GET  /rpc/layer3/intents                 (L3 ZK bridge)

Governance
  GET  /rpc/governance/proposals
  POST /rpc/governance/propose
  POST /rpc/governance/vote

AI Attestation
  GET  /rpc/ai/attestations/{epoch}

Protocol Hardening
  GET  /rpc/chaos/status
  GET  /rpc/benchmark/latest
  GET  /rpc/audit/report
  GET  /rpc/ceremony/status

Testnet UI
  GET  /explorer
  POST /faucet/{address}
  GET  /metrics
```

---

## AI Advisory Components

Two AI-assisted components exist. **Neither participates in block production, consensus voting, or any state-modifying operation without a prior governance vote.**

### Phase 3 — AIConstraintValidator

A deterministic rule engine that checks governance proposals against the four constitutional invariants before they enter the vote queue. Not a learned model. Applies explicit rules derived from the constitutional parameter set.

### Phase 4 — DeterministicInferenceEngine

An ONNX-based inference runtime enforcing six invariants: SHA3-256 model hash verification, deterministic input normalisation, deterministic output rounding, CPU-only execution, governance-approval gating, and no dynamic model loading.

Every inference produces an `InferenceRecord` containing the model hash, normalised inputs, raw outputs, and a deterministic seed — queryable at `GET /rpc/ai/attestations/{epoch}`.

---

## Audit Log

Every security-relevant event is written to a tamper-evident audit log backed by RocksDB with synchronous writes (`sync=true`). Log entries are SHA3-256 Merkle-chained. Mutating any stored entry causes chain verification to return `false`. The log survives node restarts.

---

## Protocol Parameters (Appendix)

### Consensus and Execution

| Parameter | Value |
|---|---|
| Block interval | 3,000 ms |
| Max transactions per block | 4,096 |
| Blocks per epoch (mainnet) | 1,000 |
| Blocks per epoch (testnet) | 100 |
| Finality threshold | >6,667 bps of total stake |
| Active shards | 10 |
| Double-sign slash | 33% of stake |
| Equivocation slash | 25% of stake |
| Downtime slash | 0.1% per missed block |

### Cryptography and Networking

| Parameter | Value |
|---|---|
| SPHINCS+ signature size | 7,856 bytes |
| SPHINCS+ public key | 32 bytes |
| Kyber-1024 public key | 1,568 bytes |
| State trie depth | 256 levels |
| Merkle proof size | 8,192 bytes (fixed, regardless of account count) |
| Gossip max message size | 2,097,152 bytes (2 MiB) |
| Gossip fanout | 8 |
| Kademlia k-bucket size | 20 |
| Onion routing max hops | 6 |
| ZK proof system | Winterfell STARK (FRI-based, f128 field) |
| Trusted setup requirement | **None** |
| JWT entropy minimum | 3.5 bits/byte (Shannon) |

---

## Roadmap Status

| Phase | Status |
|---|---|
| Phase 1 — Foundation | ✅ Complete |
| Phase 2 — Consensus & State | ✅ Complete |
| Phase 3 — VM & Interoperability | ✅ Complete |
| Phase 4 — Self-Healing & AI Advisory | ✅ Complete |
| Phase 5 — Hardening & Audit | ✅ Complete |
| Phase 6 — External Audit & Testnet Beta | 🔄 In progress (Q2 2026) |
| Phase 7 — Mainnet Candidate | 🔲 Planned (Q3–Q4 2026) |
| Phase 8 — Ecosystem Expansion | 🔲 Planned (2027) |
| Phase 9 — Quantum-Safe Mainnet | 🔲 Planned (2028+) |

Full details: [`ROADMAP.md`](ROADMAP.md)

---

## Contributing

BLEEP is self-funded and fully open-source under the Apache 2.0 licence (`bleep-vm` uses BSL-1.1 with a Change Date of 2028-07-13, after which it converts to Apache-2.0).

```bash
# Run the full test suite
cargo test --workspace --all-features

# Run clippy
cargo clippy --workspace --all-targets -- -D warnings

# Format
cargo fmt --all
```

See [`CONTRIBUTING.md`](CONTRIBUTING.md) for the full contribution guide, [`CODE-OF-CONDUCT.md`](CODE-OF-CONDUCT.md) for community standards, and [`SECURITY.md`](SECURITY.md) for the responsible disclosure policy.

---

## Community

| Channel | Link |
|---|---|
| Discord | [discord.gg/bleepecosystem](https://discord.gg/bleepecosystem) |
| Telegram | [t.me/bleepecosystem](https://t.me/bleepecosystem) |
| Twitter / X | [@BleepEcosystem](https://twitter.com/BleepEcosystem) |
| Zealy | [zealy.io/c/bleepecosystem](https://zealy.io/c/bleepecosystem) |
| Website | [bleepecosystem.com](https://www.bleepecosystem.com) |

---

## References

1. Shor, P.W. (1994). Algorithms for quantum computation: discrete logarithms and factoring.
2. NIST (2024). Post-Quantum Cryptography Standardization. FIPS 203, FIPS 205.
3. Mosca, M. (2018). Cybersecurity in an era with quantum computers. IEEE Security & Privacy.
4. Winterfell STARK library (2024). https://github.com/novifinancial/winterfell
5. Lamport, L., Shostak, R., Pease, M. (1982). The Byzantine generals problem.
6. Fischer, M.J., Lynch, N.A., Paterson, M.S. (1985). Impossibility of distributed consensus with one faulty process.

---

<div align="center">

*BLEEP · Quantum Trust Network · Protocol Version 4 · Pre-Testnet*

*This repository is provided for informational and development purposes. It does not constitute financial or investment advice.*

**© 2026 BLEEP Project — Apache 2.0 Licence**

</div>
