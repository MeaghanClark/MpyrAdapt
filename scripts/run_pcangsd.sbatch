#!/bin/bash

#SBATCH --job-name=pca
#SBATCH --output /home/miclark/MpyrAdapt/logs/pca-%j.out
#SBATCH --error /home/miclark/MpyrAdapt/logs/pca-%j.err
#SBATCH --cpus-per-task=8
#SBATCH --time=12:00:00
#SBATCH --mem=75G 
#SBATCH --partition=lab-mpinsky
#SBATCH --qos=pi-mpinsky
#SBATCH --account=pi-mpinsky

# Script written by M. Clark, 2/24/2023
# updated 03/18/2026
# This script calculates genotype likelihoods from a list of bamfiles

# adapted from: https://github.com/nt246/physalia-lcwgs/blob/main/day_3/markdowns/day3_PCA_Admixture_practicals.md

# merge QC snps list with LD pruned pos file 
DIR="/home/miclark/MpyrAdapt/data/geno_likelihoods"
# SNPLIST="${DIR}/LD_pruned/Mpyr_gl_unlinked.id"
BAMLIST="/home/miclark/MpyrAdapt/scripts/bamlist_pass_depth_northern_inds.txt"
REF="/home/miclark/MpyrAdapt/data/reference/Mpyr-NLJ1B.v3.hap1.softmasked.fasta" #filepath of reference file
OUTDIR="/home/miclark/MpyrAdapt/data/geno_likelihoods/LD_pruned"
RESULTS="/home/miclark/MpyrAdapt/results/pca"
CHROM="/home/miclark/MpyrAdapt/scripts/chrom_list.txt"

if [ ! -d $OUTDIR ]; then mkdir -p $OUTDIR; fi
if [ ! -d $RESULTS ]; then mkdir -p $RESULTS; fi


module load angsd/0.940
module list

# index SNP list 
sed 's/:/\t/' $SNPLIST > ${SNPLIST}.angsd # convert ":" to "\t" 
angsd sites index ${SNPLIST}.angsd

# call genotype likelihoods (parameters slightly different), use list of pruned SNPs 
  # some filtering parameters might be redundant (minInd and setmaxDepth), but keeping for consistency 
angsd -b $BAMLIST \
    -out $OUTDIR/Mpyr_north_pcangsd \
    -GL 1 \
    -doGlf 2 \
    -doMajorMinor 1 \
    -doMaf 1 \
    -doCounts 1 \
    -setmaxDepth 3486 \
    -minInd 95 \
    -minMapQ 20 \
    -minQ 20 \
    -nThreads 8 \
    -rf $CHROM #\
   # -sites ${SNPLIST}.angsd

echo "done running angsd to call genotype likelihoods"

# run PCangsd
module load pcangsd/1.36.1
module list

pcangsd -b $OUTDIR/Mpyr_north_pcangsd_LDpruned.beagle.gz -o $RESULTS/Mpyr_north_pcangsd

echo "done running pcangsd"

## END SCRIPT 
