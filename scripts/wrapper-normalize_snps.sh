#!/bin/bash
		
# wrapper-normalize_variants.sh		
# This script starts an array job normalize variants in raw bcf files
# The array job will start one job per BCF in bcflist
# Last updated 03/13/2026 by MI Clark, script format inspired by R Toczydlowski 

#  run from project directory (where you want output directory to be created)


# define high level vars
jobname=bcf_norm
date=$(date +%m%d%Y)

#define dirs:
indir="/hb/scratch/miclark/MpyrAdapt/variants/rawBCFs"
outdir="/hb/scratch/miclark/MpyrAdapt/variants/normBCFs"
logfilesdir="/home/miclark/MpyrAdapt/logs/${jobname}"

#check if directories have been created yet; if not, make one
if [ ! -d $logfilesdir ]; then mkdir $logfilesdir; fi
if [ ! -d $outdir ]; then mkdir $outdir; fi

array_key="/home/miclark/MpyrAdapt/scripts/chrom_list.txt" # list of chromosomes in the reference genome

# define slurm job details
cpus=6
total_mem=50G
array_no=$(cat $array_key | wc -l) 

# define executable and reference files
executable=/home/miclark/MpyrAdapt/scripts/normalize_snps.sbatch #script to run 
reference=/home/miclark/MpyrAdapt/data/reference/Mpyr-NLJ1B.v3.hap1.softmasked.fasta #filepath of reference file

sbatch --job-name=$jobname \
		--array=1-$array_no \
		--export=REFERENCE=$reference,CPUS=$cpus,ARRAY_KEY=$array_key,RUN_NAME=$run_name,LOGFILESDIR=$logfilesdir,DATE=$date,INDIR=$indir,OUTDIR=$outdir \
		--cpus-per-task=$cpus \
		--mem=$total_mem \
		--output=$logfilesdir/${jobname}_${date}_%A-%a.out \
		--error=$logfilesdir/${jobname}_${date}_%A-%a.err \
		--time=96:00:00 \
		$executable

echo I submitted to normalize my bcf files!
echo ----------------------------------------------------------------------------------------

