#!/usr/bin/env python

import argparse
import re
import csv

def check_design(DesignFileIn, DesignFileOut):

    required_columns = ['sample','read_1','read_2']
    label_pattern = r"^[a-zA-Z][a-zA-Z0-9_]*$"
    fastq_pattern = r"^.*(fastq|fq)(\.gz)?$"
    
    with open(DesignFileIn, "r") as fin:

        reader = csv.DictReader(fin)

        # Check if header contains required columns
        assert all(column in reader.fieldnames for column in required_columns), \
            "The design file must contain the following columns: 'sample', 'read_1', 'read_2'."
        
        # Open the output file to write the first row after validation
        with open(DesignFileOut, mode='w', newline='') as fout:
            writer = csv.DictWriter(fout, fieldnames=reader.fieldnames)
            writer.writeheader()
            # Iterate over rows to validate data
            for i, row in enumerate(reader):
                if i == 0:
                    sample = row['sample']
                    read_1 = row['read_1']
                    read_2 = row['read_2']
                    # Validate 'sample' column
                    assert re.match(label_pattern, sample), "Sample label {} contains illegal characters or does not start with letters!".format(sample)
                    # Validate 'read_1' and 'read_2' columns
                    assert re.match(fastq_pattern, read_1), "R1 path must point to a FASTQ file or gziped FASTQ file!"
                    if read_2:
                        assert re.match(fastq_pattern, read_2), "R2 path must point to a FASTQ file or gziped FASTQ file!"
                    # Write the first row to the output file
                    writer.writerow(row)
                else:
                    print("Any rows after the first in the design file are ignored in this pipeline!")
                    break

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="""Sanity check the design CSV file""")
    parser.add_argument("DesignFileIn", type=str, help="Input design CSV file")
    args = parser.parse_args()
    check_design(args.DesignFileIn, "checked_"+args.DesignFileIn)