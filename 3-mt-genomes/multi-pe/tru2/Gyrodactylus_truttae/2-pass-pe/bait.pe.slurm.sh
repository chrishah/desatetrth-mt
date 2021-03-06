#!/bin/bash
#SBATCH -J tru2.bait.pe
#SBATCH -N 1
#SBATCH --ntasks-per-node 1
#SBATCH -o job.%j.out
#SBATCH -e job.%j.err
#SBATCH -p compute

#Extract ids of good paired end reads from MIRA result
final_iteration=$(ls -1 /home/478358/WORKING/GYRO/mt-genomes/3-mt-genomes/multi-pe/tru2/Gyrodactylus_truttae/1-pass-all/ | grep "iteration" | sed 's/iteration//' | sort -n | tail -n 1)
contigreadlist=$(echo -e "/home/478358/WORKING/GYRO/mt-genomes/3-mt-genomes/multi-pe/tru2/Gyrodactylus_truttae/1-pass-all/iteration$final_iteration/tru2-Gyrodactylus_truttae _assembly/tru2-Gyrodactylus_truttae _d_info/tru2-Gyrodactylus_truttae _info_contigreadlist.txt" | sed 's/ //g')

for ref in $(cat $contigreadlist | grep "#" -v | cut -f 1 | sort -n | uniq)
do
        seed=$(echo -e "$ref" | cut -d "|" -f 2 | sed 's/_bb//g')
        grep -P "$ref" $contigreadlist | cut -f 2 | sed 's/\/[1-2]$//' | sort -n | uniq -c | perl -ne 'chomp; @a=split(" "); if ($a[0] == 2){print "$a[1]/1\n$a[1]/2\n"}else{print STDERR "$a[1]\n"}' 1> tru2.Gyrodactylus_truttae.pe.readlist.txt 2> tru2.Gyrodactylus_truttae.se.readlist.txt 
done 

miraconvert -n tru2.Gyrodactylus_truttae.pe.readlist.txt /home/478358/WORKING/GYRO/mt-genomes/3-mt-genomes/multi-pe/../../1-trimmed-data/tru2-trimmed-min50-interleaved.fastq.gz tru2.Gyrodactylus_truttae.interleaved.fastq
gzip tru2.Gyrodactylus_truttae.interleaved.fastq 
