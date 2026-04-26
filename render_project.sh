#!/bin/bash
#SBATCH --job-name=quarto_render
#SBATCH --mem=200G              # Request 32GB of RAM (adjust as needed)
#SBATCH --cpus-per-task=4      # Request 4 CPUs
#SBATCH --time=24:00:00        # Give it 2 hours
#SBATCH --output=render_%j.log

# Load the same modules you used on the login node
module load R/4.5
module load quarto

# Run the render
quarto render
