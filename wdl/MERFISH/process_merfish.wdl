task FindFieldOfViewNumber {
    File experiment_json
    command <<<
        python3 <<CODE

        import starfish

        experiment = starfish.Experiment.from_json("${experiment_json}")

        # write the number of fovs to file
        with open("num_fovs.txt", "w") as f:
            f.write(len(experiment))

        CODE
    >>>
    runtime {
        docker: "spacetx/starfish:latest"
    }

    output {
        Int num_fov = read_int("num_fovs.txt")
    }
}


task ProcessFieldOfView {

    # Input Data
    File experiment_json
    Int field_of_view

    # Filtering Parameters
    Float gaussian_high_pass_sigma = 3.0
    Int deconvolution_iterations = 15
    Float deconvolution_sigma = 2.0
    Float gaussian_low_pass_sigma = 1.0

    # Spot Finding Parameters
    Float spot_finding_distance_threshold = 0.5176
    Float spot_finding_magnitude_threshold = 0.00001775
    Int spot_finding_min_area = 2
    Int spot_finding_max_area = 100

    command <<<
        python3 <<CODE

        import numpy as np
        import starfish

        # get the data
        experiment = starfish.Experiment.from_json("${experiment_json}")
        fov = experiment["fov_${field_of_view}"]  # TODO having the "fov_" prefix is not general
        image_stack = fov["primary"]

        # filter the data
        ghp = starfish.image.Filter.GaussianHighPass(sigma=${gaussian_high_pass_sigma})
        ghp.run(primary_image, verbose=False, in_place=True)

        dpsf = starfish.image.Filter.DeconvolvePSF(
            num_iter=${deconvolution_iterations},
            sigma=${deconvolution_sigma},
            clip=True
        )
        dpsf.run(primary_image, verbose=False, in_place=True)

        glp = starfish.image.Filter.GaussianLowPass(sigma=${gaussian_low_pass_sigma})
        glp.run(primary_image, verbose=False, in_place=True)

        # TODO add the scale factors to the U2-OS TileFetcher
        # do the gross scale factor hack
        scale_factors = {
            (t[Indices.ROUND], t[Indices.CH]): t['scale_factor']
            for index, t in primary_image.tile_metadata.iterrows()
        }
        for indices in primary_image._iter_indices():
            data = primary_image.get_slice(indices)[0]
            scaled = data / scale_factors[indices[Indices.ROUND.value], indices[Indices.CH.value]]
            primary_image.set_slice(indices, scaled)

        # call spots
        psd = SpotFinder.PixelSpotDetector(
            codebook=experiment.codebook,
            metric="euclidean",
            distance_threshold=${spot_finding_distance_threshold},
            magnitude_threshold=${spot_finding_magnitude_threshold},
            min_area=${spot_finding_min_area},
            max_area=${spot_finding_max_area},
            norm_order=2,
            crop_z=0,
            crop_y=40,
            crop_x=40
        )

        spot_intensities, prop_results = psd.run(scaled_image)
        spot_intensities = spot_intensities.loc[spot_intensities[Features.PASSES_THRESHOLDS]]

        # run watershed
        # TODO

        # assign spots
        # TODO

        # write outputs
        spot_intensities.save("intensities.nc")
        np.save(label_image, "segmentation.npy")

        CODE
    >>>

    runtime {
        docker: "spacetx/starfish:latest"
    }

    output {
        File intensity_table = "intensities.nc"
        File segmentation_image = "segmentation.npy"
    }
}


task MergeIntensityTables {
    Array[File] intensity_tables

    command {
        python3 <<CODE

        from starfish.intensity_table.concatenate import concatenate

        # load all the tables
        intensity_table_names = ["${sep='", "' intensity_tables}"]
        intensity_tables = (starfish.IntensityTable.load(t) for t in intensity_table_names)

        # concatenate
        merged_table = concatenate(intensity_tables)

        # save the result
        merged_table.save("intensities.nc")

        CODE
    }

    runtime {
        docker: "spacetx/starfish:latest"
    }

    output {
        File intensity_table = "intensities.nc"
    }
}

workflow MERFISH {

    meta {
        description: "Processes a MERFISH experiment"
    }

    File experiment_json
    Float high_pass_gaussian_kernel_size = 1

    call FindFieldOfViewNumber {
        input:
            experiment_json = experiment_json
    }

    scatter(i in FindFieldOfViewNumber.num_fov) {
        call ProcessFieldOfView {
            input:
                experiment_json = experiment_json,
                field_of_view = i
        }
    }

    call MergeIntensityTables {
        input:
            intensity_tables = ProcessFieldOfView.intensity_table
    }

    output {
        File intensity_table = MergeIntensityTables.intensity_table
    }


}