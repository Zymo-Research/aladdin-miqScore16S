// Run MIQ score 16S code
params.publish_dir = "miqscore16s"
params.forward_primer_length = 17
params.reverse_primer_length = 24
params.amplicon_length = 510

process miqscore16s {
    container 'zymoresearch/miqscore16s:120524'
    publishDir "${params.publish_dir}", mode: 'copy'

    input:
    tuple val(name), path('standard_submitted_R1.fastq.gz'), path('standard_submitted_R2.fastq.gz')

    output:
    path '*.html', emit: report

    script:
    """
    export FORWARDREADS=\$PWD/standard_submitted_R1.fastq.gz
    export REVERSEREADS=\$PWD/standard_submitted_R2.fastq.gz
    mkdir output
    export OUTPUTFOLDER=\$PWD/output
    export SEQUENCEFOLDER=\$PWD
    export LOGFILE=\$PWD/miqcore16s.log
    export SAMPLENAME=${name}
    export FORWARDPRIMERLENGTH=${params.forward_primer_length}
    export REVERSEPRIMERLENGTH=${params.reverse_primer_length}
    export AMPLICONLENGTH=${params.amplicon_length}
    python3 /opt/miqscore16s/analyzeStandardReads.py
    mv output/*.html ./
    """
}
