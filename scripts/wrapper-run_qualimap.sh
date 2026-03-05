#!/bin/bash

# wrapper-run_qualimap.sh 
# This script starts an array job to run qualimap on bam files generated from wrapper-align_to_genome.sh.
# Last updated 03/02/2026 by MI Clark

# define high level variables
date=$(date +%m%d%Y)
echo running on $date 
jobname=qualimap

#define dirs:
indir="/home/miclark/MpyrAdapt/data/alignments" # name of directory with the alignments to run qualimap on
outdir="/home/miclark/MpyrAdapt/data/alignments/QC" # name of directory where qualimap reports can live
logfilesdir="/home/miclark/MpyrAdapt/logs/qualimap" #name of directory to create and then write log files to

#check if directories have been created; if not, make 
if [ ! -d $logfilesdir ]; then mkdir $logfilesdir; fi
if [ ! -d $outdir ]; then mkdir $outdir; fi
if [ ! -d $scratchnode ]; then mkdir $scratchnode; fi

# make alignment key
# this file should be a list of sample names
# e.g., 
# ind1	ind2    ind3    ind4
array_key="/home/miclark/MpyrAdapt/scripts/qualimap_key.txt"

SAMPLE_LIST=()
while IFS= read -r line; do
    SAMPLE_LIST+=("$line")
done < <(find "${indir}" -maxdepth 1 -name "*.bam" | xargs -n1 basename | sed 's/\.bam$//' | sort)
printf '%s\n' "${SAMPLE_LIST[@]}" > $array_key

echo "Found ${#SAMPLE_LIST[@]} samples"

# define slurm job details
cpus=1 #number of CPUs to request/use per dataset
ram_per_cpu=16G #amount of RAM to request/use per CPU CHANGE
array_no=$(cat $array_key | wc -l) # number of array jobs to run 

# define executable and reference genome 
executable=/home/miclark/MpyrAdapt/scripts/run_qualimap.sbatch #script to run 

#---------------------------------------------------------

#submit job to cluster
sbatch --job-name=$jobname \
	--array=1-$array_no%50 \
	--export=ARRAY_KEY=$array_key,CPUS=$cpus,INDIR=$indir,OUTDIR=$outdir,LOGFILESDIR=$logfilesdir \
	--cpus-per-task=$cpus \
	--mem-per-cpu=$ram_per_cpu \
	--output=$logfilesdir/${jobname}_${date}_%A-%a.out \
	--error=$logfilesdir/${jobname}_${date}_%A-%a.err \
	--time=4:00:00 \
    --partition=lab-mpinsky \
    --qos=pi-mpinsky \
    --account=pi-mpinsky \
	$executable
		
echo submitted $array_no jobs to run qualimap on bams in $indir

echo ----------------------------------------------------------------------------------------
echo My executable is $executable		

