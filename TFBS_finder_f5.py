#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import sys
import os
import subprocess
import glob

def main():
    input_fasta = open(sys.argv[2])
    thresholds_input = open(sys.argv[1])
    thresholds = {}
    
    
    
    for line in thresholds_input.readlines():
        name,_,_,p_value = line.strip().split("\t")
        thresholds[name] = p_value
      
    path = "./data/pwm/"
    directory = "FANTOM5/" + input_fasta.name[13:]
    os.mkdir("TFBS_output/{}".format(directory))
    
    for tf in glob.glob(os.path.join(path, "*.pwm")):
        name = tf.split("/")[-1].replace(".pwm","")
        threshold = thresholds[name]
        subprocess.call(["java", "-cp", "sarus-26Nov2017.jar", "ru.autosome.SARUS", input_fasta.name, tf, threshold, "--output-bed", "skipn"], stdout=open("TFBS_output/FANTOM5/{}/{}.bed".format(input_fasta.name[13:],name), "w"))

if __name__ == '__main__':
    main()
