// Run MIQ score 16S code
params.publish_dir = "miqscore16s"
params.forward_primer_length = 16
params.reverse_primer_length = 24
params.amplicon_length = 510

process miqscore16s {
    container 'zymoweb/miqscore16spublic:latest'
    publishDir "${params.publish_dir}", mode: 'copy'

    input:
    env SAMPLENAME
    path read_1
    path read_2

    output:
    path '*.html', emit: report

    script:
    """
    mkdir -p /data/input/sequence
    mv $read_1 /data/input/sequence/standard_submitted_R1.fastq
    mv $read_2 /data/input/sequence/standard_submitted_R2.fastq
    mkdir -p /data/output
    export FORWARDPRIMERLENGTH=${params.forward_primer_length}
    export REVERSEPRIMERLENGTH=${params.reverse_primer_length}
    export AMPLICONLENGTH=${params.amplicon_length}
    python3 /opt/miqscore16s/analyzeStandardReads.py
    mv /data/output/*.html ./
    """
}