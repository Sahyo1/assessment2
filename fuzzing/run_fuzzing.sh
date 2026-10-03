#!/usr/bin/env bash
# Reproduces the AFLsmart campaign against the WavPack encoder (ASAN build).
# Usage: ./run_fuzzing.sh [seeds_dir] [out_dir]
export AFLSMART=/opt/aflsmart
export PATH=$AFLSMART:$AFLSMART/peach-3.0.202-source/output/linux_x86_64_debug/bin:$PATH
export AFL_PATH=$AFLSMART
export LD_LIBRARY_PATH=/usr/local/lib

SEEDS="${1:-/home/fuzzer/seeds_small}"
OUT="${2:-/home/fuzzer/out}"

cd /home/fuzzer
timeout 24h afl-fuzz \
  -m none -h -d \
  -i "$SEEDS" -o "$OUT" \
  -w peach -g /home/fuzzer/wav.xml.orig -x /home/fuzzer/wav.dict -e wav \
  -- /home/fuzzer/WavPack/cli/wavpack_asan -y @@ -o /tmp/out_fuzz
