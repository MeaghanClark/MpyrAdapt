#!/bin/bash
		
# wrapper-gen_masks.sh		
# This script starts an array job to run gen_masks in an array job
# The array job will start one job per chromosome grouping
# Last updated 03/13/2026 by MI Clark, script format inspired by R Toczydlowski and T Linderoth

#  run from project directory (where you want output directory to be created)

# define high level vars
date=$(date +%m%d%Y)
jobname=gen_PF_mask

# define dirs
indir="/home/miclark/MpyrAdapt/data/alignments/bamstats/" # path to bamstats files
outdir="/home/miclark/MpyrAdapt/data/variants/masks/"  # path to output pass/fail masks and reports
logfilesdir="/home/miclark/MpyrAdapt/logs/${jobname}"

#check if directories have been created yet; if not, make one
if [ ! -d $logfilesdir ]; then mkdir $logfilesdir; fi
if [ ! -d $outdir ]; then mkdir $outdir; fi
if [ ! -d ${outdir}/reports ]; then mkdir ${outdir}/reports; fi

array_key="/home/miclark/MpyrAdapt/scripts/chrom_list.txt" # list of chromosomes in the reference genome

# define running vars
cpus=1
total_mem=24G
array_no=$(cat $array_key | wc -l) #***

# define executable, reference and needed scripts
executable=/home/miclark/MpyrAdapt/scripts/generate_PF_masks.sbatch
script=/home/miclark/MpyrAdapt/scripts/bedmask.pl

sbatch --job-name=$jobname \
        --array=1-$array_no \
        --export=OUTDIR=$outdir,INDIR=$indir,CPUS=$cpus,LOGFILESDIR=$logfilesdir,DATE=$date,ARRAY_KEY=$array_key,SCRIPT=$script \
        --cpus-per-task=$cpus \
        --mem=$total_mem \
        --output=$logfilesdir/${jobname}_%A-%a.out \
        --error=$logfilesdir/${jobname}_%A-%a.err \
        --time=24:00:00 \
        $executable

echo I submitted an array job to generate quality control masks!
echo ----------------------------------------------------------------------------------------

