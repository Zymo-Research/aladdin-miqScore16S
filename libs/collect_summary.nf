def collect_summary(params, workflow) {
    def summary = [:]
    if (workflow.revision) {
        summary['Pipeline Release'] = workflow.revision
    }
    // This has the bonus effect of catching both -name and --name
    def run_name = params.name
    if (!(workflow.runName ==~ /[a-z]+_[a-z]+/)) {
        run_name = workflow.runName
    }
    summary['Run Name']                  = run_name ?: workflow.runName
    summary['Design']                    = params.design
    summary['Max Resources']             = "$params.max_memory memory, $params.max_cpus cpus, $params.max_time time per job"
    summary['Output dir']                = params.outdir
    summary['Launch dir']                = workflow.launchDir
    summary['Working dir']               = workflow.profile == 'awsbatch' ? "s3:/${workflow.workDir}" : workflow.workDir
    summary['Config Profile']            = workflow.profile
    if (workflow.profile == 'awsbatch') {
        summary['AWS Region']            = params.awsregion
        summary['AWS Queue']             = params.awsqueue
    }
    summary['Forward Primer Length']     = params.forward_primer_length
    summary['Reverse Primer Length']     = params.reverse_primer_length
    summary['Amplicon Length']           = params.amplicon_length
    
    return summary
}