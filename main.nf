#!/usr/bin/env nextflow
/*
A nextflow pipeline to calculate MIQ score, that is compatible with Aladdin platform.
This is essentially a wrapper to run the code in MIQ score public repos, plus code to interact with Aladdin platform.
*/

// DSL 2
nextflow.enable.dsl=2

// Load functions
include { setup_channel } from ('./libs/setup_channel')
include { collect_summary } from ('./libs/collect_summary')

// AWSBatch sanity checking
if ( workflow.profile == 'awsbatch') {
    if (!params.awsqueue || !params.awsregion) exit 1, "Specify correct --awsqueue and --awsregion parameters on AWSBatch!"
    // Check outdir paths to be S3 buckets if running on AWSBatch
    // related: https://github.com/nextflow-io/nextflow/issues/813
    if (!params.outdir.startsWith('s3:')) exit 1, "Outdir not on S3 - specify S3 Bucket to run on AWSBatch!"
    // Prevent trace files to be stored on S3 since S3 does not support rolling files.
    if (params.tracedir.startsWith('s3:')) exit 1, "Specify a local tracedir or run without trace! S3 cannot be used for tracefiles."
}

/*
 * SET & VALIDATE INPUT CHANNELS
 */
design = setup_channel(params.design, "design CSV file", true, "")

/*
 * COLLECT SUMMARY & LOG
 */
log.info "Aladdin miqScore v${workflow.manifest.version}"
def summary = collect_summary(params, workflow)
log.info summary.collect { k,v -> "${k.padRight(21)}: $v" }.join("\n")
// Save workflow summary plain text
Channel.from( summary.collect{ [it.key, it.value] } )
       .map { k,v -> "${k.padRight(21)} : $v" }
       .collectFile(name: "${params.outdir}/pipeline_info/workflow_summary.txt", newLine: true, sort: 'index')

/*
 * PROCESS DEFINITION
 */
include { check_design } from "./processes/check_design"
include { miqscore16s } from "./processes/miqscore16s" addParams(
    publish_dir: "${params.outdir}/miqscore16s",
    foward_primer_length: params.foward_primer_length,
    reverse_primer_length: params.reverse_primer_length,
    amplicon_length: params.amplicon_length
)
include { summarize_downloads } from "./processes/summarize_downloads" addParams(
    publish_dir: "${params.outdir}/download_data"
)

/*
 * WORKFLOW DEFINITION
 */
workflow {
    check_design(design)
    check_design.out.checked_design
        .splitCsv( header: true )
        .first() // Only support 1 pair of FASTQ for now
        .branch {
            read1      : file(it['read_1'])
            read2      : file(it['read_2'])
            sample_name: it['sample']
        }
        .set { input }
    miqscore16s(input.sample_name, input.read1, input.read2)
    output_locations = miqscore16s.out.report.map { "${params.outdir}/miqscore16s/" + it.getName() } 
    summarize_downloads(output_locations)
}

/*
 * LOG ON COMPLETION
 */
workflow.onComplete {
    if (workflow.stats.ignoredCount > 0 && workflow.success) {
      log.info "Warning, pipeline completed, but with errored process(es)"
      log.info "Number of ignored errored process(es) : ${workflow.stats.ignoredCount}"
      log.info "Number of successfully ran process(es) : ${workflow.stats.succeedCount}"
    }
    if(workflow.success){
        log.info "[miqScore] Pipeline completed successfully"
    } else {
        log.info "[miqScore] Pipeline completed with errors"
    }
}