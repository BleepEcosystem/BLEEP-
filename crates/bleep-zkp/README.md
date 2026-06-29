# bleep-zkp

**Zero-Knowledge Proof Primitives for BLEEP**

`bleep-zkp` provides STARK-based block validity proofs and post-quantum ZKP constructions used throughout the BLEEP ecosystem for governance voting, cross-chain verification, and validator attestation.

---

## License

Licensed under **MIT**.
Copyright © 2025 Muhammad Attahir.

---

## Architecture

```
bleep-zkp
├── stark_proofs      — Base block validity AIR + STARK prover/verifier (Winterfell, 5-column)
├── extended_air      — 68-column ExtendedBlockValidityAir with sig_commitment_root (Sprint 10)
├── batch_sig_prover  — ParallelBatchSigProver: rayon-parallel SAL commitment + STARK prove/verify
└── pq_proofs         — Post-quantum ZKP constructions (governance votes, cross-chain relay)
```

---

## Modules

### `stark_proofs` — Block Validity Circuit

Proves, in zero knowledge and without a trusted setup, that a BLEEP block is valid:

**Circuit inputs:**

| Slot | Public Input | Description |
|------|-------------|-------------|
| `x[0]` | `block_index` | Block number as `BaseElement` |
| `x[1]` | `epoch_id` | Epoch identifier |
| `x[2]` | `tx_count` | Number of transactions |
| `x[3]` | `merkle_root_hash` | SHA3-256 of the Merkle root (lower 31 bytes) |
| `x[4]` | `validator_pk_hash` | SHA3-256 of the validator public key |

**Private witnesses (known only to the prover):**
- `block_hash_witness` — the 32-byte block hash
- `sk_seed_witness` — the 32-byte validator secret key seed

**What the circuit proves:**
1. The block hash is the SHA3-256 of its public fields.
2. The validator knows the secret key whose hash equals the embedded public key hash.
3. The `epoch_id` is consistent with `block_index` and `blocks_per_epoch`.
4. The Merkle root commitment is non-zero (block has been committed).

**Key types:** `StarkProof`, `BlockValidityAir`, `BlockValidityProver`, `BlockValidityVerifier`.

```rust
use bleep_zkp::{BlockValidityProver, BlockValidityVerifier, StarkProof};

let prover = BlockValidityProver::new(block_witness);
let proof: StarkProof = prover.prove()?;

let verifier = BlockValidityVerifier::new(public_inputs);
verifier.verify(&proof)?;
```

STARKs require **no trusted setup**. Proofs are transparent and post-quantum secure (hash-based, not ECC-based).

### `extended_air` — Extended Block Validity Circuit (Sprint 10)

A 68-column extension of `BlockValidityAir` that commits to the Signature Availability Layer root alongside all standard block fields.

**Additional columns (48–67):**

| Columns | Purpose |
|---------|---------|
| 48–49 | `sig_commitment_root` (Blake3 Merkle root over SHA3-256(sig_i)) |
| 50–51 | `batch_seq_id` (monotonic, equals `block.index`) |
| 52–53 | `smt_root` (SHA3-256 of `shard_state_root`) |
| 54–67 | Signature count tracking and active-batch state |

**Public inputs (`ExtendedBlockPublicInputs`):**

```rust
pub struct ExtendedBlockPublicInputs {
    pub block_index:          u64,
    pub epoch_id:             u64,
    pub tx_count:             u32,
    pub blocks_per_epoch:     u64,
    pub merkle_root_hash:     [u8; 32],
    pub validator_pk_hash:    [u8; 32],
    pub sk_seed_hash:         [u8; 32],
    pub block_hash:           [u8; 32],
    pub smt_root:             [u8; 32],
    pub sig_commitment_root:  [u8; 32],   // ← SAL root
    pub sig_count:            u32,
    pub batch_seq_id:         u64,
}
```

**Proof format written to `block.zk_proof`:**

```
[9 bytes]    b"EXTSTARK1"                   ← magic discriminator
[232 bytes]  ExtendedBlockPublicInputs      ← fixed-width LE encoding
[remainder]  Winterfell StarkProof bytes
```

`Block::verify_zkp()` dispatches on the `EXTSTARK1` prefix automatically.

### `batch_sig_prover` — Parallel Batch Signature Prover

`ParallelBatchSigProver` orchestrates the full SAL prove/verify pipeline:

```rust
use bleep_zkp::{ParallelBatchSigProver, bleep_proof_options};

let prover = ParallelBatchSigProver::new(blocks_per_epoch, bleep_proof_options());
let trace  = prover.build_trace(&pub_inputs, &sig_hashes);
let proof  = prover.prove(trace)?;  // ~850–950 ms, within 3,000 ms slot budget
ParallelBatchSigProver::verify_block(pub_inputs, proof, &options)?;
```

Hashing is rayon-parallelised: SHA3-256(sig_i) for all transactions runs concurrently, then the Blake3 Merkle tree is built from the resulting hashes. The commitment is deterministic — given identical transaction signatures, all honest validators produce identical `sig_commitment_root` values.

### `pq_proofs` — Post-Quantum ZKP Constructions

Additional ZKP constructions designed for quantum-adversarial environments, used in:
- Post-quantum governance vote privacy
- Quantum-safe asset recovery proofs
- Cross-chain ZKP relay via `bleep-interop`

---

## Properties

| Property | Base circuit | Extended circuit (Sprint 10) |
|----------|-------------|------------------------------|
| Trusted setup | ❌ None | ❌ None |
| Post-quantum secure | ✅ | ✅ |
| Trace width | 5 columns | 68 columns |
| Proof size | ~100 KB | ~100 KB + 232-byte pub_inputs header |
| Proof format | `STARK_V1` prefix | `EXTSTARK1` prefix |
| SAL root committed | ✗ | ✅ `sig_commitment_root` in circuit |
| Prover time | ~850 ms | ~850–950 ms (rayon-parallel hashing) |
| Verifier time | ~12 ms | ~12 ms |

---

## Integration

`bleep-zkp` is consumed by:

| Consumer | Purpose |
|----------|---------|
| `bleep-consensus` | Block validity attestation (base + extended circuits) |
| `bleep-core` | `Block::verify_extended_stark_zkp()` — called from `verify_zkp()` on `EXTSTARK1` prefix |
| `bleep-governance` | Anonymous ZK vote verification |
| `bleep-interop` | Cross-chain STARK proof relay (Layer 3) |
| `bleep-crypto` | Winterfell STARK integration in `zkp_verification` |
| `bleep-vm` | ZK engine for contract ZK verification intents |

---

## Testing

```bash
cargo test -p bleep-zkp
```

---

*Part of the [BLEEP Ecosystem](https://github.com/BleepEcosystem/BLEEP-V1)*
