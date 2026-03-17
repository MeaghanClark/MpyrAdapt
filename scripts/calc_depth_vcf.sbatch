#!/bin/bash

#SBATCH --job-name=vcf_depth
#SBATCH --output /home/miclark/MpyrAdapt/logs/vcf_depth-%j.out
#SBATCH --error /home/miclark/MpyrAdapt/logs/vcf_depth-%j.err
#SBATCH --cpus-per-task=32
#SBATCH --time=12:00:00
#SBATCH --mem=1000G 
#SBATCH --partition=lab-mpinsky
#SBATCH --qos=pi-mpinsky
#SBATCH --account=pi-mpinsky

module load bcftools 
module load parallel/20200122
module list 

VCF_PATTERN="MpyrAdapt_annotated_*.vcf.gz"
OUTPUT="/home/miclark/MpyrAdapt/data/variants/filtering/annotatedVCF_mean_depth_per_sample.txt"
INDIR="/hb/scratch/miclark/MpyrAdapt/variants/annotatedVCFs"

parallel -j31 'bcftools view -f PASS {} | bcftools query -f "[%SAMPLE\t%DP\n]"' \
    ::: ${INDIR}/$VCF_PATTERN | \
awk '
    $2 != "." { sum[$1] += $2; count[$1]++ }
    END {
        print "SAMPLE\tMEAN_DEPTH\tN_SITES"
        for (s in sum) print s, sum[s]/count[s], count[s]
    }
' OFS='\t' > "$OUTPUT"

## END SCRIPT