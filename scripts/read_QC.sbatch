#!/bin/bash

#SBATCH --job-name=Multi_fastqc
#SBATCH --output /home/miclark/MpyrAdapt/logs/read_QC-%j.out
#SBATCH --error /home/miclark/MpyrAdapt/logs/read_QC-%j.err
#SBATCH --cpus-per-task=32
#SBATCH --time=24:00:00
#SBATCH --mem=150G 
#SBATCH --partition=lab-mpinsky
#SBATCH --qos=pi-mpinsky
#SBATCH --account=pi-mpinsky


############# read_QC.sbatch  ###################
## runs FASTQC and MultiQC reports in parallel 
##  based on a script by Eric Garcia, e1garcia@odu.edu 
##  mic updated this 2026-02-25 for UCSC hb    

## This script runs fastQC, summarizes output with MultiQC, and calculates the percent of adapter dimer in the reads. 

## Requirements: parallel, fastqc, and multiqc in current session 
## To execute, type in the command line (do include quotes):
# sbatch read_QC.sbatch "<full path to directory with the files to be processed>" "<report name>"

# load modules
module load parallel/20200122
module load fastqc/0.12.1
module list 

# define variables
#inDIR=$(echo $1 | sed 's/\\/$//')
inDIR=$1
REPORTNAME=$2
PATTERN=".fastq.gz" # change to match file extension or regex pattern that identifies the files to be processed
CPUS=32 # change to match number of cpus requested in slurm settings

#run fastqc in parallel 
ls ${inDIR}/*${PATTERN} | parallel --no-notice -j ${CPUS} "fastqc {}" 

# load multiqc 
module unload fastqc/0.12.1
module load multiqc/1.27

# run multiqc with specific report and subdirectory names
multiqc -v -p -ip -f --data-dir --data-format tsv --cl-config "max_table_rows: 3000" --filename $REPORTNAME --outdir $inDIR $inDIR

# move fastqc files to new subdirectory
OUTDIR=${inDIR}/read_QC

ls ${inDIR}/*fastqc.html | parallel -kj $CPUS "mv {} ${OUTDIR}" &&
ls ${inDIR}/*fastqc.zip | parallel -kj $CPUS "mv {} ${OUTDIR}"
mv ${inDIR}/${REPORTNAME}.html ${OUTDIR}

# calculate % adapter dimer
adapter_dimer() {
    file="$1"
    adapter=$(zcat "$file" | grep -c '^AGATCGGAAG')
    total_lines=$(zcat "$file" | wc -l)
    total_reads=$((total_lines / 4))
    pct=$(echo "scale=2; 100 * $adapter / $total_reads" | bc)
    echo -e "$file\t$adapter\t$total_reads\t$pct%"
}

export -f adapter_dimer

echo -e "File\tAdapter_Dimers\tTotal_Reads\tPct_Adapter" > ${OUTDIR}/${REPORTNAME}_adapter_report.txt

parallel --no-notice -j${CPUS} adapter_dimer {} ::: *.fastq.gz >> ${OUTDIR}/${REPORTNAME}_adapter_report.txt

#print some environment variables to stdout for records
echo ----------------------------------------------------------------------------------------
echo PRINTING SUBSET OF ENVIRONMENT VARIABLES:
(set -o posix ; set | grep -v ^_ | grep -v ^EB | grep -v ^BASH | grep -v PATH | grep -v LS_COLORS)

echo ----------------------------------------------------------------------------------------
seff ${SLURM_JOBID}

# END SCRIPT