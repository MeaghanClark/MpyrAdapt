#!/bin/bash

# bam_depth.sbatch
# This script uses samtools depth to caluclate cumulative per-site depth from aligned bam files.
# Last updated 03/12/2026 by MI Clark

#--------------- EXECUTABLE ---------------

# activate conda environment
module load samtools

CHROM=$(sed -n "${SLURM_ARRAY_TASK_ID}p" $ARRAY_KEY)

# calcualte depth on a given scaffold for all individuals in BAMLIST
samtools depth -f $BAMLIST -r $CHROM | awk '{ sum = 0; for (i = 3; i <= NF; i++) sum += $i; print $1, $2, sum }' > ${OUTDIR}/${CHROM}_depth_summary.txt

echo "Done with ${CHROM}"

## END SCRIPT
 

