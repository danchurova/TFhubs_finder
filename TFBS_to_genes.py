#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import sys

def main():

    TF_list = set()
    TFS = open(sys.argv[1])
    genes = open(sys.argv[2])
    genes_peaks_TFBS = {}
    gene_info = {}


    for line in TFS:
        name,_,_,_, = line.strip().split("\t")
        name = name.rsplit("_",1)[0]
        TF_list.add(name)


    for line in genes.readlines():
        _,_,_,peak_name, gene_name = line.strip().split("\t")
        for chunk in gene_name.split(";"):
            key, value = chunk.split("=")
            gene_info[key] = value
        gene = gene_info['gene_name']
        genes_peaks_TFBS[gene] = genes_peaks_TFBS.get(gene, {})
        genes_peaks_TFBS[gene][peak_name] = set()


if __name__ == '__main__':
    main()
