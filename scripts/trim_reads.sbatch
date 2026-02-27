#!/bin/bash

#SBATCH --job-name=fastp
#SBATCH --output /hb/home/miclark/kelpEVOL_fq_gz_processing/logs/trim_reads-%j.out
#SBATCH --error /hb/home/miclark/kelpEVOL_fq_gz_processing/logs/trim_reads-%j.err
#SBATCH --cpus-per-task=32 
#SBATCH --time=72:00:00 
#SBATCH --mem=75G 
#SBATCH --partition=lab-mpinsky
#SBATCH --qos=pi-mpinsky
#SBATCH --account=pi-mpinsky

######## runFASTP_1st_trim.sbatch
## runs FASTP to do read trimming             
##  mic updated this 2025-03-24 for UCSC hb    

# this script will do all trimming, except 5'
# overlapping reads are merged and output separately
# this is first step in prepping reads for de novo assembly

module load parallel/20200122
module load fastp/0.23.2
module list 

# define key variables
INDIR=/home/miclark/MpyrAdapt/data/raw
OUTDIR=/home/miclark/MpyrAdapt/data/processed
FQPATTERN=*.fastq.gz
EXTPATTERN='_[0-9]\.fastq\.gz$'  # pattern match to fq extensions
FWDEXT=_1.fastq.gz
REVEXT=_2.fastq.gz
THREADS=16 

if [ ! -d $OUTDIR ]; then mkdir $OUTDIR; fi
if [ ! -d $OUTDIR/failed ]; then mkdir $OUTDIR/failed; fi
if [ ! -d $OUTDIR/merged ]; then mkdir $OUTDIR/merged; fi
if [ ! -d $OUTDIR/unmerged ]; then mkdir $OUTDIR/unmerged; fi
if [ ! -d $OUTDIR/QC ]; then mkdir $OUTDIR/QC; fi

FILES=$(ls $INDIR/$FQPATTERN | \
	sed -E "s/$EXTPATTERN//" | sed 's#.*/##' | \
	uniq)
echo $FILES 

ls $INDIR/$FQPATTERN | \
	sed -E "s/$EXTPATTERN//" | sed 's#.*/##' | \
	uniq | \
	parallel --no-notice -j $THREADS \
	fastp \
		--in1 $INDIR/{}$FWDEXT \
		--in2 $INDIR/{}$REVEXT \
		--out1 $OUTDIR/unmerged/{}_r1.fq.gz \
		--out2 $OUTDIR/unmerged/{}_r2.fq.gz \
		--unpaired1 $OUTDIR/failed/{}_unprd.fq.gz \
		--unpaired2 $OUTDIR/failed/{}_unprd.fq.gz \
		--failed_out $OUTDIR/failed/{}_fail.fq.gz \
		--merge \
		--merged_out $OUTDIR/merged/{}_mrg.fq.gz \
		-h $OUTDIR/QC/{}_fastp.html \
		-j $OUTDIR/QC/{}_fastp.json \
		--qualified_quality_phred 20 \
		--unqualified_percent_limit 40 \
		--length_required 75 \
		--low_complexity_filter \
		--complexity_threshold 30 \
		--detect_adapter_for_pe \
		--adapter_sequence=TCGTCGGCAGCGTCAGATGTGTATAAGAGACAG \
		--adapter_sequence_r2=GTCTCGTGGGCTCGGAGATGTGTATAAGAGACAG \
		--cut_tail \
		--cut_tail_window_size 1 \
		--cut_tail_mean_quality 20 \
		--trim_poly_g \
		--poly_g_min_len 10 \
		--trim_poly_x \
		--report_title "First Trim 4 De Novo" 

# TruSeq adapters
		# --adapter_sequence=AGATCGGAAGAGCACACGTCTGAACTCCAGTCA \
		# --adapter_sequence_r2=AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT \

#run multiqc 
module load multiqc

multiqc -v -p -ip -f --data-dir --data-format tsv --cl-config "max_table_rows: 3000" --filename trimmed_report --outdir $OUTDIR/QC $OUTDIR

## END SCRIPT