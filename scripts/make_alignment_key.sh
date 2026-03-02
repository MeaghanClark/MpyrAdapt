# script to make alignment array key to run with wrapper-align_to_genome.sh

KEY=/home/miclark/MpyrAdapt/scripts/alignment_key.txt
INDIR=/home/miclark/MpyrAdapt/data/processed/merged

ls $INDIR/*mrg.fq.gz | \
    sed -E 's/.*\///' | \
    sed -E 's/_mrg\.fq\.gz$//' | \
    while read line; do
        echo -e "$line\t$INDIR/${line}_r1.fq.gz\t$INDIR/${line}_r2.fq.gz\t$INDIR/${line}_mrg.fq.gz"
    done > $KEY
