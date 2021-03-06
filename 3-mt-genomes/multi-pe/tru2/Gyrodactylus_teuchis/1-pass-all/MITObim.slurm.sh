#!/bin/bash
#
#SBATCH -J tru2.MITObim
#SBATCH -N 1
#SBATCH --ntasks-per-node 1
#SBATCH -o log.%j.out
#SBATCH -e log.%j.err
#SBATCH -p compute

###LOAD MODULES

#############################################################################
##DO SOME WORK


sample=tru2
readsSE=/home/478358/WORKING/GYRO/mt-genomes/3-mt-genomes/multi-pe/../../1-trimmed-data/tru2-trimmed-min50-interleaved.fastq.gz
reads1=
reads2=
seed=/home/478358/WORKING/GYRO/mt-genomes/3-mt-genomes/clean/teu2/seed_salaris/teu2.circular.14789.renamed.fasta
ref=Gyrodactylus_teuchis
end_iteration=100
MM=1

zcat $reads1 $reads2 $readsSE > $sample-reads.fastq

#run MITObim
~/src/MITObim/MITObim/MITObim_1.8.pl -end $end_iteration --quick $seed -readpool $sample-reads.fastq -ref $ref -sample $sample --clean --missmatch $MM

rm -v $sample-reads.fastq

