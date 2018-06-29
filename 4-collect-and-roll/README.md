
Collect all circular mt genomes that were recovered and 'roll' them so that they are all start at the same base. 

Reference mt genomes all start with the COXII gene. We'll use `blastx` to align the COXII protein to the circular mt genomes and then make the base matching the start of the gene start of the circular mt genome.

Download the COXIII genes from both G.salaris (accession: ABI74676) and G. derjavinoides (accession: ABX59348) from Genbank.

```bash
mkdir COXIII_DB
for acc in $(echo -e "ABX59348\nABI74676")
do 
	wget -O - "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nucleotide&id=$acc&rettype=fasta"
done > COXIII_DB/COXIII.fasta
```

Build blast database from COXIII protein sequences.

```bash
makeblastdb -in COXIII_DB/COXIII.fasta -dbtype prot -out COXIII_DB/COXIII_references
```

Collect the new mt genomes.
```bash
mkdir mt-genomes-before

#find all files containing 'renamed' in the relevant directories and create symbolic links to these
find ../3-mt-genomes/ -name '*.renamed.*' -exec ln -s $(pwd)/{} mt-genomes-before/ \;

```

Run `blastx` for each of the mt genomes against the COXIII proteins.
```bash
mkdir blasting
cd blasting
for mt in $(ls -1 ../mt-genomes-before/)
do 
	echo -e "Processing $mt\n"
	id=$(echo -e "$mt" | sed 's/.renamed.*//')
	#return standard blast output
	blastx -db ../COXIII_DB/COXIII_references -query ../mt-genomes-before/$mt -evalue 1e-50 -out $id.blastx.out
	#return tab delimited output
	blastx -db ../COXIII_DB/COXIII_references -query ../mt-genomes-before/$mt -evalue 1e-50 -outfmt 6 -out $id.blastx.outfmt6.out
done
cd ..
``` 

Roll each mt genome to the first base of COxIII.
```bash
mkdir roll-to_COXIII
cd roll-to-COXIII
for mt in $(ls -1 ../mt-genomes-before/)
do
        echo -e "Processing $mt\n"
        id=$(echo -e "$mt" | sed 's/.renamed.*//')
	
	#get start base from blast result and roll mt genome
	cat <(cat ../blasting/$id.blastx.outfmt6.out | cut -f 7 | head -n 1) ../mt-genomes-before/$id.renamed.fasta | perl -ne 'chomp; if ($. == 1){$start=$_-1}else{$h=$_; $s=<>; chomp($s); $newseq=substr($s, $start).substr($s, 0, $start); print "$h\n$newseq\n"}' > $id.renamed.rolled.fasta
done


cd ..
```
