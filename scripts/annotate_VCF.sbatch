#!/bin/bash 

#load programs we want to use
module load bcftools/1.21 
module load perl/5.40.0
module list 

BCF='${INDIR}/MpyrAdapt_scaffold_${SLURM_ARRAY_TASK_ID}_norm.bcf.gz' 
OUTFILE='${OUTDIR}/MpyrAdapt_annotated_${SLURM_ARRAY_TASK_ID}.vcf.gz' # annotated VCF! 
#GRPFILE defined in wrapper
CHROM=$(sed -n "${SLURM_ARRAY_TASK_ID}p" $ARRAY_KEY) 
BEDFILE='${MASKDIR}/MpyrAdapt_PF_mask_${SLURM_ARRAY_TASK_ID}_fail.bed' 

#SCAF=$(cat $REGFILE)
# trying -r, annotate by scaffold 
CMD="bcftools view -r $CHROM --no-version $BCF | $SCRIPT --dpbounds 174,3486 --hetbound 1e-4 --bed $BEDFILE --overwrite --genorep $GRPFILE | bgzip > $OUTFILE" 

printf "\n%s\n\n" "$CMD"
eval $CMD
wait

tabix -p vcf $OUTFILE
#print some environment variables to stdout for records
echo ----------------------------------------------------------------------------------------
echo PRINTING SUBSET OF ENVIRONMENT VARIABLES:
(set -o posix ; set | grep -v ^_ | grep -v ^EB | grep -v ^BASH | grep -v PATH | grep -v LS_COLORS)

echo ----------------------------------------------------------------------------------------
