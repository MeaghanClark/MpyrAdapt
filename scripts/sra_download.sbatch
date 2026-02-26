#!/bin/bash
#SBATCH --job-name=sra_download
#SBATCH --output=/home/miclark/MpyrAdapt/logs/sra_download_%j.log
#SBATCH --error=/home/miclark/MpyrAdapt/logs/sra_download_%j.err
#SBATCH --time=24:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --partition=lab-mpinsky
#SBATCH --qos=pi-mpinsky
#SBATCH --account=pi-mpinsky

########   sra_download.sbatch     ##############
## downloads data from NCBI SRA for a given bioproject 
## works for bioprojects with up to 500 acceessions
## requires installation of the sratoolkit in the $HOME directory. 
        # for future runs, modify code to download .sra file to scratch, convert to .fastq in parallel, and then move to storage directory

# Usage: sbatch download_bioproject.sh <BIOPROJECT> 
# Example: sbatch download_bioproject.sh PRJNA938791

BIOPROJECT=$1
OUTDIR=/home/miclark/Mpyr_WGS_data/${BIOPROJECT}

# make sure to install sratoolkit in your home directory
export PATH=$HOME/software/sratoolkit.3.3.0-ubuntu64/bin:$PATH

if [ -z "$BIOPROJECT" ]; then
    echo "ERROR: No BioProject accession provided."
    echo "Usage: sbatch download_bioproject.sh <BIOPROJECT>"
    exit 1
fi

# make output directories 
mkdir -p $OUTDIR $OUTDIR/fastq

echo "Fetching SRR accessions for $BIOPROJECT..."

# Get UIDs
wget -q "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=sra&term=${BIOPROJECT}&retmax=500&retmode=json" \
    -O $OUTDIR/search.json

# Fetch run info
wget -q "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=sra&id=$(grep -o '"[0-9]\{6,\}"' $OUTDIR/search.json | tr -d '"' | paste -sd',')" \
    -O $OUTDIR/runinfo.xml

# Extract SRR accessions
grep -o 'SRR[0-9]*' $OUTDIR/runinfo.xml | sort -u > $OUTDIR/SRR_accessions.txt

echo "Found $(wc -l < $OUTDIR/SRR_accessions.txt) runs:"
cat $OUTDIR/SRR_accessions.txt

# Download all runs
echo "Downloading SRA files..."
prefetch --option-file $OUTDIR/SRR_accessions.txt \
         --output-directory $OUTDIR/sra \
         --max-size 100G

# Convert to FASTQ
echo "Converting to FASTQ..."
for sra_file in $OUTDIR/sra/SRR*/*.sra; do
    fasterq-dump "$sra_file" \
        --outdir $OUTDIR/fastq \
        --threads 8 \
        --split-files
done

# Compress
echo "Compressing FASTQ files..."
gzip $OUTDIR/fastq/*.fastq

echo "Done! Files in $OUTDIR/fastq:"
ls -lh $OUTDIR/fastq/

#print some environment variables to stdout for records
echo ----------------------------------------------------------------------------------------
echo PRINTING SUBSET OF ENVIRONMENT VARIABLES:
(set -o posix ; set | grep -v ^_ | grep -v ^EB | grep -v ^BASH | grep -v PATH | grep -v LS_COLORS)

echo ----------------------------------------------------------------------------------------
seff ${SLURM_JOBID}

# END SCRIPT