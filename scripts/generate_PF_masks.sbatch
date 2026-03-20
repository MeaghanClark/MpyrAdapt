#!/bin/bash

# This script generates bed file of site masks based on bam statistics
# Last updated 03/16/2026 by MI Clark, based on script by T Linderoth

#load programs we want to use
module load perl/5.40.0
module list 

# define variables 
# SCRIPT defined in wrapper
BAMSTATS=${INDIR}/MpyrAdapt_scaffold.${SLURM_ARRAY_TASK_ID}.bamstats
OUTPREFIX=${OUTDIR}/MpyrAdapt_PF_mask_${SLURM_ARRAY_TASK_ID}
REPORT=${OUTDIR}/reports/MpyrAdapt_PF_mask_${SLURM_ARRAY_TASK_ID}.txt

### create bed file of masks

echo The date is $DATE

CMD="$SCRIPT --mindepth 174 --maxdepth 3486 --minmq 35 --maxmq0 0.1 --minbq 20 --maxbq0 0.1 $BAMSTATS $OUTPREFIX > $REPORT" # update filtering values based on bamstats summaries

# changed parameters based on output from bamstats histograms 

printf "\n%s\n\n" "$CMD"
eval $CMD


#print some environment variables to stdout for records
echo ----------------------------------------------------------------------------------------
echo PRINTING SUBSET OF ENVIRONMENT VARIABLES:
(set -o posix ; set | grep -v ^_ | grep -v ^EB | grep -v ^BASH | grep -v PATH | grep -v LS_COLORS)

echo ----------------------------------------------------------------------------------------
