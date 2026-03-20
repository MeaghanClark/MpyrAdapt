#!/bin/bash

#SBATCH --job-name=call_gl
#SBATCH --output /home/miclark/MpyrAdapt/logs/call_gl-%j.out
#SBATCH --error /home/miclark/MpyrAdapt/logs/call_gl-%j.err
#SBATCH --cpus-per-task=8
#SBATCH --time=12:00:00
#SBATCH --mem=120G 
#SBATCH --partition=lab-mpinsky
#SBATCH --qos=pi-mpinsky
#SBATCH --account=pi-mpinsky

# Script written by M. Clark, 2/24/2023
# updated 03/18/2026
# This script calculates genotype likelihoods from a list of bamfiles

# usage: 
# call_geno_likelihood.sh

module load angsd/0.940
module list

OUTDIR="/home/miclark/MpyrAdapt/data/geno_likelihoods"
INDS="/home/miclark/MpyrAdapt/scripts/pass_depth_northern_inds.txt"
BAMLIST="/home/miclark/MpyrAdapt/scripts/bamlist_pass_depth_northern_inds.txt"
BAMDIR="/home/miclark/MpyrAdapt/data/alignments"

if [ ! -d $OUTDIR ]; then mkdir $OUTDIR; fi

awk -v dir="$BAMDIR" '{print dir"/"$1".rmdup.bam"}' "$INDS" > "$BAMLIST"

echo "Job started: $(date)"
echo "Number of individuals: $(wc -l < ${BAMLIST})"

# make sure bam files are indexed! 
# minIND: # ~60% of 158 samples

angsd -b ${BAMLIST} -GL 1 -doMaf 1 -doMajorMinor 1 -doCounts 1 -SNP_pval 1e-4 -minInd 95 -minMapQ 20 -minQ 20 -setMaxDepth 3486 -doGlf 2 -nThreads 8 -out $OUTDIR/Mpyr_north_gl

# angsd -b ${BAMLIST} -setMaxDepth 3486

echo done calling genotype likelihoods
