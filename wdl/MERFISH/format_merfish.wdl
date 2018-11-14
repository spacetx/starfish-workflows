task format_merfish {
    String input_s3_folder_prefix
    String output_s3_folder_prefix

    # TODO I don't think we have s3 installed in the container. how to deal?
    # TODO this will likely be something we'd prefer to parallelize if we are running in the cloud
    command {
        # download the data from s3
        aws s3 sync ${input_s3_folder_prefix} ./data

        python3 examples/get_merfish_u2Os_data.py \
            --input_dir ./data \
            --output_dir ./formatted

        aws s3 sync ./formatted ${output_s3_folder_prefix}

        # run the formatting script

        # upload the data back to s3
    }

    runtime {}

    output {}
}