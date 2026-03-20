#!/bin/bash
		
# wrapper-extract_pos_qc_SNPs.sh		
# This script starts an array job to run extract_pos_qc_SNPs.sbatch in an array job
# The array job will start one job per chromosome grouping
# Last updated 03/17/2026 by MI Clark, script format inspired by R Toczydlowski and T Linderoth

#  run from project directory (where you want output directory to be created)

# define high level vars
date=$(date +%m%d%Y)
jobname=extract_pos

# define dirs
indir="/hb/scratch/miclark/MpyrAdapt/variants/annotatedVCFs" # path to annotated vcf files
outdir="/home/miclark/MpyrAdapt/data/variants/masks/qc_sites"  # path to output qc_SNP masks
logfilesdir="/home/miclark/MpyrAdapt/logs/${jobname}"

#check if directories have been created yet; if not, make one
if [ ! -d $logfilesdir ]; then mkdir $logfilesdir; fi
if [ ! -d $outdir ]; then mkdir $outdir; fi

array_key="/home/miclark/MpyrAdapt/scripts/chrom_list.txt" # list of chromosomes in the reference genome
inds="/home/miclark/MpyrAdapt/scripts/pass_depth_inds.txt" # list of individuals who passed depth QC 

# define running vars
cpus=1
total_mem=24G
array_no=$(cat $array_key | wc -l) #***

# define executable, reference and needed scripts
executable=/home/miclark/MpyrAdapt/scripts/extract_pos_qc_sites.sbatch

sbatch --job-name=$jobname \
        --array=1-$array_no \
        --export=OUTDIR=$outdir,INDIR=$indir,CPUS=$cpus,LOGFILESDIR=$logfilesdir,DATE=$date,ARRAY_KEY=$array_key,INDS=$inds \
        --cpus-per-task=$cpus \
        --mem=$total_mem \
        --output=$logfilesdir/${jobname}_%A-%a.out \
        --error=$logfilesdir/${jobname}_%A-%a.err \
        --time=24:00:00 \
        $executable

echo I submitted an array job to generate position files detailing QC SNPs!
echo ----------------------------------------------------------------------------------------

