#!/bin/bash
#SBATCH --job-name=configuration_distance_relationship_parallel
#SBATCH --time=00:25:00
#SBATCH --mem=25G
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=30
#SBATCH --mail-type=BEGIN,END
#SBATCH --mail-user=bs20brkh@leeds.ac.uk

# Load any necessary modules
module load miniforge
conda activate r_spatial_env

# Run the job
Rscript /mnt/scratch/bs20brkh/configuration_distance_relationship_parallel_HPC.R

