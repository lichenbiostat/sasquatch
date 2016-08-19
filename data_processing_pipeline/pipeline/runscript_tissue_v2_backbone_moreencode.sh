#!/bin/bash


##############################################################################################
##                                                                                          ##
## Sasquatch, Sequence based predicting of DNase I footprinting potential.                  ##
## Copyright (C) 2016 Genome Biology and Computational Biology Research Group, WIMM, Oxford ##
##                                                                                          ##
## Data preprocessing: download and job submission backbone, public data                    ##
##                                                                                          ##
##############################################################################################

#$ -cwd
#$ -q batchq
#$ -M ron.schwessinger@ndcls.ox.ac.uk
#$ -m eas
#$ -j y
#$ -o /t1-data1/WTSA_Dev/rschwess/clustereo

# qsub -N name.tag -v IDTAG="",BAM_PATH="",BED_PATH="" /t1-data1/WTSA_Dev/rschwess/Sasquatch_offline/Sasquatch/data_processing_pipeline/pipeline/runscript_tissue_v2_backbone_moreencode.sh

# nohup nice sh /t1-data1/WTSA_Dev/rschwess/Sasquatch_offline/Sasquatch/data_processing_pipeline/pipeline/runscript_tissue_v2_backbone_public.sh &

#set -x

#path to pipeline directory and additional scripts
PIPE_DIR=/t1-data1/WTSA_Dev/rschwess/Sasquatch_offline/Sasquatch/data_processing_pipeline/pipeline/
SCRIPT_DIR=/t1-data1/WTSA_Dev/rschwess/Sasquatch_offline/Sasquatch/data_processing_pipeline/scripts/


##################
# Set PARAMETERS #
##################

#specify if "mouse" or "human"
ORGANISM="human"

#genome Build ["hg18", "hg19", "mm9"] currently choosable
BUILD='hg19'

#IDtag to produce output directory and name the files
#IDTAG="ENCODE_UW_MCF7_rep2"

#specify if DNaseI or ATAC data ("DNase" or "ATAC")
DATA_TYPE="DNase"

#output directory
OUTPUT_DIR=/t1-data1/WTSA_Dev/rschwess/database_assembly/idx_correct_assembly/${ORGANISM}/${DATA_TYPE}/${IDTAG}

#type of sequencing ["singleend" / "pairedend"] 
#SEQ_TYPE="singleend"


# ================================================================================ #
# PRESET SOME USEFULE FTP LINKS 						   #
# Source: ENCODE  "Duke" "UW" "UW_DGF" "UW_mouse"; chose download paths 	   #
# set names of bam and peak files of interest  					   #
# ================================================================================ #

BAM_NAME=`basename ${BAM_PATH}`
PEAK_NAME=`basename ${BED_PATH} .bed.gz`

PEAK_FILE="${PEAK_NAME}.bed"

# set future bamfile path
BAM_FILE=${OUTPUT_DIR}/${BAM_NAME}
# the perl script handling the region file decides based on the end of of the file name (.gff or (.bed or .narroweak)) in which columns is has to look for the chromosome and start and stop coordinates
REGIONS_FILE=${OUTPUT_DIR}/${PEAK_FILE}
REGIONS_FILE_PLOIDY_FILTERED=${OUTPUT_DIR}/${PEAK_NAME}_ploidy_filtered.bed

# ======================================================================================== #
# Configure Paths to genomes and chr sizes files and ploidy regions to filter out for      #
# required organisms and genome builds only required those specified that are atully used  #                            
# ======================================================================================== #

#hg19
REF_GENOME_hg19=/databank/igenomes/Homo_sapiens/UCSC/hg19/Sequence/WholeGenomeFasta/genome.fa
BIGWIG_CHRSIZES_hg19=/t1-data/user/config/bigwig/hg19_sizes.txt
PLOIDY_REGIONS_hg19=/t1-data1/WTSA_Dev/rschwess/database_assembly/region_exclude/hg19/wgEncodeDukeMapabilityRegionsExcludable.bed

#hg18
REF_GENOME_hg18=/databank/raw/hg18_full/hg18_full.fa
BIGWIG_CHRSIZES_hg18=/t1-data/user/config/bigwig/hg18_sizes.txt
PLOIDY_REGIONS_hg18=/t1-data1/WTSA_Dev/rschwess/database_assembly/region_exclude/hg18/wgEncodeDukeRegionsExcluded.bed

#mm9
REF_GENOME_mm9=/databank/igenomes/Mus_musculus/UCSC/mm9/Sequence/WholeGenomeFasta/genome.fa
BIGWIG_CHRSIZES_mm9=/t1-data/user/config/bigwig/mm9_sizes.txt
PLOIDY_REGIONS_mm9=/t1-data1/WTSA_Dev/rschwess/database_assembly/region_exclude/mm9/Ploidy_mm9_sorted.bed

# ===================================================================================================== #
# Configure Paths to genome wide background DNase/ATAC cut propensities according to organism and build #
# only required to specifiy those that are actully used                                       		#
# ===================================================================================================== #

