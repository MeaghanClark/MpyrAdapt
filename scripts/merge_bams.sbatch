#!/bin/bash

#SBATCH --job-name=merge_bams
#SBATCH --output /home/miclark/MpyrAdapt/logs/merge_bams-%j.out
#SBATCH --error /home/miclark/MpyrAdapt/logs/merge_bams-%j.err
#SBATCH --cpus-per-task=12
#SBATCH --mem=75G 
#SBATCH --time=24:00:00

############# merge_bams.sbatch  ###################

# This script merges bam files 
# Last updated 04/13/2026 by MI Clark,based on script by T Linderoth

# Output: merged MEGA bam file in scratch directory 

#load modules
module load bcftools/1.21
module list 

# define variables
REFERENCE=/home/miclark/MpyrAdapt/data/reference/Mpyr-NLJ1B.v3.hap1.softmasked.fasta #filepath of reference file
BAMS=/home/miclark/MpyrAdapt/scripts/bam_list.txt # text file with paths to bam files to merge, one per line
OUTFILE=/hb/scratch/miclark/MpyrAdapt/alignments/MpyrAdapt_merged.bam 

CMD="samtools merge -O BAM --reference $REFERENCE -b $BAMS -o $OUTFILE -@ 11"

printf "\n%s\n\n" "$CMD"

eval $CMD

wait

samtools index -@ 11 "$OUTFILE"

#print some environment variables to stdout for records
echo ----------------------------------------------------------------------------------------
echo PRINTING SUBSET OF ENVIRONMENT VARIABLES:
(set -o posix ; set | grep -v ^_ | grep -v ^EB | grep -v ^BASH | grep -v PATH | grep -v LS_COLORS)

echo ----------------------------------------------------------------------------------------
seff ${SLURM_JOBID}
