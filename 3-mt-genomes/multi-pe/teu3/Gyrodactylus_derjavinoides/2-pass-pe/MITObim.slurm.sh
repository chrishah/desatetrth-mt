#!/bin/bash
#
#SBATCH -J teu3.pe.MITObim
#SBATCH -N 1
#SBATCH --ntasks-per-node 1
#SBATCH -o log.%j.out
#SBATCH -e log.%j.err
#SBATCH -p compute

###LOAD MODULES

#############################################################################
##DO SOME WORK


sample=teu3
readsSE=teu3.Gyrodactylus_derjavinoides.interleaved.fastq.gz
reads1=
reads2=
seed=/home/478358/WORKING/GYRO/mt-genomes/3-mt-genomes/references/G.derjavinoides.mt.fasta
ref=Gyrodactylus_derjavinoides
end_iteration=100
MM=1

zcat $reads1 $reads2 $readsSE > $sample-reads.fastq

#run MITObim
~/src/MITObim/MITObim/MITObim_1.8.pl -end $end_iteration --quick $seed -readpool $sample-reads.fastq -ref $ref -sample $sample --clean --missmatch $MM

rm -v $sample-reads.fastq