#human DNase
PROPENSITY_PLUS_human_dnase=/t1-data1/WTSA_Dev/rschwess/database_assembly/idx_correct_assembly/background/hg18_h_ery_1/pnorm/hg18_h_ery_1_propensities_plus_merged
PROPENSITY_MINUS_human_dnase=/t1-data1/WTSA_Dev/rschwess/database_assembly/idx_correct_assembly/background/hg18_h_ery_1/pnorm/hg18_h_ery_1_propensities_minus_merged

#human ATAC
PROPENSITY_PLUS_human_atac=/t1-data1/WTSA_Dev/rschwess/database_assembly/idx_correct_assembly/background/hg18_h_ery_1_atac/pnorm/cut_kmer_6_hg18_h_ery_1_atac_plus_merged_propensities
PROPENSITY_MINUS_human_atac=/t1-data1/WTSA_Dev/rschwess/database_assembly/idx_correct_assembly/background/hg18_h_ery_1_atac/pnorm/cut_kmer_6_hg18_h_ery_1_atac_minus_merged_propensities

#mouse DNase
PROPENSITY_PLUS_mouse_dnase=/t1-data1/WTSA_Dev/rschwess/database_assembly/idx_correct_assembly/background/mm9_m_ery_1/pnorm/cut_kmer_6_mm9_m_ery_1_plus_merged_propensities
PROPENSITY_MINUS_mouse_dnase=/t1-data1/WTSA_Dev/rschwess/database_assembly/idx_correct_assembly/background/mm9_m_ery_1/pnorm/cut_kmer_6_mm9_m_ery_1_minus_merged_propensities

#mouse ATAC
PROPENSITY_PLUS_mouse_atac=/t1-data1/WTSA_Dev/rschwess/database_assembly/idx_correct_assembly/background/mm9_m_ery_1_atac/pnorm/cut_kmer_6_atac_mm9_m_ery_1_atac_plus_merged_propensities
PROPENSITY_MINUS_mouse_atac=/t1-data1/WTSA_Dev/rschwess/database_assembly/idx_correct_assembly/background/mm9_m_ery_1_atac/pnorm/cut_kmer_6_atac_m_ery_1_atac_minus_merged_propensities


# ============================================================================================================== #
# Select reference genome, mapability (ploidy) regions to remove from the footprint signal and                   #
# background cut propensities according to organism and genome build 						 #
# ============================================================================================================== #
case "${ORGANISM}" in
	
	human)
		#select ref genome ploidy regions and chromosome sizes
		case "${BUILD}" in

			hg19)
				REF_GENOME=${REF_GENOME_hg19}
				BIGWIG_CHRSIZES=${BIGWIG_CHRSIZES_hg19}
				PLOIDY_REGIONS=${PLOIDY_REGIONS_hg19}
			;;

			hg18)
				REF_GENOME=${REF_GENOME_hg18}
				BIGWIG_CHRSIZES=${BIGWIG_CHRSIZES_hg18}
				PLOIDY_REGIONS=${PLOIDY_REGIONS_hg18}
			;;

		esac

		#source of background cut propensities (ATAC or DNase1)
		case "${DATA_TYPE}" in
	
			DNase)
				pnormsource="h_ery_1"
				PROPENSITY_PLUS=${PROPENSITY_PLUS_human_dnase}
				PROPENSITY_MINUS=${PROPENSITY_MINUS_human_dnase}			
			;;

			ATAC)
				pnormsource="h_ery_1_atac"
				PROPENSITY_PLUS=${PROPENSITY_PLUS_human_atac}
				PROPENSITY_MINUS=${PROPENSITY_MINUS_human_atac}
			;;
		esac

	;;

	mouse)

		case "${BUILD}" in

			mm9)	
				REF_GENOME=${REF_GENOME_mm9}
				BIGWIG_CHRSIZES=${BIGWIG_CHRSIZES_mm9}
				PLOIDY_REGIONS=${PLOIDY_REGIONS_mm9}						
			;;
		esac	

		#source of cut propensities (ATAC or DNase1)
		case "${DATA_TYPE}" in
	
			DNase)
				pnormsource="m_ery_1"
				PROPENSITY_PLUS=${PROPENSITY_PLUS_mouse_dnase}
				PROPENSITY_MINUS=${PROPENSITY_MINUS_mouse_dnase}			
			;;

			ATAC)
				pnormsource="m_ery_1_atac"
				PROPENSITY_PLUS=${PROPENSITY_PLUS_mouse_atac}
				PROPENSITY_MINUS=${PROPENSITY_MINUS_mouse_atac}
			;;
		esac

	;;
esac


####################
# START PROCESSING #
####################

echo "starting at ..."
date

#### --------------------------------------
#### Download Files
#### --------------------------------------
mkdir -p ${OUTPUT_DIR}

cd ${OUTPUT_DIR}

echo "Start downloading bam file ..."

