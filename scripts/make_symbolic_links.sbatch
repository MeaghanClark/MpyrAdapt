#!/bin/bash

#SBATCH --job-name=make_symbolic_links
#SBATCH --output /home/miclark/MpyrAdapt/logs/make_links-%j.out
#SBATCH --error /home/miclark/MpyrAdapt/logs/make_links-%j.err
#SBATCH --cpus-per-task=1
#SBATCH --time=4:00:00
#SBATCH --mem=24G 
#SBATCH --partition=lab-mpinsky
#SBATCH --qos=pi-mpinsky
#SBATCH --account=pi-mpinsky

############# make_symbolic_links.sbatch  ###################
## creates symbolic links for all samples in the project
## Each bioproject has slightly different naming conventions, so this script standardizes names and creates symbolic links to the original files in the same directory.

INDIR="/data/rufus/pinsky_lab/Mpyr/non_GCRG_WGS" # storage directory containing directories for each bioproject
RUNINFO="runinfo.csv"
    # generated with: wget -q "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=sra&id=$(grep -o '"[0-9]\{6,\}"' ./search.json | tr -d '"' | paste -sd',')&rettype=runinfo&retmode=csv" -O runinfo.csv
OUTDIR="/home/miclark/MpyrAdapt/data/raw" # directory to store symbolic links with standardized names

# Mpyr_Alberto_data
FASTQDIR=${INDIR}/Mpyr_Alberto_data/

for FILE in $FASTQDIR/*_R1_001.fastq.gz $FASTQDIR/*_R2_001.fastq.gz; do
    [ -f "$FILE" ] || continue

    BASENAME=$(basename $FILE)

    # Extract site ID and sample number from filename (e.g. PL17)
    SITE=$(echo $BASENAME | grep -o '^[A-Z]*')
    NUM=$(echo $BASENAME | grep -o '^[A-Z]*[0-9]*' | grep -o '[0-9]*')

    # Extract read direction (R1 or R2)
    READ=$(echo $BASENAME | grep -o 'R[12]'| tr -d 'R')

    # Construct new name
    NEWNAME="Mpyr_ALB_${SITE}_${NUM}_${READ}.fastq.gz"

    echo "$BASENAME --> $NEWNAME"
    ln -s "$(realpath $FILE)" "$OUTDIR/$NEWNAME"
done

# PRJNA661280
FASTQDIR=${INDIR}/PRJNA661280/fastq
COL=30  # column number containing isolate ID

awk -F',' -v col=$COL 'NR>1 {print $1, $col}' ${INDIR}/PRJNA661280/${RUNINFO} | while read SRR ISOLATE; do
    # Skip if isolate ID is empty
    if [ -z "$ISOLATE" ]; then
        echo "WARNING: No isolate ID for $SRR, skipping"
        continue
    fi

    # Reformat isolate ID: AQ_05 --> Mpyr_MOL_AQ-05
    NEWNAME="Mpyr_MOL_$(echo $ISOLATE | tr '_' '-')"

    # Create symbolic links for forward and reverse reads
    for SUFFIX in _1.fastq.gz _2.fastq.gz; do
        TARGET=$FASTQDIR/${SRR}${SUFFIX}
        LINK=$OUTDIR/${NEWNAME}${SUFFIX}

        if [ -f "$TARGET" ]; then
            echo "$SRR$SUFFIX --> ${NEWNAME}${SUFFIX}"
            ln -s "$(realpath $TARGET)" "$LINK"
        else
            echo "WARNING: $TARGET not found, skipping"
        fi
    done
done

# PRJNA938791
FASTQDIR=${INDIR}/PRJNA938791/fastq
COL=12  # column number containing isolate ID

awk -F',' -v col=$COL 'NR>1 {print $1, $col}' ${INDIR}/PRJNA938791/${RUNINFO} | while read SRR ISOLATE; do
    # Skip if isolate ID is empty
    if [ -z "$ISOLATE" ]; then
        echo "WARNING: No isolate ID for $SRR, skipping"
        continue
    fi

    # Reformat isolate ID: AQ_05 --> Mpyr_GON_AQ-05
    NEWNAME=$(echo $ISOLATE | sed "s/Macrocystis_/Mpyr_GON_/")

    # Create symbolic links for forward and reverse reads
    for SUFFIX in _1.fastq.gz _2.fastq.gz; do
        TARGET=$FASTQDIR/${SRR}${SUFFIX}
        LINK=$OUTDIR/${NEWNAME}${SUFFIX}

        if [ -f "$TARGET" ]; then
            echo "$SRR$SUFFIX --> ${NEWNAME}${SUFFIX}"
            ln -s "$(realpath $TARGET)" "$LINK"
        else
            echo "WARNING: $TARGET not found, skipping"
        fi
    done
done


# END SCRIPT