import argparse
import boto3


session = boto3.Session(profile_name='spacetx-admin')
batch = session.client('batch')
# batch = boto3.client('batch')
parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)

parser.add_argument("--experiment-url", help="The url to your experiment.json file", type=str)
parser.add_argument("--num-fovs", help="The number of fields of view in the experiment", type=int)
parser.add_argument("--recipe-location", help="The location of the recipe file to process "
                                              "the experiment with", type=str)
parser.add_argument("--results-bucket", help="The s3 bucket to copy the results to", type=str)
parser.add_argument("--job-queue", help="The job queue to send the jobs to", type=str, default="first-run-job-queue")
args = parser.parse_args()


def main():
    experiment_location = args.experiment_url
    num_fovs = args.num_fovs
    recipe_location = args.recipe_location
    results_bucket = args.results_bucket
    job_queue = args.job_queue
    process_job_id = submit_array_job(experiment_location=experiment_location,
                                      num_fovs=num_fovs,
                                      recipe_location=recipe_location,
                                      results_bucket=results_bucket,
                                      job_queue=job_queue)
    print(f"Process fovs array job {process_job_id} successfully submitted.")
    merge_job_id = submit_merge_job(job_id=process_job_id, results_bucket=results_bucket,
                                    job_queue=job_queue)
    print(f"Merge results job {merge_job_id} successfully submitted.")


def submit_array_job(
        experiment_location,
        num_fovs,
        recipe_location,
        results_bucket,
        job_queue):
    submitJobResponse = batch.submit_job(
        jobName="process-fov-batch-job",
        jobQueue=job_queue,
        jobDefinition="process-fov",
        arrayProperties={"size": num_fovs},
        containerOverrides={
            "environment": [
                {
                    "name": "RECIPE_LOCATION",
                    "value": recipe_location
                },
                {
                    "name": "EXPERIMENT_URL",
                    "value": experiment_location
                },
                {
                    "name": "RESULTS_LOCATION",
                    "value": results_bucket
                  }
                ]
              }
            )

    return submitJobResponse['jobId']


def submit_merge_job(job_id, results_bucket, job_queue):
    submitJobResponse = batch.submit_job(
        jobName="merge-results-job",
        jobQueue=job_queue,
        jobDefinition="merge-job",
        dependsOn=[{"jobId": job_id}],
        containerOverrides={
            "environment": [
                {
                    "name": "RESULTS_LOCATION",
                    "value": results_bucket
                }
            ]
        }
    )

    return submitJobResponse['jobId']


if __name__ == '__main__':
    main()
