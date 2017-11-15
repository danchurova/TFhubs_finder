#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys

def main():
    open_tss = {}
    open_peak = {}
    prev_chrom = None

    for line in sys.stdin.readlines():
        pieces = line.strip().split("\t")
        chrom, start, end, kind, name = pieces
        start = int(start)
        end = int(end)

        if kind == 'TSS':
            tss = name
            open_tss[tss] = end
            for peak, (peak_start, peak_end) in open_peak.items():
                print(chrom, peak_start, peak_end, peak, tss, sep="\t")

        if kind == 'peak':
            peak, peak_start, peak_end = name, start, end
            open_peak[peak] = peak_start, peak_end
            for tss in open_tss:
                print(chrom, peak_start, peak_end, peak, tss, sep="\t")
        
        if chrom != prev_chrom:
            open_tss = {}
            open_peak = {}
        else:
            open_tss = {tss: tss_end for tss, tss_end in open_tss.items() if start < tss_end }
            open_peak = {peak: (peak_start, peak_end) for peak, (peak_start, peak_end) in open_peak.items() if start < peak_end }

        prev_chrom = chrom

        

if __name__ == '__main__':
    main()

