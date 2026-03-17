#!/bin/bash

#--------------- EXECUTABLE ---------------

# This script runs bcftools norm on a zipped bcf file
# Last updated 03/13/2026 by MI Clark, based on script by T Linderoth
# Input: Reference genome with path, zipped bcf file
#
# Output: normalized zipped bcf file 

#load programs we want to use
module load bcftools/1.21 
module list 

# Required import variables from wrapper
#	(1) reference
#	(3) OUTDIR

# path to a file that contains the list of chromosomes for this array job no. 
INBCF_NAME=MpyrAdapt_scaffold_${SLURM_ARRAY_TASK_ID}.bcf.gz
OUTBCF_NAME=MpyrAdapt_scaffold_${SLURM_ARRAY_TASK_ID}_norm.bcf.gz

# define chromosome to call SNPs on 
CHROM=$(sed -n "${SLURM_ARRAY_TASK_ID}p" $ARRAY_KEY) 

### Normalize variants

echo I am running bcftools norm using $REFERENCE, $CHROM, ${OUTDIR}/${OUTBCF_NAME}, and ${INDIR}/${INBCF_NAME} as imported from the wrapper script and defined here
echo
echo The date is $DATE

CMD="bcftools norm -f $REFERENCE -r $CHROM --threads ${CPUS} -O b -o ${OUTDIR}/${OUTBCF_NAME} ${INDIR}/${INBCF_NAME}"

printf "\n%s\n\n" "$CMD"

eval $CMD

wait

tabix -p bcf ${OUTDIR}/${OUTBCF_NAME}

printf "--FIN--"


#print some environment variables to stdout for records
echo ----------------------------------------------------------------------------------------
echo PRINTING SUBSET OF ENVIRONMENT VARIABLES:
(set -o posix ; set | grep -v ^_ | grep -v ^EB | grep -v ^BASH | grep -v PATH | grep -v LS_COLORS)

echo ----------------------------------------------------------------------------------------
