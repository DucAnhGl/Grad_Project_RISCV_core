#!/usr/bin/env bash
set -e

# Clean up previous CSV
rm -f log.csv
echo "IPC Accuracy" > log.csv

# Sweep values 2..12
for WIDTH in $(seq 2 12); do
  echo "== Running with HISTORY_WIDTH=$WIDTH =="
  HISTORY_WIDTH=$WIDTH make all PREDICTOR=1 HW=$WIDTH
done
