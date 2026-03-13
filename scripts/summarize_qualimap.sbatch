#!/bin/bash

#SBATCH --job-name=sum_qual
#SBATCH --output /home/miclark/MpyrAdapt/logs/qualimap/sum_qual-%j.out
#SBATCH --error /home/miclark/MpyrAdapt/logs/qualimap/sum_qual-%j.err
#SBATCH --cpus-per-task=1
#SBATCH --time=24:00:00
#SBATCH --mem=50G 
#SBATCH --partition=lab-mpinsky
#SBATCH --qos=pi-mpinsky
#SBATCH --account=pi-mpinsky


############# summarize_qualimap.sbatch  ###################
## runs MultiQC 
##  mic updated this 2026-03-04 for UCSC hb    

## This script summarizes qualimap output from wrapper-run_qualimap.sh and run_qualimap.sbatch with MultiQC

# load multiqc 
module load multiqc/1.27
module list

INDIR=/home/miclark/MpyrAdapt/data/alignments/QC
OUTDIR=/home/miclark/MpyrAdapt/data/alignments/QC
REPORTNAME="qualimap_multiqc_report.html"
CONFIG="/home/miclark/MpyrAdapt/scripts/qualimap_multiqc_config.yml"

# run multiqc with specific report and subdirectory names
multiqc -v -p -ip -f \
    --data-dir \
    --data-format tsv \
    --cl-config "max_table_rows: 3000" \
    --filename "$REPORTNAME" \
    --outdir "$OUTDIR" "$INDIR"

# run multiqc again to get full coverage histogram file 
multiqc -v -p -ip -f \
    --data-dir \
    --data-format tsv \
    --cl-config "max_table_rows: 3000" \
    --filename "fullcoverage_qualimap_report.html" \
    -c "$CONFIG" \
    --outdir "$OUTDIR" "$INDIR"


#print some environment variables to stdout for records
echo ----------------------------------------------------------------------------------------
echo "Job ID: ${SLURM_JOBID}"
echo ----------------------------------------------------------------------------------------

# END SCRIPT