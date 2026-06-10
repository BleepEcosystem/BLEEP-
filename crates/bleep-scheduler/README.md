# bleep-scheduler

**Protocol Task Scheduler — BLEEP Quantum Trust Network**

`bleep-scheduler` manages all time-driven and block-driven protocol maintenance tasks. It runs 20 built-in tasks across 7 categories, each in an isolated Tokio task with a configurable timeout. A panic or hang in one task never affects the scheduler or other tasks. All tasks are idempotent — safe to re-run after a node restart without side effects.

---

## License

Licensed under **Apache 2.0**.
Copyright © 2026 Muhammad Attahir.

---

## Architecture

```
bleep-scheduler
├── built_in    — 20 built-in task implementations
├── registry    — TaskRegistry, RegisteredTask, TaskContext, dynamic registration
├── task        — TaskId, TaskKind, Trigger, TaskStatus, ExecutionOutcome, TaskRunRecord
├── metrics     — MetricsStore, SchedulerMetrics, TaskMetrics (Prometheus-compatible)
└── errors      — SchedulerError, SchedulerResult
```

### Execution Model

- `interval_loop` fires tasks on wall-clock intervals (1-second tick resolution)
- `block_loop` fires tasks on each new block notification from `bleep-consensus`
- Each task runs in an isolated Tokio task with a configurable `timeout_secs`
- Hung tasks are cancelled at their timeout boundary — scheduler continues unaffected
- Tasks never share mutable state directly — all inter-task communication via `Arc`/channel
- `last_run_at` is updated before spawning to prevent double-firing on restart

---

## Built-In Tasks — 20 Tasks, 7 Categories

### EPOCH
| Task | Trigger | Description |
|---|---|---|
| `epoch_advance` | Interval | Transitions to next epoch; rotates validator set; distributes rewards |
| `epoch_metrics_snapshot` | Interval | Captures epoch-end telemetry for Prometheus |

### CONSENSUS
| Task | Trigger | Description |
|---|---|---|
| `validator_trust_decay` | Interval | Decays AI-derived validator reputation scores |
| `validator_reward_distribution` | Block | Distributes per-block rewards to validators |
| `slashing_evidence_sweep` | Interval | Processes pending slashing evidence queue |

### HEALING
| Task | Trigger | Description |
|---|---|---|
| `self_healing_sweep` | Interval | Triggers fault detection and recovery orchestration |
| `recovery_timeout_check` | Interval | Cancels stale recovery operations |

### GOVERNANCE
| Task | Trigger | Description |
|---|---|---|
| `governance_proposal_advance` | Block | Checks proposals for quorum; advances lifecycle |
| `governance_voting_window_close` | Interval | Closes expired voting windows |

### ECONOMICS
| Task | Trigger | Safety | Description |
|---|---|---|---|
| `fee_market_update` | Block | — | Recalculates EIP-1559-style base fee after each block |
| `supply_state_verify` | Interval | ⚠️ SAFETY CRITICAL | Asserts supply conservation invariant — **halts node if circulating supply exceeds 200,000,000 BLEEP** |
| `token_burn_execution` | Interval | — | Executes pending scheduled fee burns |

> **`supply_state_verify` is a safety-critical task.** If it detects that circulating supply exceeds `MAX_SUPPLY` (200,000,000 BLEEP), it halts the node rather than continuing in a potentially invalid state. This is a constitutional enforcement mechanism, not a monitoring task.

### NETWORKING
| Task | Trigger | Description |
|---|---|---|
| `shard_rebalance` | Interval | Redistributes validators across 10 shards |
| `peer_score_decay` | Interval | Decays AI-derived peer quality scores |
| `cross_shard_timeout_sweep` | Interval | Force-aborts stale cross-shard 2PC coordinators after 60s |

### MAINTENANCE
| Task | Trigger | Description |
|---|---|---|
| `session_revocation_purge` | Interval | Removes expired JWT deny-list entries |
| `rate_limit_bucket_purge` | Interval | Clears expired rate limiter windows |
| `mempool_prune` | Interval | Evicts low-fee transactions when mempool is full |
| `indexer_checkpoint` | Interval | Writes indexer snapshots for crash recovery |
| `audit_log_rotation` | Interval | Archives and rotates SHA3-256 Merkle-chained audit log segments |

---

## Quick Start

```rust
use bleep_scheduler::{TaskRegistry, TaskContext};

let registry = TaskRegistry::new();
registry.register_all_built_in(context.clone());

// Start both loops
tokio::join!(
    registry.start_interval_loop(),
    registry.start_block_loop(block_rx),
);
```

---

## Custom Tasks

Tasks can be registered dynamically without modifying built-in code:

```rust
use bleep_scheduler::{RegisteredTask, TaskId, TaskKind, ExecutionOutcome};

registry.register(RegisteredTask {
    id:           TaskId::from("my_custom_task"),
    kind:         TaskKind::Interval { secs: 60 },
    timeout_secs: 10,
    handler:      Arc::new(|ctx| Box::pin(async move {
        // task implementation
        Ok(ExecutionOutcome::Success)
    })),
});
```

---

## Metrics

All task execution outcomes are tracked in `MetricsStore` and exposed via the Prometheus-compatible `/metrics` endpoint:

- `scheduler_task_runs_total{task, outcome}` — total executions by outcome
- `scheduler_task_duration_seconds{task}` — execution time histogram
- `scheduler_task_timeouts_total{task}` — timeout counter per task

---

## Testing

```bash
cargo test -p bleep-scheduler
```

---

*Part of the [BLEEP Quantum Trust Network](https://github.com/BleepEcosystem/BLEEP-v1) · Protocol Version 5*
*© 2026 Muhammad Attahir — Apache 2.0 Licence*
