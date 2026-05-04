#!/bin/bash
#SBATCH --job-name=quarto_pdf
#SBATCH --partition=ncpu
#SBATCH --mem=100G
#SBATCH --cpus-per-task=4
#SBATCH --time=06:00:00
#SBATCH --output=logs/render_pdfs_%j.log
#SBATCH --error=logs/render_pdfs_%j.log

set -euo pipefail
cd "${SLURM_SUBMIT_DIR:-$(dirname "$0")}"

module load R/4.5
module load quarto

# Determine next run number
LAST=$(ls -d pdfs/run_* 2>/dev/null | grep -oP '\d+$' | sort -n | tail -1)
NEXT=$(printf "%03d" $(( ${LAST:-0} + 1 )))
OUTDIR="pdfs/run_${NEXT}"

echo "host:   $(hostname)"
echo "start:  $(date -Is)"
echo "run:    ${OUTDIR}"
echo "commit: $(git rev-parse --short HEAD 2>/dev/null || echo 'no-git')"

mkdir -p "${OUTDIR}/bulk_proteomics"
mkdir -p "${OUTDIR}/phosphoproteomics"

NOTEBOOKS=(
    bulk_proteomics/notebooks/01_initial_qc_spectronaut.qmd
    bulk_proteomics/notebooks/02_msstats.qmd
    bulk_proteomics/notebooks/03_DE_plots.qmd
    bulk_proteomics/notebooks/04_gsea.qmd
    bulk_proteomics/notebooks/05_microglia_app_modulated.qmd
    bulk_proteomics/notebooks/06_PPI.qmd
    bulk_proteomics/notebooks/07_subcellular.qmd
    phosphoproteomics/notebooks/01_phospho_qc.qmd
    phosphoproteomics/notebooks/02_msstatsptm.qmd
    phosphoproteomics/notebooks/03_phospho_DE_plots.qmd
    phosphoproteomics/notebooks/04_kinase_activity.qmd
    phosphoproteomics/notebooks/05_phospho_GSEA.qmd
)

for QMD in "${NOTEBOOKS[@]}"; do
    # Route to matching subfolder
    if [[ "$QMD" == bulk_proteomics/* ]]; then
        DEST="${OUTDIR}/bulk_proteomics"
    else
        DEST="${OUTDIR}/phosphoproteomics"
    fi
    echo "  rendering: ${QMD} -> ${DEST}/"
    quarto render "${QMD}" --to pdf --output-dir "${DEST}" 2>&1 || \
        echo "  WARNING: failed to render ${QMD}"
done

# Write a provenance note
{
    echo "run:    ${OUTDIR}"
    echo "date:   $(date -Is)"
    echo "commit: $(git rev-parse --short HEAD 2>/dev/null || echo 'no-git')"
} > "${OUTDIR}/provenance.txt"

echo "end: $(date -Is)"
echo "PDFs written to ${OUTDIR}/"
