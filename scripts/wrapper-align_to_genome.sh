#!/bin/bash

# wrapper-align_to_genome.sh 
# This script starts an array job to align trimmed and QC'd sequencing reads to a reference genome
# Last updated 03/02/2026 by MI Clark, originally written by R Toczydlowski 

# define high level variables
date=$(date +%m%d%Y)
echo running on $date 
jobname=align

# this should be a tab-separated text file with no header. Each line contains the merged and unpaired forward/reverse read information for one individual.
# file should end with a line break
# e.g., 
# ind1	ind1.1.fq.gz	ind1.2.fq.gz	ind1_mrg.fq.gz
# ind2	ind2.1.gq.gz	ind2.2.fq.gz	ind2_mrg.fq.gz
array_key=/home/miclark/MpyrAdapt/scripts/alignment_key.txt

#define dirs:
outdir="/home/miclark/MpyrAdapt/data/alignments" # name of directory where final alignments can live
scratchnode="/hb/scratch/miclark/MpyrAdapt/alignments" # name of directory where intermediate files can live
logfilesdir="/home/miclark/MpyrAdapt/logs/alignments" #name of directory to create and then write log files to

#check if directories have been created; if not, make 
if [ ! -d $logfilesdir ]; then mkdir $logfilesdir; fi
if [ ! -d $outdir ]; then mkdir $outdir; fi
if [ ! -d $scratchnode ]; then mkdir $scratchnode; fi

# define slurm job details
cpus=2 #number of CPUs to request/use per dataset
ram_per_cpu=25G #amount of RAM to request/use per CPU CHANGE
array_no=$(cat $array_key | wc -l) # number of array jobs to run 

# define executable and reference genome 
executable=/home/miclark/MpyrAdapt/scripts/align_to_genome.sbatch #script to run 
reference=/home/miclark/MpyrAdapt/data/reference/Mpyr-NLJ1B.v3.hap1.softmasked.fasta #filepath of reference file

#---------------------------------------------------------
# required exports to executable: 
#	ARRAY_KEY
# 	REFERENCE
# 	CPUS
#	OUTDIR
#	INDIR
#	SCRATCHNODE

#submit job to cluster
sbatch --job-name=$jobname \
	--array=94-188%10 \
	--export=ARRAY_KEY=$array_key,REFERENCE=$reference,CPUS=$cpus,SCRATCHNODE=$scratchnode,OUTDIR=$outdir,LOGFILESDIR=$logfilesdir \
	--cpus-per-task=$cpus \
	--mem-per-cpu=$ram_per_cpu \
	--output=$logfilesdir/${jobname}_${date}_%A-%a.out \
	--error=$logfilesdir/${jobname}_${date}_%A-%a.err \
	--time=168:00:00 \
    --partition=lab-mpinsky \
    --qos=pi-mpinsky \
    --account=pi-mpinsky \
	$executable
		
echo submitted a job to align reads in $indir to $reference

echo ----------------------------------------------------------------------------------------
echo My executable is $executable		

