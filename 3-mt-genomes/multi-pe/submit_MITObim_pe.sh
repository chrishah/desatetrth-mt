#!/bin/bash

base=$(pwd)
for sample in $(cat $base/../multi.txt | sed 's/\t/|/')
do
	s=$(echo -e "$sample" | cut -d "|" -f 1)
	echo -e "\n###\n$s\n###\n"
	mkdir $s
	cd $s
	
	for ref in $(echo $sample | cut -d "|" -f 2 | sed 's/,/\n/g')
	do
		echo -e "$ref:"
		mkdir $ref
		cd $ref
	
		reads="$base/../../1-trimmed-data/$s-trimmed-min50-interleaved.fastq.gz"	
		reference=$(cat $base/../references/references_fofn.txt | grep "$ref" | cut -f 2)
		#run first pass of MITObim - > submit
		mkdir 1-pass-all
		cd 1-pass-all
		cat $base/MITObim.slurm.sh | sed "s/-J MITObim.*/-J $s.MITObim/" | sed "s?seed=.*?seed=$reference?" | sed "s/ref=.*/ref=$ref/" | sed "s/sample=.*/sample=$s/" | sed "s?readsSE=.*?readsSE=$reads?" > MITObim.slurm.sh
		pass1_job=$(sbatch MITObim.slurm.sh | perl -ne 'chomp; @a=split(" "); print "$a[-1]\n"')
		echo -e "[$(date)]\tSubmitted $s 'MITObim pass 1' job -> $pass1_job"

		cd ..
	
		#submit second pass of MITObim - good pairs only -> submit - dependency first pass
		mkdir 2-pass-pe
		cd 2-pass-pe
		
		#find last iteration in previous pass
		
		echo -e "#!/bin/bash
#SBATCH -J $s.bait.pe
#SBATCH -N 1
#SBATCH --ntasks-per-node 1
#SBATCH -o job.%j.out
#SBATCH -e job.%j.err
#SBATCH -p compute

#Extract ids of good paired end reads from MIRA result
final_iteration=\$(ls -1 $base/$s/$ref/1-pass-all/ | grep \"iteration\" | sed 's/iteration//' | sort -n | tail -n 1)
contigreadlist=\$(echo -e \"$base/$s/$ref/1-pass-all/iteration\$final_iteration/$s-$ref _assembly/$s-$ref _d_info/$s-$ref _info_contigreadlist.txt\" | sed 's/ //g')

for ref in \$(cat \$contigreadlist | grep \"#\" -v | cut -f 1 | sort -n | uniq)
do
        seed=\$(echo -e \"\$ref\" | cut -d \"|\" -f 2 | sed 's/_bb//g')
        grep -P \"\$ref\" \$contigreadlist | cut -f 2 | sed 's/\/[1-2]\$//' | sort -n | uniq -c | perl -ne 'chomp; @a=split(\" \"); if (\$a[0] == 2){print \"\$a[1]/1\\\n\$a[1]/2\\\n\"}else{print STDERR \"\$a[1]\\\n\"}' 1> $s.$ref.pe.readlist.txt 2> $s.$ref.se.readlist.txt 
done 

miraconvert -n $s.$ref.pe.readlist.txt $reads $s.$ref.interleaved.fastq
gzip $s.$ref.interleaved.fastq " > bait.pe.slurm.sh
		

		#Submit paired end extraction with dependency MITObim pass 1
		jobid=$(sbatch --dependency=afterok:$pass1_job bait.pe.slurm.sh | perl -ne 'chomp; @a=split(" "); print "$a[-1]\n"')
		echo -e "[$(date)]\tSubmitted $s 'extract pe only' job -> $jobid"

		#prepare submission script for second MITObim pass
		cat $base/MITObim.slurm.sh | sed "s/-J MITObim.*/-J $s.pe.MITObim/" | sed "s?seed=.*?seed=$reference?" | sed "s/ref=.*/ref=$ref/" | sed "s/sample=.*/sample=$s/" | sed "s?readsSE=.*?readsSE=$s.$ref.interleaved.fastq.gz?" > MITObim.slurm.sh

        	#submit MITObim pass 2 job with dependency pe extraction
		jobid=$(sbatch --dependency=afterok:$jobid MITObim.slurm.sh | perl -ne 'chomp; @a=split(" "); print "$a[-1]\n"')
		echo -e "[$(date)]\tSubmitted $s 'MITObim pass 2' job -> $jobid"

		cd ..

		cd ..
	done

	cd ..
done

