#!/bin/bash
# Author: Hyung Joo Lee

##SBATCH --mem=2G
#SBATCH --array=1-14
##SBATCH --workdir=/scratch/twlab/hlee/zf_te
#SBATCH --job-name=annot_feat_epi

# SOFTWARE
module load bedtools/2.27.1
ID=$SLURM_ARRAY_TASK_ID
workdir=/scratch/twlab/hlee/zf_te

# GENOME FEATURES
dir_feature=/scratch/twlab/hlee/genomes/danRer10
list=${dir_feature}/features.txt
feature=$( cat $list | sed "${ID}q;d" )
bed_feature=${dir_feature}/${feature}.bed.gz


# INPUT DATA
dir_in=${workdir}/0_cres

boundaries=${dir_in}/union/TAD_boundaries_union.bed.gz
anchors=${dir_in}/union/loop_anchors_union.bed.gz


# OUTPUT
dir_out=${workdir}/1_annot
feature=${feature##*/}
feature=${feature#danRer10.}
feature=${feature#GRCz10.91.}
out=${dir_out}/${feature}.annotation_hic_union.txt


# COMMANDS
echo $feature > $out


## TAD boundaries and loop anchors
intersectBed -a $bed_feature -b $boundaries | sort -k1,1 -k2,2n |
    mergeBed -i stdin |
    awk 'BEGIN{s=0} {s+=$3-$2} END{print s}' >> $out

intersectBed -a $bed_feature -b $anchors | sort -k1,1 -k2,2n |
    mergeBed -i stdin |
    awk 'BEGIN{s=0} {s+=$3-$2} END{print s}' >> $out

## Genomic feature size
zcat $bed_feature | sort -k1,1 -k2,2n |
    mergeBed -i stdin |
    awk 'BEGIN{s=0} {s+=$3-$2} END{print s}' >> $out


