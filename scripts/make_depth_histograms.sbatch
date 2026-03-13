#!/bin/bash

#SBATCH --job-name=make_symbolic_links
#SBATCH --output /home/miclark/MpyrAdapt/logs/make_links-%j.out
#SBATCH --error /home/miclark/MpyrAdapt/logs/make_links-%j.err
#SBATCH --cpus-per-task=1
#SBATCH --time=4:00:00
#SBATCH --mem=120G 
#SBATCH --partition=lab-mpinsky
#SBATCH --qos=pi-mpinsky
#SBATCH --account=pi-mpinsky

# load modules
module load r/4.4.1
module list 

# define variables
EXEC="/home/miclark/MpyrAdapt/scripts/make_depth_histograms.R"
STATS_DIR="/home/miclark/MpyrAdapt/data/alignments/depth"
OUTFILE="/home/miclark/MpyrAdapt/data/alignments/depth/depth_histograms.pdf"

# run code
CMD="$EXEC $STATS_DIR $OUTFILE"
printf "\n%s\n\n" "$CMD"
eval $CMD

#print some environment variables to stdout for records
echo ----------------------------------------------------------------------------------------
echo PRINTING SUBSET OF ENVIRONMENT VARIABLES:
(set -o posix ; set | grep -v ^_ | grep -v ^EB | grep -v ^BASH | grep -v PATH | grep -v LS_COLORS)

echo ----------------------------------------------------------------------------------------
