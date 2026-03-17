#!/bin/bash
		
# wrapper-call_snps.sh		
# This script starts an array job to call SNPs on different chromosomes
# Last updated 03/13/2026 by MI Clark for running on elkhorn, originally written by R Toczydlowski 

#  run from project directory (where you want output directory to be created)

# define high level variables
date=$(date +%m%d%Y)
jobname=call_snps #label for SLURM book-keeping 

#define dirs:
indir="/home/miclark/MpyrAdapt/data/alignments"
outdir="/hb/scratch/miclark/MpyrAdapt/variants/rawBCFs"
logfilesdir="/home/miclark/MpyrAdapt/logs/${jobname}"

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

# define slurm job details
cpus=1 #number of CPUs to request/use per dataset 
ram_per_cpu=12G #amount of RAM to request/use per CPU
array_no=$(cat $array_key | wc -l) #***

# define executable and reference genome 
executable=/home/miclark/MpyrAdapt/scripts/call_snps.sbatch #script to run 
reference=/home/miclark/MpyrAdapt/data/reference/Mpyr-NLJ1B.v3.hap1.softmasked.fasta #filepath of reference file

bamlist="/home/miclark/MpyrAdapt/scripts/bam_list.txt"
sample_list="/home/miclark/MpyrAdapt/scripts/bam_sample_list.txt"

# make sample names
SAMPLE_LIST=()
while IFS= read -r line; do
    SAMPLE_LIST+=("$line")
done < <(cat $bamlist | xargs -n1 basename | sed 's/\.rmdup.bam$//')
printf '%s\n' "${SAMPLE_LIST[@]}" > $sample_list

#---------------------------------------------------------

# Required explore variables to sbatch
#	(1) reference
#	(2) list of bamfiles
#	(3) OUTDIR

#submit job to cluster

sbatch --job-name=$jobname \
		--array=1-$array_no \
		--export=REFERENCE=$reference,CPUS=$cpus,BAMLIST=$bamlist,SAMPLE_LIST=$sample_list,OUTDIR=$outdir,LOGFILESDIR=$logfilesdir,ARRAY_KEY=$array_key \
		--cpus-per-task=$cpus \
		--mem-per-cpu=$ram_per_cpu \
		--output=$logfilesdir/${jobname}_${date}_%A-%a.out \
		--error=$logfilesdir/${jobname}_${date}_%A-%a.err \
		--time=72:00:00 \
		$executable
			
echo I submitted to call SNPs woohoo!
echo ----------------------------------------------------------------------------------------

