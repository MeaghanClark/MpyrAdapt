#!/bin/bash

#SBATCH --job-name=make_symbolic_links
#SBATCH --output /home/miclark/MpyrAdapt/logs/make_links-%j.out
#SBATCH --error /home/miclark/MpyrAdapt/logs/make_links-%j.err
#SBATCH --cpus-per-task=1
#SBATCH --time=4:00:00
#SBATCH --mem=12G 
#SBATCH --partition=lab-mpinsky
#SBATCH --qos=pi-mpinsky
#SBATCH --account=pi-mpinsky

############# make_symbolic_links_CCGP.sbatch  ###################
## creates symbolic links for CCGP samples in the project

# Edit these paths
KEY="/home/miclark/MpyrAdapt/metadata/Mpyr_CCGP_ID.csv"
SEQDIR="/groups/mpinsky_lab/CCGP_data_raw"
OUTDIR="/home/miclark/MpyrAdapt/data/raw"


while IFS=',' read -r number site_id seq_id _rest; do
    echo "Processing ${number} (${site_id}, ${seq_id})"
done < <(tail -n +2 "$KEY")

while IFS=',' read -r number site_id seq_id _rest; do
    number="${number// /}"
    site_id="${site_id// /}"
    seq_id="${seq_id// /}"

    [[ -z "$number" ]] && continue

    for read_num in 1 2; do
        src=$(find "$SEQDIR" -name "${number}_*_R${read_num}_*.fastq.gz" | head -n 1)
        [[ -z "$src" ]] && continue

        ln -s "$(realpath "$src")" "${OUTDIR}/Mpyr_CCG_${site_id}_${seq_id}_${read_num}.fastq.gz"
    done

done < <(tail -n +2 "$KEY")
# END SCRIPT