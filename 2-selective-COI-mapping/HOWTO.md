I downloaded COI sequences from the 4 relevant Gyrodactylus species from Genbank and prepared them into a single fasta file that will be used as reference seed for every dataset.

```bash
cat GyrodactylusCOI.fasta | grep ">"
```

Will loop over the read data for all samples and submit a MITObim job against the COI references for each sample.

```bash
for file in $(ls -1 ../1-trimmed-data/*interleaved*)
do
	id=$(echo $file | perl -ne '@a=split("/"); @b=split("-",$a[-1]); print "$b[0]\n"')
	file=$(pwd)/$file
	echo -e "[$(date)]\t$id -> $file\n"
	mkdir $id
	cd $id
	cat ../MITObim.template.slurm.sh | sed "s/-J MITObim_/-J $id\_MITObim/g" | sed "s/^sample=/sample=$id/g" | sed "s?^reads1=?reads1=$file?g" > MITObim.slurm.sh
	sbatch MITObim.slurm.sh
	cd ..
done
```

I have prepared a MITObim slurm submission script that is being used as template and adjusted for each sample in the loop above. We are going to allow for up to 5 bases mismatch between the COI sequence and any given read. Reads are at most 100 bp so that is 5% mismatch, which should easily cover any intraspecific variation.

```bash
cat MITObim.template.slurm.sh
```

For a positive detection of a species in a given library we expect that at least 80% of the initial COI seed for the species needs to be covered with Illumina reads. The below loop checks that.

```bash
for sample in $(ls -hlrt ./ | grep "^d" | perl -ne 'chomp; @a=split(" "); print "$a[-1]\n"' | sort -n)
do
        echo -e "$sample\t$(cat $sample/iteration1/temp_baitfile.fasta | perl -ne 'chomp; $h=$_; $s=<>; $count=0; $total = (length($s) - 1); for (split //, $s){if ($_ =~ /[acgt]/){ $count++}} if (($count / $total) >= 0.8){ ($acc,$sp) = split(/\|/, $h); print "$sp\n"}' | sort -n | sed 's/_COI.*//' | tr '\n' ',' | sed 's/,$/\n/')"
done > selective_mapping_summary.tsv

cat selective_mapping_summary.tsv
```


###
```bash
cat <(echo) species.txt > table.tsv
for sample in $(ls -hlrt ./ | grep "^d" | perl -ne 'chomp; @a=split(" "); print "$a[-1]\n"' | sort -n)
do
	total=$(cat $sample/iteration0/$sample-Gyro_COI_assembly/$sample-Gyro_COI_d_info/$sample-Gyro_COI_info_contigstats.txt | grep "#" -v |perl -ne 'chomp; @a=split("\t"); $norm=sprintf("%.0f", ($a[3]/$a[1])*1349); $total+=$norm; if (eof()){print "$total\n"}')
	echo -e "$sample" > temp.txt
	props=""
	for sp in $(cat species.txt)
	do 
		norm_count=$(grep -P "$sp" $sample/iteration0/$sample-Gyro_COI_assembly/$sample-Gyro_COI_d_info/$sample-Gyro_COI_info_contigstats.txt | perl -ne '@a=split("\t"); $norm=sprintf("%.0f", ($a[3]/$a[1])*1349); print "$norm\t"')
		prop=$(echo -e "$total\t$norm_count" | perl -ne '@a=split("\t"); $norm=sprintf("%.3f", ($a[1]/$a[0])); print "$norm"')
		echo -e "$prop" >> temp.txt
		props=$props" "$prop
	done 
	paste table.tsv temp.txt > temp_table.tsv
	mv temp_table.tsv table.tsv
	rm temp.txt
done
```


