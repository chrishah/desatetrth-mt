#!/bin/bash
#SBATCH -J let.bait.pe
#SBATCH -N 1
#SBATCH --ntasks-per-node 1
#SBATCH -o job.%j.out
#SBATCH -e job.%j.err
#SBATCH -p compute

#Extract ids of good paired end reads from MIRA result
final_iteration=$(ls -1 /home/478358/WORKING/GYRO/mt-genomes/3-mt-genomes/multi-pe/let/Gyrodactylus_derjavinoides/1-pass-all/ | grep "iteration" | sed 's/iteration//' | sort -n | tail -n 1)
contigreadlist=$(echo -e "/home/478358/WORKING/GYRO/mt-genomes/3-mt-genomes/multi-pe/let/Gyrodactylus_derjavinoides/1-pass-all/iteration$final_iteration/let-Gyrodactylus_derjavinoides _assembly/let-Gyrodactylus_derjavinoides _d_info/let-Gyrodactylus_derjavinoides _info_contigreadlist.txt" | sed 's/ //g')

for ref in $(cat $contigreadlist | grep "#" -v | cut -f 1 | sort -n | uniq)
do
        seed=$(echo -e "$ref" | cut -d "|" -f 2 | sed 's/_bb//g')
        grep -P "$ref" $contigreadlist | cut -f 2 | sed 's/\/[1-2]$//' | sort -n | uniq -c | perl -ne 'chomp; @a=split(" "); if ($a[0] == 2){print "$a[1]/1\n$a[1]/2\n"}else{print STDERR "$a[1]\n"}' 1> let.Gyrodactylus_derjavinoides.pe.readlist.txt 2> let.Gyrodactylus_derjavinoides.se.readlist.txt 
done 

miraconvert -n let.Gyrodactylus_derjavinoides.pe.readlist.txt /home/478358/WORKING/GYRO/mt-genomes/3-mt-genomes/multi-pe/../../1-trimmed-data/let-trimmed-min50-interleaved.fastq.gz let.Gyrodactylus_derjavinoides.interleaved.fastq
gzip let.Gyrodactylus_derjavinoides.interleaved.fastq 
