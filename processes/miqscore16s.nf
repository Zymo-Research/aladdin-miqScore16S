// Run MIQ score 16S code
params.publish_dir = "miqscore16s"
params.foward_primer_length = 16
params.reverse_primer_length = 24
praram.amplicon_length = 510

process miqscore16s {
    container 'zymoweb/miqscore16spublic:latest'
    containerOptions "--volume ${task.workDir}/data:/data"
    publishDir "${params.publish_dir}", mode: 'copy',
        saveAs: { file(it).getName() }

    input:
    path read1, stageAs: 'data/input/sequence/standard_submitted_R1.fastq'
    path read2, stageAs: 'data/input/sequence/standard_submitted_R2.fastq'
    env SAMPLENAME

    output:
    path 'data/output/*.html', emit: report

    script:
    """
    mkdir -p /data/output
    export FORWARDPRIMERLENGTH=${params.forward_primer_length}
    export REVERSEPRIMERLENGTH=${params.reverse_primer_length}
    export AMPLICONLENGTH=${params.amplicon_length}
    python3 /opt/miqscore16s/analyzeStandardReads.py
    """
}