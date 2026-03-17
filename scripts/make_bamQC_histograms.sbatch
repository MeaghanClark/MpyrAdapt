#!/bin/bash

#SBATCH --job-name=bamQC_hist
#SBATCH --output /home/miclark/MpyrAdapt/logs/bamQC_hist-%j.out
#SBATCH --error /home/miclark/MpyrAdapt/logs/bamQC_hist-%j.err
#SBATCH --cpus-per-task=1
#SBATCH --time=24:00:00
#SBATCH --mem=300G 
#SBATCH --partition=lab-mpinsky
#SBATCH --qos=pi-mpinsky
#SBATCH --account=pi-mpinsky

# load modules
module load r/4.4.1
module list 

# define variables
EXEC="/home/miclark/MpyrAdapt/scripts/make_bamQC_histograms.R"
STATS_DIR="/home/miclark/MpyrAdapt/data/alignments/bamstats"
OUTFILE="/home/miclark/MpyrAdapt/data/alignments/bamstats/bamQC_histograms.pdf"

# verify STATS_DIRE exists; if not, make it
if [ ! -d $STATS_DIR ]; then mkdir $STATS_DIR; fi

# run code
CMD="$EXEC $STATS_DIR $OUTFILE"
printf "\n%s\n\n" "$CMD"
eval $CMD

#print some environment variables to stdout for records
echo ----------------------------------------------------------------------------------------
echo PRINTING SUBSET OF ENVIRONMENT VARIABLES:
(set -o posix ; set | grep -v ^_ | grep -v ^EB | grep -v ^BASH | grep -v PATH | grep -v LS_COLORS)

echo ----------------------------------------------------------------------------------------
