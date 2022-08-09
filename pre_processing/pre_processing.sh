#!/bin/bash

# Necessary modules
# FastUniq (v1.1)
# cutadapt (v3.2)
# STAR (v2.7.7a)
# SAMtools (v1.13)

# FASTUNIQ - DEDUPLICATION
# initial_fq_list.txt is a text file containing the 2 fastq files to be processe, one name for each line (e.g. the output of a ls)
fastuniq -i initial_fq_list.txt -tq -o dedup_R1.fq -p dedup_R2.fq  -c 0
gzip dedup_*.fq

# CUTADAPT TRIMMING
# cut the first 10 of R2 (randomer) and then remove the adapter (X1A/B 3' RNA linker) from the end of the read (-a). 
# adapter sequences are contained in the file adapters.txt
# if after the adapters' removal the read's length is < 10, discard the reads
cutadapt --cut 10 -a file:adapters.txt --minimum-length 10 -o R2_trim.fq.gz dedup_R2.fq.gz > trim_stats.txt


# STAR ALIGNMENT 
# genomedir_path is the folder containing the indexed files
STAR --runThreadN 15 --genomeDir genomedir_path --readFilesIn R2_trim.fq.gz --readFilesCommand gunzip -c --outSAMtype BAM SortedByCoordinate --quantMode GeneCounts --outFilterMultimapNmax 20
samtools index Aligned.sortedByCoord.out.bam
