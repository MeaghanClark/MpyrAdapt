# script to make alignment array key to run with wrapper-align_to_genome.sh

KEY=/home/miclark/MpyrAdapt/scripts/alignment_key.txt
INDIR=/home/miclark/MpyrAdapt/data/processed

ls $INDIR/merged/*mrg.fq.gz | \
    sed -E 's/.*\///' | \
    sed -E 's/_mrg\.fq\.gz$//' | \
    while read line; do
        echo -e "$line\t$INDIR/unmerged/${line}_r1.fq.gz\t$INDIR/unmerged/${line}_r2.fq.gz\t$INDIR/merged/${line}_mrg.fq.gz"
    done > $KEY

# For CCGP dataset
KEY=/home/miclark/MpyrAdapt/scripts/CCGP_alignment_key.txt
INDIR=/home/miclark/MpyrAdapt/data/processed/

ls $INDIR/merged/*CCG*mrg.fq.gz | \
    sed -E 's/.*\///' | \
    sed -E 's/_mrg\.fq\.gz$//' | \
    while read line; do
        echo -e "$line\t$INDIR/unmerged/${line}_r1.fq.gz\t$INDIR/unmerged/${line}_r2.fq.gz\t$INDIR/merged/${line}_mrg.fq.gz"
    done > $KEY
