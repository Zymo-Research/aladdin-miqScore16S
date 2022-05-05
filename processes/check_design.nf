// Sanity check design file
process check_design {
    container 'python:3.9'

    input:
    path design

    output:
    path "checked_${design}", emit: checked_design

    script:
    """
    check_design.py $design
    """
}