#!/bin/bash

# wrapper-bam_depth.sh 
# This script starts an array job to calculate cumulative per-site depth from aligned bam files
# Last updated 03/12/2026 by MI Clark

# define high level variables
date=$(date +%m%d%Y)
echo running on $date 
jobname=bamDepth

#define dirs:
indir="/home/miclark/MpyrAdapt/data/alignments" # name of directory with the alignments to run qualimap on
outdir="/home/miclark/MpyrAdapt/data/alignments/depth" # name of directory where qualimap reports can live
logfilesdir="/home/miclark/MpyrAdapt/logs/bam_depth" #name of directory to create and then write log files to

#check if directories have been created; if not, make 
if [ ! -d $logfilesdir ]; then mkdir $logfilesdir; fi
if [ ! -d $outdir ]; then mkdir $outdir; fi
if [ ! -d $scratchnode ]; then mkdir $scratchnode; fi

# make alignment key
# this file should be a list of chromosomes from the reference genome
# e.g., 
# chrom1
# chrom2
# chrom3

array_key="/home/miclark/MpyrAdapt/scripts/chrom_list.txt" # list of chromosomes in the reference genome

bamlist="/home/miclark/MpyrAdapt/scripts/bam_list.txt"

# generate list of bam files
SAMPLE_LIST=()
while IFS= read -r line; do
    SAMPLE_LIST+=("$line")
done < <(find "${indir}" -maxdepth 1 -name "*.bam" | sort)
printf '%s\n' "${SAMPLE_LIST[@]}" > $bamlist

echo "Found ${#SAMPLE_LIST[@]} samples"

# define slurm job details
cpus=1 #number of CPUs to request/use per dataset
ram_per_cpu=20G #amount of RAM to request/use per CPU CHANGE
array_no=$(cat $array_key | wc -l) # number of array jobs to run 

# define executable and reference genome 
executable=/home/miclark/MpyrAdapt/scripts/bam_depth.sbatch #script to run 

#---------------------------------------------------------

#submit job to cluster
sbatch --job-name=$jobname \
	--array=1-$array_no%100 \
	--export=ARRAY_KEY=$array_key,BAMLIST=$bamlist,CPUS=$cpus,INDIR=$indir,OUTDIR=$outdir,LOGFILESDIR=$logfilesdir \
	--cpus-per-task=$cpus \
	--mem-per-cpu=$ram_per_cpu \
	--output=$logfilesdir/${jobname}_${date}_%A-%a.out \
	--error=$logfilesdir/${jobname}_${date}_%A-%a.err \
	--time=12:00:00 \
	$executable
		
echo submitted $array_no jobs to run qualimap on bams in $indir

echo ----------------------------------------------------------------------------------------
echo My executable is $executable		

