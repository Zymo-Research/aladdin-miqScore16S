// Downsample FASTQ files

process downsample {
    container 'quay.io/biocontainers/seqtk:1.4--he4a0461_1'

    input:
    tuple val(name), path(read_1), path(read_2)

    when:
    params.downsample_num

    output:
    tuple val(name), path("${name}_downsample_R1.fastq.gz"), path("${name}_downsample_R2.fastq.gz"), emit: reads

    script:
    """
    readnum=\$((\$(zcat $read_1 | wc -l) / 4))
    if ((\$readnum > $params.downsample_num))
    then
    seqtk sample -s1000 $read_1 $params.downsample_num > ${name}_downsample_R1.fastq
    gzip ${name}_downsample_R1.fastq
    seqtk sample -s1000 $read_2 $params.downsample_num > ${name}_downsample_R2.fastq
    gzip ${name}_downsample_R2.fastq
    else
    [ ! -f ${name}_downsample_R1.fastq.gz ] && ln -s $read_1 ${name}_downsample_R1.fastq.gz
    [ ! -f ${name}_downsample_R2.fastq.gz ] && ln -s $read_2 ${name}_downsample_R2.fastq.gz
    fi
    """
}