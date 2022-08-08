#!/usr/bin/env python

import argparse
import re
import os

def check_design(DesignFileIn, DesignFileOut):

    HEADER = ['group','sample','read_1','read_2']
    label_pattern = r"^[a-zA-Z0-9][a-zA-Z0-9_\-\.]*$"
    fastq_pattern = r"^.*(fastq|fq)(\.gz)?$"
    
    with open(DesignFileIn, "r") as fin:
        # Check the header first
        header = fin.readline().strip().split(',')
        assert header == HEADER, "Header of design file Incorrect! Should be {}".format(','.join(HEADER))
        
        labels = []
        groups = []
        # Check the rest
        for line in fin:
            cols = line.strip().split(',')
            # Check the number of columns in each line
            assert len(cols) == len(HEADER), "Number of columns incorrect in line '{}'!".format(line.strip())
            # Check the sample label
            assert re.match(label_pattern, cols[1]), "Sample label {} contains illegal characters or does not start with letters!".format(cols[1])
            assert cols[1] not in labels, "Duplicate sample label {}".format(cols[1])
            labels.append(cols[1])
            # Check the fastq file locations
            assert cols[2], "R1 path could not be missing!"
            assert re.match(fastq_pattern, cols[2]), "R1 path must point to a FASTQ file or gziped FASTQ file!"
            assert cols[3], "R2 path could not be missing!"
            assert re.match(fastq_pattern, cols[3]), "R2 path must point to a FASTQ file or gziped FASTQ file!"
            # Check the group label
            if cols[0]:
                assert re.match(label_pattern, cols[0]), "Group label {} contains illegal characters or does not start with letters!".format(cols[0])
                groups.append(cols[0])
            assert len(groups)==0 or len(groups)==len(labels), "Group label(s) missing in some but not all samples!"
    
    os.rename(DesignFileIn, DesignFileOut)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="""Sanity check the design CSV file""")
    parser.add_argument("DesignFileIn", type=str, help="Input design CSV file")
    args = parser.parse_args()
    check_design(args.DesignFileIn, "checked_"+args.DesignFileIn)