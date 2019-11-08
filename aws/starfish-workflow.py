import subprocess
import json


# Submit array job
submitCommand = "aws --profile spacetx-admin batch submit-job --cli-input-json file://submit-array-job.json"
process = subprocess.Popen(submitCommand.split(), stdout=subprocess.PIPE)
output, error = process.communicate()
submit_info = json.loads(output)

# get jobID for merge job
job_id = submit_info["jobId"]


# Add Job ID to merge-results params json
with open('aws-merge-results-job/submit-merge-job.json', "r+") as json_file:
    merge_job_params = json.load(json_file)
    merge_job_params["dependsOn"] = [{"jobId": job_id}]
    json_file.seek(0)  # <--- should reset file position to the beginning.
    json.dump(merge_job_params, json_file, indent=4)
    json_file.truncate()


# Submit merge job
submitCommand = "aws --profile spacetx-admin batch submit-job --cli-input-json file://submit-merge-job.json"
process = subprocess.Popen(submitCommand.split(), stdout=subprocess.PIPE)
output, error = process.communicate()
submit_info = json.loads(output)

print(submit_info)


