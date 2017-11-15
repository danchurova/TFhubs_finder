#/usr/bin/env bash

rm -r output
mkdir output || true

function process() {
	file=$1
	threshold=$2
	input=data/$file

	filtered_output=output/${file}.filtered.bed
	prepared_output=output/${file}.prepared
	combined_output=output/${file}.combined
	promoters_output=output/${file}.promoters.bed
	uniq_promoters_output=output/${file}.uniq_promoters
	enhancers_output=output/${file}.enhancers.bed
        combined_enhanc_output=output/${file}.comb_enhanc.bed
        FANTOM5_enhancers_output=output/${file}.FANTOM5_enhanc.bed

	echo "filtering $file with threshold $threshold..."
	cat $input | awk "{if (\$5 > $threshold) {print}}" | sort -k1,1 -k2,2n > $filtered_output
	echo "preparing peaks..."
	cat $filtered_output | awk 'BEGIN {OFS="\t"} {print $1,$2,$3,"peak",$4}' > $prepared_output
	echo "combining with TSS data..."
	cat $prepared_output output/promoter_regions.txt | sort -k1,1 -k2,2n > $combined_output
	echo "looking for intersections..."
	cat $combined_output | python3 ./intersect.py  > $promoters_output
	echo "looking for enhancers..."
	cat $promoters_output | awk '{print $4}' | uniq > $uniq_promoters_output
	python3 ./enhancers.py $uniq_promoters_output $filtered_output > $enhancers_output
        echo "analyzing found enhancers..."
        cat data/hg19_enhancer_tss_associations_FANTOM5data.bed | tail -n +3 > data/hg19_FANTOM5data.bed
        cat $enhancers_output data/hg19_FANTOM5data.bed | sort -k1,1 -k2,2n | awk 'BEGIN {OFS="\t"} {print $1,$2,$3,$4}' > $combined_enhanc_output 
	cat $combined_enhanc_output | python3 ./enhancers2.py > $FANTOM5_enhancers_output 
	 
}
echo "getting transcripts..."

tail -n +8 data/gencode.v19.annotation.gff3 | awk '
BEGIN {OFS="\t"}{
	if ($7 == "+") {print $1,$3,$4,$4+1,$9}
	else if ($7 == "-") {print $1,$3,$5-1,$5,$9}
}' | grep -wE "(transcript)" | awk 'BEGIN {OFS="\t"}{print $1,$2,$3,$4,$5}' > output/gencode.v19.TSS.txt 
echo "done!"

echo "determining promoter regions..."
cat output/gencode.v19.TSS.txt | awk 'BEGIN {OFS="\t"}{print $1,$3-5000,$4+5000,"TSS",$5}' > output/promoter_regions.txt
echo "done!"

process ATAC.GM12878.50Kcells.rep1_peaks.narrowPeak 3.74665
process ATAC.H1hES.50Kcells.rep2_peaks.narrowPeak 4.52314
process ATAC.K562.50Kcells.rep1_peaks.narrowPeak 4.99941

