#!/bin/bash
		
# wrapper-annotateVCF.sh		
# This script starts an array job to annotate 
# The array job will start one job per BCF in bcflist
# Last updated 13/16/2024 by MI Clark, script format inspired by R Toczydlowski 

# define high level vars
jobname=annotateVCF
date=$(date +%m%d%Y)

#define dirs:
logfilesdir="/home/miclark/MpyrAdapt/logs/${jobname}"
indir="/hb/scratch/miclark/MpyrAdapt/variants/normBCFs"
outdir="/hb/scratch/miclark/MpyrAdapt/variants/annotatedVCFs"
maskdir="/home/miclark/MpyrAdapt/data/variants/masks"
groupfile='/home/miclark/MpyrAdapt/scripts/Mpyr_groups_qc.txt' # CHECK THAT THIS MATCHES ORDER OF INDIVIDUALS IN BCF
	# group file contains four columns: #GROUP	INDEX	MIN_GQ	MIN_DP
		# group code, usually population code 
		# index is a comma-separated list of the 0-based indices of samples in the BCF that belong to that group
		# minimum genotype quality and depth for that group (e.g., 15, 5) 

#check if directories has been created in submit dir yet; if not, make one
if [ ! -d $logfilesdir ]; then mkdir $logfilesdir; fi
if [ ! -d $outdir ]; then mkdir $outdir; fi

array_key="/home/miclark/MpyrAdapt/scripts/chrom_list.txt" # list of chromosomes in the reference genome

# define slurm job details
cpus=1
total_mem=12G
array_no=$(cat $array_key | wc -l) 

# define executable and variables to import to executable
executable=/home/miclark/MpyrAdapt/scripts/annotate_VCF.sbatch #script to run 
script='/home/miclark/MpyrAdapt/scripts/insertAnnotations_Mpyr.pl' 

sbatch --job-name=$jobname \
		--array=1-$array_no \
		--export=CPUS=$cpus,ARRAY_KEY=$array_key,LOGFILESDIR=$logfilesdir,DATE=$date,SCRIPT=$script,INDIR=$indir,OUTDIR=$outdir,MASKDIR=$maskdir,GRPFILE=$groupfile \
		--cpus-per-task=$cpus \
		--mem=$total_mem \
		--output=$logfilesdir/${jobname}_${date}_%A-%a.out \
		--error=$logfilesdir/${jobname}_${date}_%A-%a.err \
		--time=24:00:00 \
		$executable

echo I submitted to annotate my bcf file!
echo ----------------------------------------------------------------------------------------

