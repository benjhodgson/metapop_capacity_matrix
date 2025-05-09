#!/bin/bash
#SBATCH --job-name=cover_distance_relationship_parallel
#SBATCH --time=00:40:00
#SBATCH --mem=50G
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=30
#SBATCH --mail-type=BEGIN,END
#SBATCH --mail-user=bs20brkh@leeds.ac.uk

# Load any necessary modules
module load miniforge
conda activate r_spatial_env

# Run the job
Rscript /mnt/scratch/bs20brkh/cover_distance_relationship_parallel_HPC.R
