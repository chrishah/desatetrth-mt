#!/bin/bash
#
#SBATCH -J MITObim_teu1
#SBATCH -N 1
#SBATCH --ntasks-per-node 1
#SBATCH -o log.%j.out
#SBATCH -e log.%j.err
#SBATCH -p compute

###LOAD MODULES

#############################################################################
##DO SOME WORK


sample=teu1
readsSE=../../../../../1-trimmed-data/teu1-trimmed-min50-interleaved.fastq.gz
reads1=
reads2=
seed=Gyrodactylus_teuchis_ciruclar_14789.reference.fasta
ref=Gyrodactylus_teuchis_ciruclar_14789
end_iteration=100
MM=2

zcat $reads1 $reads2 $readsSE > $sample-reads.fastq

#run MITObim
~/src/MITObim/MITObim/MITObim_1.8.pl -end $end_iteration --quick $seed -readpool $sample-reads.fastq -ref $ref -sample $sample --clean --missmatch $MM

rm -v $sample-reads.fastq

