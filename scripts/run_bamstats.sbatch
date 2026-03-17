#!/bin/bash

#--------------- EXECUTABLE ---------------

# This script runs bamstats on a merged bam file
# Last updated 03/13/2026 by MI Clark,based on script by T Linderoth
# Input: 
#
# Output: 

#load modules
module load bcftools/1.21
module list 

# define array vars
CHROM=$(sed -n "${SLURM_ARRAY_TASK_ID}p" $ARRAY_KEY) 
OUTFILE=${OUTDIR}/MpyrAdapt_scaffold.${SLURM_ARRAY_TASK_ID}.bamstats 

# run bamstats
CMD="$BAMSTATS -A -d 0 -f $REFERENCE -q 0 -Q 0 -r $CHROM --ff UNMAP,SECONDARY,QCFAIL,DUP -s -aa $INBAM >> $OUTFILE"
printf "\n%s\n\n" "$CMD"
eval $CMD
wait

#print some environment variables to stdout for records
echo ----------------------------------------------------------------------------------------
echo PRINTING SUBSET OF ENVIRONMENT VARIABLES:
(set -o posix ; set | grep -v ^_ | grep -v ^EB | grep -v ^BASH | grep -v PATH | grep -v LS_COLORS)

echo ----------------------------------------------------------------------------------------
seff ${SLURM_JOBID}
