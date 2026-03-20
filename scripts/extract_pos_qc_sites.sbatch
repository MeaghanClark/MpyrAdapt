#!/bin/bash

# This script generates bed file of site masks based on bam statistics
# Last updated 03/16/2026 by MI Clark, based on script by T Linderoth

#load programs we want to use
module load bcftools 
module list

VCF="${INDIR}/MpyrAdapt_annotated_${SLURM_ARRAY_TASK_ID}.vcf.gz"
SITES="${OUTDIR}/MpyrAdapt_qc_sites_${SLURM_ARRAY_TASK_ID}.pos"

# adding "&& MQ>=35 && MQ0F<=0.1 && QUAL>=20" to end of FILTER_STRING and removing "-f PASS" from bcftools view because annotations in vcf are too stringent

# 90% of individuals in a population need to have at least one read, don't filter based on genotype quality! 
bcftools view -S $INDS -i 'N_PASS(GT[0,1,2,3,4,5,6,7,8,9]!="mis" & FMT/DP >= 1) >= 8 && N_PASS(GT[10,11,12,13,14,15,16,17,18,19]!="mis" & FMT/DP >= 1) >= 8 && N_PASS(GT[20,21,22,23,24,25,26,27,28]!="mis" & FMT/DP >= 1) >= 7 && N_PASS(GT[29,30,31,32,33,34,35,36,37]!="mis" & FMT/DP >= 1) >= 7 && N_PASS(GT[38,39,40,41,42,43,44,45,46]!="mis" & FMT/DP >= 1) >= 7 && N_PASS(GT[47,48,49,50,51,52,53,54,55]!="mis" & FMT/DP >= 1) >= 7 && N_PASS(GT[56,57,58,59,60,61,62,63,64,65]!="mis" & FMT/DP >= 1) >= 8 && N_PASS(GT[66,67,68,69]!="mis" & FMT/DP >= 1) >= 3 && N_PASS(GT[70,71,72,73,74]!="mis" & FMT/DP >= 1) >= 4 && N_PASS(GT[75,76,77,78,79]!="mis" & FMT/DP >= 1) >= 4 && N_PASS(GT[80,81,82,83,84]!="mis" & FMT/DP >= 1) >= 4 && N_PASS(GT[85,86,87,88,89]!="mis" & FMT/DP >= 1) >= 4 && N_PASS(GT[90,91,92,93,94]!="mis" & FMT/DP >= 1) >= 4 && N_PASS(GT[95,96,97,98,99]!="mis" & FMT/DP >= 1) >= 4 && N_PASS(GT[100,101,102,103]!="mis" & FMT/DP >= 1) >= 3 && N_PASS(GT[104,105,106,107,108]!="mis" & FMT/DP >= 1) >= 4 && N_PASS(GT[109,110,111,112,113]!="mis" & FMT/DP >= 1) >= 4 && N_PASS(GT[114,115,116,117,118]!="mis" & FMT/DP >= 1) >= 4 && N_PASS(GT[119,120,121,122,123,124,125,126,127,128]!="mis" & FMT/DP >= 1) >= 8 && N_PASS(GT[129,130,131,132,133]!="mis" & FMT/DP >= 1) >= 4 && N_PASS(GT[134,135,136,137,138]!="mis" & FMT/DP >= 1) >= 4 && N_PASS(GT[139,140,141,142,143]!="mis" & FMT/DP >= 1) >= 4 && N_PASS(GT[144,145,146,147,148,149,150,151,152,153,154]!="mis" & FMT/DP >= 1) >= 9 && N_PASS(GT[155,156]!="mis" & FMT/DP >= 1) >= 2 && MQ>=35 && MQ0F<=0.1 && QUAL>=20' $VCF | \
bcftools query -f '%CHROM\t%POS\n' | uniq > $SITES

wait

module remove bcftools
module load angsd/0.940
module list

angsd sites index $SITES

printf "\nfinished\n"




#print some environment variables to stdout for records
echo ----------------------------------------------------------------------------------------
echo PRINTING SUBSET OF ENVIRONMENT VARIABLES:
(set -o posix ; set | grep -v ^_ | grep -v ^EB | grep -v ^BASH | grep -v PATH | grep -v LS_COLORS)

echo ----------------------------------------------------------------------------------------
