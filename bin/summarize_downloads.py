#!/usr/bin/env python
###
# This program creates a JSON file that lists the locations of files for download
# and how to display those files on aladdin platform.
###

import argparse
import logging
import os
import json

# Create a logger
logging.basicConfig(format='%(name)s - %(asctime)s %(levelname)s: %(message)s')
logger = logging.getLogger(__file__)
logger.setLevel(logging.INFO)

def summarize_downloads(locations):

    """
    :param locations: a file containing locations of files on S3
    """

    file_info = dict()

    # Define what to do with each type of files
    categories = {
        '.html': ('Report', 'report'),
    }

    # Read the file locations
    with open(locations, 'r') as fh:
        for line in fh:
            info = dict()
            path = line.strip()
            info['path'] = path
            logger.info("Processing file {}".format(path))
            # Get file name
            fn = os.path.basename(path)
            # Check each file category
            for suffix, values in categories.items():
                if fn.endswith(suffix):
                    file_type, scope = values
                    info['file_type'] = file_type
                    info['scope'] = scope
                    file_info[fn] = info
                    break
            else:
                logger.error("File {} did not match any expected patterns".format(fn))
    
    # Output the dict to JSON
    with open('files_to_download.json', 'w') as fh:
        json.dump(file_info, fh, indent=4)

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="""Generate a json file for displaying outputs on aladdin platform""")
    parser.add_argument("locations", type=str, help="File with all the locations of files on S3")
    args = parser.parse_args()
    summarize_downloads(args.locations)