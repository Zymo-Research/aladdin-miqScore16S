# aladdin-miqScore16S
Nextflow pipeline that calculates 16S MIQ score. Compatible with Compatible with [Aladdin Bioinformatics Platform](https://www.aladdin101.org/).. This is essentially a Nextflow wrapper that runs the code at [miqScore16SPublic](https://github.com/Zymo-Research/miqScore16SPublic) repo. Please refer to the original repo for more information on the source code.

## Adaptation for Aladdin
In order to be compatible with Aladdin platform, this pipeline requires a design CSV file as input. The design CSV file must have the following format
```
group,sample,read_1,read_2
,Sample1,s3://mybucket/this_is_s1_R1.fastq.gz,s3://mybucket/this_is_s1_R2.fastq.gz
```
Because the [miqScore16SPublic](https://github.com/Zymo-Research/miqScore16SPublic) code only supports one sample at a time, only the 1st row after the header is recognized.

## How to run the pipeline

### Prerequisites
* [Nextflow](https://www.nextflow.io) version 20.07.1 or later
* [Docker](https://www.docker.com/) if using `docker` profile
* Permissions to AWS S3 and Batch resources if using `awsbacth` profile

### Using Docker
```bash
nextflow run Zymo-Research/aladdin-miqScore16S \
	--profile docker \
	--design "<path to design CSV file>"
```

### Using AWS Batch
```bash
nextflow run Zymo-Research/aladdin-miqScore16S \
	-profile awsbatch \
	--design "<path to design CSV file>" \
	-work-dir "<work dir on S3>" \
	--awsqueue "<SQS ARN>" \
	--outdir "<output dir on S3>" \
```
The parameters `--awsqueue`, `-work-dir`, and `--outdir` are required when running on AWS Batch, the latter two must be directories on S3.

## Report and Documentation

#### Sample report
A sample report this pipeline produces can be found [here](https://zymo-research.github.io/pipeline-resources/reports/MIQscore_16S_sample_report.html).

#### Report documentation
A documentation explaining how to understand the report can be found [here](https://zymo-research.github.io/pipeline-resources/report_docs/MIQscore_documentation.html).
