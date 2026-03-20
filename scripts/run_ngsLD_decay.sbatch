#!/bin/bash

#SBATCH --job-name=ngsLD
#SBATCH --output /home/miclark/MpyrAdapt/logs/ngsLD-%j.out
#SBATCH --error /home/miclark/MpyrAdapt/logs/ngsLD-%j.err
#SBATCH --cpus-per-task=8
#SBATCH --time=12:00:00
#SBATCH --mem=120G 


# Script written by M. Clark, 2/24/2023
# updated 03/18/2026
# This script runs ngs LD on a subset of SNPs to get LD curve 

# usage: 
# run_ngsLD_decay.sbatch

module load ngsld/1.2.0
module list

DIR=/home/miclark/MpyrAdapt/data/geno_likelihoods
OUTDIR=${DIR}/LD_decay
SCRIPT_DIR=/hb/software/apps/ngsld/gnu13-1.2.0/share/scripts/

if [ ! -d $OUTDIR ]; then mkdir -p $OUTDIR; fi

# subsample beagle and pos files together
zcat $DIR/Mpyr_north_gl.mafs.gz | cut -f 1,2 | tail -n +2 | gzip > $DIR/all_sites.pos.gz
zcat $DIR/Mpyr_north_gl.beagle.gz | awk 'NR % 50 == 0' | cut -f 4- | gzip > $DIR/subsampled.beagle.gz
zcat $DIR/all_sites.pos.gz | awk 'NR % 50 == 0' | gzip > $DIR/subsampled.pos.gz

N_SITES=$(zcat $DIR/subsampled.pos.gz | wc -l)

echo I found $N_SITES

ngsLD \
    --geno $DIR/subsampled.beagle.gz \
    --pos $DIR/subsampled.pos.gz \
    --probs \
    --n_ind 158 \
    --n_sites $N_SITES \
    --max_kb_dist 200 \
    --n_threads 8 \
    --out $OUTDIR/ld_decay.out
echo done running ngsLD

# plot decay 

module load r 

Rscript --vanilla ${SCRIPT_DIR}/fit_LDdecay.R \
    --ld_files ${OUTDIR}/ld_file.txt \
    --n_ind 158 \
    --ld r2 \
    --fit_level 3 \
    --plot_data \
    --plot_bin_size 1000 \
    --plot_x_lim 12\
    --out ${OUTDIR}/ld_decay_fit.pdf

# END SCRIPT
