#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import sys
import os
import subprocess
import glob

def main():
    # input_fasta = open(sys.argv[2])
    thresholds_input = open(sys.argv[1])
    thresholds = {}
    
    
    for line in thresholds_input.readlines():
        name,_,_,p_value = line.strip().split("\t")
        thresholds[name] = p_value
    print(thresholds)  
    path = "./data/pwm/"
    for tf in glob.glob(os.path.join(path, "*.pwm")):
        print(tf)
        name = tf.split("/")[-1].replace(".pwm","")
        threshold = thresholds[name]
        subprocess.call(['java','-jar', 'sarus.jar', "./output_fasta/ATAC.GM12878.50Kcells.rep1_peaks_promoters.fa.out", tf, threshold], stdout=open("TFBS_output/{}.txt".format(name), "w"))

if __name__ == '__main__':
    main()
