# GEOPM Power/Frequency Sweep Harness

A small set of scripts that measures **board energy, GPU energy, runtime, and
average power** of your application across a sweep of GPU frequencies on
GEOPM-enabled systems (developed and tested on ALCF Sunspot).

You should only need to edit **`Run_my_app.sh`** to plug your own application
into the harness.

---

## Files

| File | Purpose | Edit it? |
|------|---------|----------|
| `Run_GEOPM_Power.sh` | PBS job script: sweeps frequency, samples energy, calls your app, runs the parser | Only the PBS header (`#PBS -A`, walltime, etc.) and the `FREQ_MAX/MIN/STEP` block, if needed |
| `Run_my_app.sh`      | Launches **your** application — this is the timed/measured region | **Yes** — replace the body with your own `mpiexec`/`mpirun` line |
| `freq_set.sh`        | Pins the GPU min/max/boost frequency via sysfs (`/sys/class/drm/cardN/...`) | Usually no; edit only if your system uses different sysfs paths |
| `parse_power.py`     | Reads `output_power.*.txt` and prints an aligned per-frequency summary | Usually no |

---

## What you need to do

### 1. Edit `Run_my_app.sh`

Replace the placeholder body with whatever launches your application. Common
pattern:

```bash
#!/bin/bash

# Any env vars your app needs
export FI_CXI_DEFAULT_CQ_SIZE=131072

NNODES=`wc -l < $PBS_NODEFILE`
NMPI=$(( NNODES * 12 ))      # adjust 12 if your node has a different GPU count

EXE=/path/to/your/binary
INPUT=/path/to/your/input

mpiexec -n $NMPI --ppn 12 gpu_tile_compact.sh ${EXE} ${INPUT}
```

**Important:**
- Everything `Run_my_app.sh` does is **inside the timed region**. 
- Your app must **exit non-zero on failure**. The harness captures `$?` and
  flags any block where the app crashed (`App exit != 0`). If your launcher
  swallows the exit code, the parser will silently report misleading "low
  power" numbers from a crashed run.
- Keep the **work per run** constant. The sweep compares
  frequencies at fixed work; using a wall-clock-based stopping criterion
  inside your app will defeat the comparison.

### 2. (Optional) Adjust the PBS header in `Run_GEOPM_Power.sh`

```bash
#PBS -A Performance                  # your project / allocation
#PBS -l select=1                     # number of nodes
#PBS -l walltime=9:00:00
#PBS -q workq
#PBS -l filesystems=home:tegu
```

### 3. (Optional) Adjust the frequency sweep

Near the top of `Run_GEOPM_Power.sh`:

```bash
FREQ_MAX=1600       # highest MHz
FREQ_MIN=800        # lowest MHz
FREQ_STEP=100       # step size (sweep is high → low)
```

### 4. Submit

```bash
qsub Run_GEOPM_Power.sh
```

---

## Outputs

Everything for a single job lands in `output.${jobid}/`:

| File | Contents |
|------|----------|
| `output_power.${jobid}.txt`           | Raw per-frequency blocks (input to the parser) |
| `output_app.FREQ${F}.${jobid}.txt`    | Combined stdout/stderr of `Run_my_app.sh` at frequency F |
| `summary.${jobid}.txt`                | Human-readable per-frequency table (parser output) |
| `Power_Measurement.o${jobid}`         | PBS stdout (moved here at the end of the job, if possible) |

### Reading the summary

```
Freq (MHz)  Runtime (s)    GPU Pow (W)  Board Pow (W)     GPU Energy   Board Energy  App exit  Frequency control
       800       59.596          720.2         2068.7          42921         123285         0  success
       900       56.634          788.0         2137.9          44625         121075         0  success
      ...
```

| Column | Meaning |
|--------|---------|
| **Freq (MHz)**        | Requested GPU core frequency for this run |
| **Runtime (s)**       | Wall-clock time of `./Run_my_app.sh` (from `date +%s.%N`) |
| **GPU Pow (W)**       | Avg GPU power = (sum of all GPU chips' energy delta) / runtime |
| **Board Pow (W)**     | Avg full-board power = `MSR::BOARD_ENERGY` delta / runtime |
| **GPU Energy**        | Sum of `GPU_CHIP_ENERGY` deltas across all chips (J) |
| **Board Energy**      | `MSR::BOARD_ENERGY` delta (J) |
| **App exit**          | Exit code of `Run_my_app.sh` (0 = OK) |
| **Frequency control** | `success` if every GPU chip reported the requested frequency in `GPU_CORE_FREQUENCY_STATUS`; otherwise `failed [failed GPUs: [ids]]` |

The trailing **`Summary: N/N blocks OK`** line counts blocks where BOTH the
app exited cleanly AND the frequency was correctly applied to all GPUs.
**Always check this line — a block with `App exit != 0` will produce
misleadingly low energy/power because the app likely crashed early.**

### Re-running the parser by itself

```bash
python3 parse_power.py output.${jobid}/output_power.${jobid}.txt
```

With no arguments, it auto-discovers `output_power.*.txt` in the current
folder and in any `output.*/` subfolders.

---

## Assumptions / portability

- **12 GPU chips per node** is currently hard-coded in `Run_GEOPM_Power.sh`
  (the `seq 0 11` loops) and in `freq_set.sh` (`card{0..5}` with 2 tiles each).
  If your node has a different GPU count, both will need updates.
- The script reads GEOPM signals: `MSR::BOARD_ENERGY`, `GPU_CHIP_ENERGY`,
  `GPU_CORE_FREQUENCY_STATUS`. They must be registered on the compute node
  where the job runs (they are on Sunspot; login-node `geopmread` may report
  fewer signals).
- `freq_set.sh` writes to `/sys/class/drm/cardN/gt_*_freq_mhz`. The user
  running it must have permissions for these sysfs writes (usually granted
  inside the job allocation).

---

## Troubleshooting

| Symptom | Likely cause |
|---------|--------------|
| `App exit != 0` for every frequency | Your `Run_my_app.sh` path/launcher is wrong; check `output_app.FREQ*.${jobid}.txt` |
| `Frequency control = failed [failed GPUs: [...]]` | `freq_set.sh` ran without the right permissions, or the frequency you requested is outside the GPU's supported range — check the actual MHz values reported |
| Runtime is much shorter at low freq than high freq | Your app probably ran less work (early exit, error) — verify via `output_app.FREQ*` |
| `summary.${jobid}.txt` is empty | The post-processing `python3 parse_power.py` line failed; rerun manually |
