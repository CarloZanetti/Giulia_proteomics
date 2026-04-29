#!/bin/bash
#SBATCH --job-name=quarto_render
#SBATCH --partition=ncpu
#SBATCH --mem=200G
#SBATCH --cpus-per-task=4
#SBATCH --time=24:00:00
#SBATCH --output=render_%j.log
#SBATCH --error=render_%j.log

set -euo pipefail
cd "${SLURM_SUBMIT_DIR}"

echo "host: $(hostname)"
echo "start: $(date -Is)"

module load R/4.5
module load quarto

quarto render

echo "end: $(date -Is)"
