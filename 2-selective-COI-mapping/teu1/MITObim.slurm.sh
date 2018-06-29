#!/bin/bash
#
#SBATCH -J teu1_MITObim
#SBATCH -N 1
#SBATCH --ntasks-per-node 1
#SBATCH -o log.%j.out
#SBATCH -e log.%j.err
#SBATCH -p compute

###LOAD MODULES

#############################################################################
##DO SOME WORK


sample=teu1
readsSE=
reads1=/home/478358/WORKING/GYRO/mt-genomes/2-selective-COI-mapping/../1-trimmed-data/teu1-trimmed-min50-interleaved.fastq.gz
reads2=
seed=/home/478358/WORKING/GYRO/mt-genomes/2-selective-COI-mapping/GyrodactylusCOI.fasta
ref=Gyro_COI
MM=4
end_iteration=1
minlength=90
#threads=$PBS_NUM_PPN

zcat $reads1 $reads2 $readsSE | perl -ne 'chomp; $h=$_; $s=<>; $p=<>; $q=<>; if (length($s) > 90){print "$h\n$s$p$q"}' > $sample-reads.fastq

#run MITObim
~/src/MITObim/MITObim/MITObim_1.8.pl -end $end_iteration --quick $seed -readpool $sample-reads.fastq -ref $ref -sample $sample --clean --trimoverhang --missmatch $MM 

rm -v $sample-reads.fastq

