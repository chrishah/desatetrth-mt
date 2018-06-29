#!/bin/bash
#
#SBATCH -J MITObim_teu4
#SBATCH -N 1
#SBATCH --ntasks-per-node 1
#SBATCH -o log.%j.out
#SBATCH -e log.%j.err
#SBATCH -p compute

###LOAD MODULES

#############################################################################
##DO SOME WORK


sample=teu4
readsSE=/home/478358/WORKING/GYRO/mt-genomes/1-trimmed-data/teu4.extended.minlength-100bp.fastq.gz
reads1=
reads2=
seed=/home/478358/WORKING/GYRO/mt-genomes/3-mt-genomes/references/G.salaris.mt.fasta
ref=G.salaris.mt
end_iteration=100

zcat $reads1 $reads2 $readsSE > $sample-reads.fastq

#run MITObim
~/src/MITObim/MITObim/MITObim_1.8.pl -end $end_iteration --quick $seed -readpool $sample-reads.fastq -ref $ref -sample $sample --clean 

rm -v $sample-reads.fastq

