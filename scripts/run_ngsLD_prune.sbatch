#!/bin/bash

#SBATCH --job-name=ngsLD
#SBATCH --output /home/miclark/MpyrAdapt/logs/ngsLD-%j.out
#SBATCH --error /home/miclark/MpyrAdapt/logs/ngsLD-%j.err
#SBATCH --cpus-per-task=8
#SBATCH --time=24:00:00
#SBATCH --mem=500G 
#SBATCH --partition=lab-mpinsky
#SBATCH --qos=pi-mpinsky
#SBATCH --account=pi-mpinsky

# Script written by M. Clark, 2/24/2023
# updated 03/18/2026
# This script runs LD prunes a set of genotype likelihoods

# usage: 
# run_ngsLD_prune.sbatch

module load ngsld/1.2.0
module list

DIR=/home/miclark/MpyrAdapt/data/geno_likelihoods
OUTDIR=${DIR}/LD_pruned_randomSamp
SCRIPT_DIR=/home/miclark/software/ngsLD/scripts

if [ ! -d $OUTDIR ]; then mkdir -p $OUTDIR; fi

# zcat $DIR/Mpyr_north_gl.mafs.gz | cut -f 1,2 | tail -n +2 | awk '{print $1":"$2}' | gzip > $DIR/all_sites.pos.gz

N_SITES=$(zcat $DIR/all_sites.pos.gz | wc -l)
MAX_KB_DIST=5 # informed by run_ngsLD_decay.sbatch
MAX_BP_DIST=$((MAX_KB_DIST * 1000))


ngsLD \
--geno $DIR/Mpyr_north_gl.beagle.gz \
--pos $DIR/all_sites.pos.gz \
--probs \
--n_ind 158 \
--n_sites $N_SITES \
--rnd_sample 0.01 \
--max_kb_dist $MAX_KB_DIST \
--n_threads 8 \
--out $OUTDIR/Mpyr_gl_pruned.ld 

## remove the header line from LD estimates (because the python script had issues with it)
#tail -n +2 $OUTDIR/Mpyr_gl_pruned.ld > $OUTDIR/Mpyr_gl_subsampled.noheader.ld

## run LD pruning script
# perl ${SCRIPT_DIR}/prune_graph.pl \
#    --in_file $OUTDIR/Mpyr_gl_pruned.ld \
#    --field_dist 3 \
#    --max_kb_dist $MAX_KB_DIST \
#    --field_weight 4 \
#    --min_weight 0.5 \
#    --out $OUTDIR/Mpyr_gl_unlinked.id

conda activate ngsld_deps

python ${SCRIPT_DIR}/prune_ngsLD_fixed.py \
    --input $OUTDIR/Mpyr_gl_pruned.ld \
    --field_dist 3 \
    --field_weight 4 \
    --max_dist $MAX_BP_DIST \
    --min_weight 0.5 \
    --output $OUTDIR/Mpyr_gl_unlinked.id
echo done! 

## DONE