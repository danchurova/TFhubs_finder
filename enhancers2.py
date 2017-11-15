#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import sys


def main():
    open_tss_enh = {}
    open_peak_enh = {}
    prev_chrom = None
    
    
    for line in sys.stdin.readlines():
        pieces = line.strip().split("\t")
        chrom, start, end, name = pieces
        start = int(start)
        end = int(end)
        
        if chrom != prev_chrom:
            open_tss_enh = {}
            open_peak_enh = {}
        else:
            open_tss_enh = {tss: tss_end for tss, tss_end in open_tss_enh.items() if start < tss_end }
            open_peak_enh = {peak: peak_end for peak, peak_end in open_peak_enh.items() if start < peak_end }

        prev_chrom = chrom
       
        if "chr" in name:
            tss = name
            open_tss_enh[tss] = end
            for peak in open_peak_enh:
                print(chrom, start, end, peak, tss)
        if "peak" in name:
            peak = name
            open_peak_enh[peak] = end
            for tss in open_tss_enh:
                print(chrom, start, end, peak, tss)


         
   
if __name__ == '__main__':
    main()
