#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import sys

def main():
    promoter_peaks = set()
    promoters = open(sys.argv[1])
    all_peaks = open(sys.argv[2])


    for line in promoters.readlines():
        peak_1 = line.strip()
        promoter_peaks.add(peak_1)

    for line_2 in all_peaks.readlines():
        pieces = line_2.strip().split("\t")
        chrom, start, end, peak_2,_,_,_,_,_,_ = pieces
        if peak_2 not in promoter_peaks:
            print(chrom, start, end, peak_2, sep="\t")
        
if __name__ == '__main__':
    main()	
	
