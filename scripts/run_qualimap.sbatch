#!/bin/bash

# run_qualimap.sbatch
# This script uses qualimap to generate alignment statistics for a given sample.
# Last updated 03/02/2026 by MI Clark

#--------------- EXECUTABLE ---------------

# Input: Reference genome path, forward and reverse reads from wrapper-align_to_genome.sh 
#
# Output: ${SAMPLE_NAME}.trim.bam file, forward and reverse reads aligned to reference genome and trimmed

# activate conda environment
module load miniconda3
conda activate qualimap

SAMPLE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" $ARRAY_KEY)
BAM="${INDIR}/${SAMPLE}.bam"
SAMPLEDIR="${OUTDIR}/${SAMPLE}"
# run qualimap 

# java-mem-size should be ~75% of requested RAM
qualimap bamqc \
    -bam "${BAM}" \
    -outdir "${SAMPLEDIR}" \
    -outformat HTML \
    --java-mem-size=12G \
    -nt "${SLURM_CPUS_PER_TASK}" \
    --cov-hist-lim 2000 \
    --collect-overlap-pairs \
    --paint-chromosome-limits

echo "Done with ${SAMPLE}"

## END SCRIPT
 