wget -q ${BAM_PATH}

# check for single or paired end (check first 100000 reads
pairedcheck=`samtools view ${BAM_FILE} | head -n 10000 | perl -lane 'print $_ if $F[1] & 0x1;' | head -n 1`

#echo $pairedcheck

if [ -z "$pairedcheck" ]
then
	echo "bam file is single end ..."
	SEQ_TYPE="singleend"
else
	echo "bam file is paired end ..."
        SEQ_TYPE="pairedend"
fi


echo "Start downloading bed file ..."

wget -q ${BED_PATH} 

gzip -d ${OUTPUT_DIR}/${PEAK_FILE}.gz

### --------------------------------------
### filter regions file for ploidy regions
### --------------------------------------

# load modules: rather specific to our server system /not required when bedtools is accessible
module load bedtools
module load samtools

# filter peaks for ploidy regions
bedtools intersect -v -a ${REGIONS_FILE} -b ${PLOIDY_REGIONS} >${REGIONS_FILE_PLOIDY_FILTERED}

### -----------------
### Submit Footprints
### -----------------

# submit fooptrinting and keep job id
fpid=`qsub -N fp_${IDTAG} -v OUTPUT_DIR=${OUTPUT_DIR},DATA_TYPE=${DATA_TYPE},BAM_FILE=${BAM_FILE},SCRIPT_DIR=${SCRIPT_DIR},BIGWIG_CHRSIZES=${BIGWIG_CHRSIZES},SEQ_TYPE=${SEQ_TYPE},IDTAG=${IDTAG} ${PIPE_DIR}/runscript_tissue_v2_footprinting.sh | perl -ne '$_=~/\s+(\d+)\s+/; print $1;'`
 
 echo "Footprinting Job $fpid submitted"

### ------------------------
### submit count k-mers pnorm
### ------------------------

# make counts directory
COUNTS=${OUTPUT_DIR}/counts
mkdir -p ${COUNTS}

# submit kmer based cut profile counting and store job ID
countpnormid=`qsub -N kmerpn_${IDTAG} -hold_jid $fpid -v COUNTS=${COUNTS},OUTPUT_DIR=${OUTPUT_DIR},REGIONS_FILE_PLOIDY_FILTERED=${REGIONS_FILE_PLOIDY_FILTERED},SCRIPT_DIR=${SCRIPT_DIR},REF_GENOME=${REF_GENOME},IDTAG=${IDTAG},PROPENSITY_PLUS=${PROPENSITY_PLUS},PROPENSITY_MINUS=${PROPENSITY_MINUS},pnormsource=${pnormsource} ${PIPE_DIR}/runscript_tissue_v2_kmercount_pnorm.sh  | perl -ne '$_=~/\s+(\d+)\s+/; print $1;'`


## without waiting for the footprinting job ID
##countpnormid=`qsub -N kmerpn_${IDTAG} -v COUNTS=${COUNTS},OUTPUT_DIR=${OUTPUT_DIR},REGIONS_FILE_PLOIDY_FILTERED=${REGIONS_FILE_PLOIDY_FILTERED},SCRIPT_DIR=${SCRIPT_DIR},REF_GENOME=${REF_GENOME},IDTAG=${IDTAG},PROPENSITY_PLUS=${PROPENSITY_PLUS},PROPENSITY_MINUS=${PROPENSITY_MINUS},pnormsource=${pnormsource} ${PIPE_DIR}/runscript_tissue_v2_kmercount_pnorm.sh  | perl -ne '$_=~/\s+(\d+)\s+/; print $1;'`


echo "K-mer counting P-norm Job $countpnormid submitted"


### -----------------------------------------------------
### count reads, peaks and reads in peaks into stats file
### -----------------------------------------------------

samtools index ${BAM_FILE}

echo "Total reads: `samtools view ${BAM_FILE} | wc -l`" >${OUTPUT_DIR}/read_stats.txt
echo "Number of Peaks:: `wc -l ${REGIONS_FILE_PLOIDY_FILTERED}`" >>${OUTPUT_DIR}/read_stats.txt 
echo "Reads in Peaks:: `bedtools intersect -wa -a ${BAM_FILE} -b ${REGIONS_FILE_PLOIDY_FILTERED} | wc -l`" >>${OUTPUT_DIR}/read_stats.txt 


### --------------------------------------------------------------------------------------------
### Submit cleaner .sh for removing temporary stored bam (and footprint files if adjusted the cleaner script) after jobs finished
### --------------------------------------------------------------------------------------------
qsub -N cleaner_${IDTAG} -hold_jid $fpid,$countpnormid -v OUTPUT_DIR=${OUTPUT_DIR},REGIONS_FILE=${REGIONS_FILE},REGIONS_FILE_PLOIDY_FILTERED=${REGIONS_FILE_PLOIDY_FILTERED},BAM_FILE=${BAM_FILE} ${PIPE_DIR}/runscript_tissue_v2_cleaner.sh

