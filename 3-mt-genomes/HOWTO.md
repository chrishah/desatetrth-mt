I am going to process the samples with different strategies based on whether they appear to contain only a single species of Gyrodactylus (`clean`) or the selective COI mapping indicated the presence of multiple species (`multi`).


Identify clean samples, i.e. samples that appear to contain only a single species:
```bash
cat ../2-selective-COI-mapping/selective_mapping_summary.tsv | grep "," -v > clean.txt
```

The remainder of the samples contain multiple species of Gyrodactylus:
```bash
cat ../2-selective-COI-mapping/selective_mapping_summary.tsv | grep "," > multi.tsv
```



