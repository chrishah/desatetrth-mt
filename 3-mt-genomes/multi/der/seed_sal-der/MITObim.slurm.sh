#!/bin/bash
#
#SBATCH -J MITObim_der
#SBATCH -N 1
#SBATCH --ntasks-per-node 1
#SBATCH -o log.%j.out
#SBATCH -e log.%j.err
#SBATCH -p compute

###LOAD MODULES

#############################################################################
##DO SOME WORK


sample=der
readsSE=/home/478358/WORKING/GYRO/mt-genomes/1-trimmed-data/der.extended.minlength-100bp.fastq.gz
reads1=
reads2=
seed=G.sal-der.mt.fasta
ref=G.sal.der.mt
end_iteration=100
MM=2

zcat $reads1 $reads2 $readsSE > $sample-reads.fastq

#run MITObim
~/src/MITObim/MITObim/MITObim_1.8.pl -end $end_iteration --quick $seed -readpool $sample-reads.fastq -ref $ref -sample $sample --clean --missmatch $MM

rm -v $sample-reads.fastq

