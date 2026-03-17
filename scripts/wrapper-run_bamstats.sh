#!/bin/bash

# wrapper-run_bamstats.sh
# This script starts an array job to run bamstats on bamfiles
# Last updated 03/13/2026 by MI Clark, script format by R Toczydlowski 

#  run from project directory (where you want output directory to be created)

# define high level vars
date=$(date +%m%d%Y)
jobname=bamstats
bamstats="/home/miclark/software/ngsQC/bamstats/bamstats"

# define dirs
logfilesdir="/home/miclark/MpyrAdapt/logs/${jobname}"
outdir="/home/miclark/MpyrAdapt/data/alignments/bamstats"

#check if directories have been created; if not, make 
if [ ! -d $logfilesdir ]; then mkdir $logfilesdir; fi
if [ ! -d $outdir ]; then mkdir $outdir; fi

# alignment key
# this file should be a list of chromosomes from the reference genome
# e.g., 
# chrom1
# chrom2
# chrom3

array_key="/home/miclark/MpyrAdapt/scripts/chrom_list.txt" # list of chromosomes in the reference genome

# define running vars
cpus=1
ram_per_cpu=25G
array_no=$(cat $array_key | wc -l)

inbam=/hb/scratch/miclark/MpyrAdapt/alignments/MpyrAdapt_merged.bam # path to merged bam file to run bamstats on
executable=/home/miclark/MpyrAdapt/scripts/run_bamstats.sbatch #script to run 
reference=/home/miclark/MpyrAdapt/data/reference/Mpyr-NLJ1B.v3.hap1.softmasked.fasta #filepath of reference file

sbatch --job-name=$jobname \
        --array=1-$array_no \
        --export=REFERENCE=$reference,CPUS=$cpus,BAMSTATS=$bamstats,ARRAY_KEY=$array_key,LOGFILESDIR=$logfilesdir,OUTDIR=$outdir,INBAM=$inbam,DATE=$date \
        --cpus-per-task=$cpus \
        --mem-per-cpu=$ram_per_cpu \
        --output=$logfilesdir/${jobname}_%A-%a.out \
        --error=$logfilesdir/${jobname}_%A-%a.err \
        --time=48:00:00 \
        $executable

echo I submitted an array job to run bamstats!
echo ----------------------------------------------------------------------------------------

