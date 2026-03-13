#!/bin/bash --login

#--------------- EXECUTABLE ---------------

# This script calls snps
# Last updated 03/13/2026 by MI Clark, based on script by R Toczydlowski. Shout out to T Linderoth for helping establish reasonable SNP calling parameters
# Input: Reference genome path, bam file, input directory, output directory from wrapper-call_snps.sh 
#
# Output: ${OUTDIR}/${SAMPLE_NAME}.bcf  file, stored in directory at <storagenode>/<run_name>/called_snps
#			example: /mnt/home/clarkm89/massasauga/called_snps/PCC_321.bcf 

# DEFINE SAMPLE_NAMES, got rid of ploidyf, using ARRAY_KEY instead of CHROM_LIST_DIR

# load modules 
module load bcftools/1.21
module list 

echo we are starting calling snps!
 

# Required import variables from wrapper
#	(1) reference
#	(2) list of bamfiles
#	(3) OUTDIR

# define chromosome to call SNPs on 
CHROM=$(sed -n "${SLURM_ARRAY_TASK_ID}p" $ARRAY_KEY) 

# name BCF output
BCF_NAME=MpyrAdapt_scaffold_${SLURM_ARRAY_TASK_ID}

# text for troubleshooting
echo using $REFERENCE 
echo I will put the output in ${OUTDIR}/${BCF_NAME}.bcf 

# make sure .bam files are indexed! 

# parameter recs from T Linderoth
 bcftools mpileup \
 -f $REFERENCE \
 -b $BAMLIST \
 -r $CHROM \
 -S $SAMPLE_LIST \
 -C 0 \
 -d 10000 \
 -L 10000 \
 -q 20 \
 -Q 13 \
 --ns "UNMAP,SECONDARY,QCFAIL,DUP" \
 --nu "PROPER_PAIR" \
 -a "FORMAT/AD,FORMAT/DP,FORMAT/QS,FORMAT/SP,FORMAT/SCR,INFO/AD,INFO/SCR" \
 -p \
 -O u \
 | bcftools call \
 -a PV4,GQ,GP \
 -m \
 -P 0.002 \
 -O u \
 | bcftools +fill-tags \
 -O b \
 -o ${OUTDIR}/${BCF_NAME}.bcf.gz \
 -- -t 'AF,ExcHet,NS'

echo --FIN-- 


echo I have called SNPs using $BAMLIST and $REFERENCE
echo I have also output a bcf file and saved it here: ${OUTDIR}/${BCF_NAME}.bcf

wait

tabix -p bcf ${OUTDIR}/${BCF_NAME}.bcf.gz

#print some environment variables to stdout for records
echo ----------------------------------------------------------------------------------------
echo PRINTING SUBSET OF ENVIRONMENT VARIABLES:
(set -o posix ; set | grep -v ^_ | grep -v ^EB | grep -v ^BASH | grep -v PATH | grep -v LS_COLORS)

echo ----------------------------------------------------------------------------------------

