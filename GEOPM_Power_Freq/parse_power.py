#!/usr/bin/env python3
"""Parse output_power.*.txt files: report board/GPU energy and frequency-control status per block."""

import argparse
import re
import sys
from pathlib import Path


FREQ_RE = re.compile(r"Start running in\s+(\d+)\s*MHz")
RUNTIME_RE = re.compile(r"Runtime:\s*([-\d.]+)\s*s")
APP_RC_RE = re.compile(r"App exit:\s*(-?\d+)")
BOARD_RE = re.compile(
    r"Board Energy Start:\s*([-\d.]+),\s*End:\s*([-\d.]+),\s*Used:\s*([-\d.]+)"
)
GPU_ALL_RE = re.compile(
    r"GPU_CHIP All,\s*GPU Energy start:\s*([-\d.]+),\s*End:\s*([-\d.]+),\s*Energy used:\s*([-\d.]+)"
)
STATUS_RE = re.compile(r"GPU_CORE_FREQUENCY_STATUS:\s*(.*)")


def parse_file(path: Path):
    """Yield (freq_mhz, runtime_s, app_rc, board_used, gpu_used, reported_mhz) per block.

    reported_mhz is a list of per-GPU frequencies (in MHz) or None if not seen.
    runtime_s is a float (seconds) or None if not present.
    app_rc is an int (App exit code) or None if not present.
    """
    freq = runtime = app_rc = board = gpu = reported = None
    with path.open() as f:
        for line in f:
            m = FREQ_RE.search(line)
            if m:
                if freq is not None:
                    yield freq, runtime, app_rc, board, gpu, reported
                freq = int(m.group(1))
                runtime = app_rc = board = gpu = reported = None
                continue
            m = RUNTIME_RE.search(line)
            if m:
                runtime = float(m.group(1))
                continue
            m = APP_RC_RE.search(line)
            if m:
                app_rc = int(m.group(1))
                continue
            m = BOARD_RE.search(line)
            if m:
                board = float(m.group(3))
                continue
            m = GPU_ALL_RE.search(line)
            if m:
                gpu = float(m.group(3))
                continue
            m = STATUS_RE.search(line)
            if m:
                reported = [int(x) // 1_000_000 for x in m.group(1).split()]
    if freq is not None:
        yield freq, runtime, app_rc, board, gpu, reported


def freq_control_status(requested, reported):
    if reported is None:
        return "no GPU_CORE_FREQUENCY_STATUS line"
    failed = [i for i, v in enumerate(reported) if v != requested]
    if not failed:
        return "success"
    return f"failed [failed GPUs: {failed}]"


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument(
        "files",
        nargs="*",
        type=Path,
        help="Power output files (default: output_power.*.txt in parent dir)",
    )
    args = ap.parse_args()

    files = args.files
    if not files:
        here = Path(__file__).resolve().parent
        files = sorted(here.glob("output_power.*.txt"))
        files += sorted(here.glob("output.*/output_power.*.txt"))
    if not files:
        print("No input files found.", file=sys.stderr)
        sys.exit(1)

    total_blocks = total_failed = 0
    for path in files:
        print(f"\n=== {path.name} ===")
        header = (
            f"{'Freq (MHz)':>10} {'Runtime (s)':>12} {'GPU Pow (W)':>14}"
            f" {'Board Pow (W)':>14} {'GPU Energy':>14} {'Board Energy':>14}"
            f" {'App exit':>9}  {'Frequency control':<35} {'FOM':>12}"
        )
        print(header)
        for freq, runtime, app_rc, board, gpu, reported in sorted(parse_file(path)):
            rt_s = f"{runtime:.3f}" if runtime is not None else "N/A"
            board_s = f"{board:.0f}" if board is not None else "N/A"
            gpu_s = f"{gpu:.0f}" if gpu is not None else "N/A"
            board_pow = board / runtime if board is not None and runtime else None
            gpu_pow = gpu / runtime if gpu is not None and runtime else None
            bp_s = f"{board_pow:.1f}" if board_pow is not None else "N/A"
            gp_s = f"{gpu_pow:.1f}" if gpu_pow is not None else "N/A"
            rc_s = str(app_rc) if app_rc is not None else "N/A"
            fom_s = ""
            freq_ctrl = freq_control_status(freq, reported)
            app_bad = app_rc is not None and app_rc != 0
            ok = (freq_ctrl == "success") and not app_bad
            total_blocks += 1
            if not ok:
                total_failed += 1
            ctrl = freq_ctrl
            if app_bad:
                ctrl = f"{freq_ctrl} | app FAILED (rc={app_rc})"
            print(
                f"{freq:>10d} {rt_s:>12} {gp_s:>14} {bp_s:>14}"
                f" {gpu_s:>14} {board_s:>14} {rc_s:>9}  {ctrl:<35} {fom_s:>12}"
            )

    if total_blocks:
        print(
            f"\nSummary: {total_blocks - total_failed}/{total_blocks} blocks OK"
            f" (both Frequency control = success AND App exit = 0)"
            f" across {len(files)} file(s)"
        )


if __name__ == "__main__":
    main()
