#!/bin/bash

#SBATCH --job-name=vcf_depth
#SBATCH --output /home/miclark/MpyrAdapt/logs/vcf_depth-%j.out
#SBATCH --error /home/miclark/MpyrAdapt/logs/vcf_depth-%j.err
#SBATCH --cpus-per-task=32
#SBATCH --time=12:00:00
#SBATCH --mem=1000G 
#SBATCH --partition=lab-mpinsky
#SBATCH --qos=pi-mpinsky
#SBATCH --account=pi-mpinsky

module load bcftools 
module load vcftools/0.1.16
module load parallel/20200122
module list 

VCF_PATTERN="MpyrAdapt_annotated_*.vcf.gz"
OUTDIR="/home/miclark/MpyrAdapt/data/variants/filtering/annotated_depth"
INDIR="/hb/scratch/miclark/MpyrAdapt/variants/annotatedVCFs"

# all sites 
export OUTDIR
parallel -j32 '
    CHROM=$(basename {} .vcf.gz | sed "s/MpyrAdapt_annotated_//")
    vcftools --gzvcf {} --depth --out  ${OUTDIR}/annotated_depth_${CHROM}

' ::: ${INDIR}/$VCF_PATTERN

# PASS sites
#export OUTDIR
#parallel -j32 '
#    CHROM=$(basename {} .vcf.gz | sed "s/MpyrAdapt_annotated_//")
#    vcftools --gzvcf {} --remove-filtered-all --depth --out  ${OUTDIR}/annotated_depth_${CHROM}
#
#' ::: ${INDIR}/$VCF_PATTERN

## END SCRIPT