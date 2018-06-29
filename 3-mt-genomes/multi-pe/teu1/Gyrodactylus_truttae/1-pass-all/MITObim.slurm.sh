#!/bin/bash
#
#SBATCH -J teu1.MITObim
#SBATCH -N 1
#SBATCH --ntasks-per-node 1
#SBATCH -o log.%j.out
#SBATCH -e log.%j.err
#SBATCH -p compute

###LOAD MODULES

#############################################################################
##DO SOME WORK


sample=teu1
readsSE=/home/478358/WORKING/GYRO/mt-genomes/3-mt-genomes/multi-pe/../../1-trimmed-data/teu1-trimmed-min50-interleaved.fastq.gz
reads1=
reads2=
seed=/home/478358/WORKING/GYRO/mt-genomes/3-mt-genomes/clean/tru1/seed_salaris_pe/tru1.circular.14823.renamed.fasta
ref=Gyrodactylus_truttae
end_iteration=100
MM=1

zcat $reads1 $reads2 $readsSE > $sample-reads.fastq

#run MITObim
~/src/MITObim/MITObim/MITObim_1.8.pl -end $end_iteration --quick $seed -readpool $sample-reads.fastq -ref $ref -sample $sample --clean --missmatch $MM

rm -v $sample-reads.fastq

