#/usr/bin/env bash

rm -r output
mkdir output || true

rm -r output_fasta
mkdir output_fasta || true

function process() {
	file=$1
	threshold=$2
	input=data/$file

	prepared_output=output/${file}.prepared.bed
	promoters_output=output/${file}.promoters.bed
	uniq_promoters_output=output/${file}.uniq_promoters.bed
	enhancers_output=output/${file}.enhancers.bed
        FANTOM5_enhancers_output=output/${file}.FANTOM5_enhanc.bed
        uniq_FANTOM5_enhanc_output=output/${file}.uniq_FANTOM5_enhanc.bed
        enhancers_left_output=output/${file}.enhanc_left.bed
        combined_enhanc_tads_output=output/${file}.comb_enhanc_tads.bed
        unfiltered_tads_enhanc_output=output/${file}.unfilt_enhanc_tads.bed
        TADS_with_repeats_output=output/${file}.TADS_with_repeats
        TADS_enhancers_output=output/${file}.TADS_enhanc.bed
        promoters_fasta_output=output_fasta/${file}.promoters.fa
        FANTOM5_enhanc_fasta_output=output_fasta/${file}.FANTOM5.fa
        TADS_enhanc_fasta_output=output_fasta/${file}.TADS.fa
        


	echo "1. filtering $file with threshold $threshold..."
	cat $input | awk "BEGIN {OFS=\"\t\"} {if (\$5 > $threshold) {print \$1,\$2,\$3,\"peak\",\$4}}" > $prepared_output
	
	echo "2. looking for promoters..."
	cat $prepared_output output/promoter_regions.txt.bed | sort -k1,1 -k2,2n | python3 intersect.py TSS > $promoters_output
        # output: chrom, start, end, peak, gene

	echo "3. looking for enhancers..."
	cat $promoters_output | sort -u -k4,4 > $uniq_promoters_output
	python3 enhancers.py $uniq_promoters_output $prepared_output > $enhancers_output
        # output: chrom, start, end, "peak", peak

        echo "4. looking for fantom5 enhancers..."
        cat data/hg19_enhancer_tss_associations_FANTOM5data.bed | tail -n +3 | awk 'BEGIN {OFS="\t"} {print $1,$7-200,$7+200,"genes",$4}' > output/hg19_FANTOM5data.bed
        cat $enhancers_output output/hg19_FANTOM5data.bed | sort -k1,1 -k2,2n | python3 intersect.py genes > $FANTOM5_enhancers_output
        echo "done!"
        echo "getting uniq fantom5 enhancers..."
        #cat $FANTOM_enhancers_output | sort -k4,4 | sort -u -k4,4 > $uniq_FANTOM5_enhanc_output
        echo "done!"
        
        echo "5. looking for TADS enhancers..."
        python3 ./enhancers_left.py $FANTOM5_enhancers_output $enhancers_output > $enhancers_left_output
        cat data/allTADS.bed | awk 'BEGIN {OFS="\t"} {print $1,$2,$3,"TADS",$4}' > $combined_enhanc_tads_output
        cat $enhancers_left_output $combined_enhanc_tads_output | sort -k1,1 -k2,2n | python3 intersect.py TADS > $unfiltered_tads_enhanc_output
        python3 ./filter_tads.py $promoters_output $unfiltered_tads_enhanc_output >  $TADS_with_repeats_output
        python3 merge_TADS.py $TADS_with_repeats_output > $TADS_enhancers_output

        echo "6. making fasta of promoters and enhancers..."
        bedtools getfasta -fi data/GRCh37.p13.genome.fa -bed $uniq_promoters_output -name -fo $promoters_fasta_output
        bedtools getfasta -fi data/GRCh37.p13.genome.fa -bed $FANTOM5_enhancers_output -name -fo $FANTOM5_enhanc_fasta_output
        bedtools getfasta -fi data/GRCh37.p13.genome.fa -bed $TADS_enhancers_output -name -fo $TADS_enhanc_fasta_output
        echo "done!" 
}
echo "getting transcripts..."

tail -n +8 data/gencode.v19.annotation.gff3 | awk '
BEGIN {OFS="\t"}{
	if ($7 == "+") {print $1,$3,$4,$4+1,$9}
	else if ($7 == "-") {print $1,$3,$5-1,$5,$9}
}' | grep -wE "(transcript)" | awk 'BEGIN {OFS="\t"}{print $1,$2,$3,$4,$5}' > output/gencode.v19.TSS.txt 
echo "done!"

echo "determining promoter regions..."
cat output/gencode.v19.TSS.txt | awk 'BEGIN {OFS="\t"}{print $1,$3-5000,$4+5000,"TSS",$5}' > output/promoter_regions.txt.bed
echo "done!"

process ATAC.GM12878.50Kcells.rep1_peaks.narrowPeak 3.74665
#process ATAC.H1hES.50Kcells.rep2_peaks.narrowPeak 4.52314
#process ATAC.K562.50Kcells.rep1_peaks.narrowPeak 4.99941

