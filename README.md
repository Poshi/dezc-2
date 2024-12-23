# Data Engineering ZoomCamp - Module 2 - Workflow orchestration

For this module, we used [Kestra](http://kestra.io) as the orchestrator tool.
We used the Docker compose file provided by the course to start the necessary
services on localhost. You just have to run

    docker compose up

and the Kestra service and support database will be started.

Once you have Kestra running, you can upload the different workflows by using
the command line:

    curl -X POST http://localhost:8080/api/v1/flows/import -F fileUpload=@gcp_kv_setup.yaml
    curl -X POST http://localhost:8080/api/v1/flows/import -F fileUpload=@gcp_resources_setup.yaml
    curl -X POST http://localhost:8080/api/v1/flows/import -F fileUpload=@gcp_resources_destroy.yaml
    curl -X POST http://localhost:8080/api/v1/flows/import -F fileUpload=@process_month.yaml
    curl -X POST http://localhost:8080/api/v1/flows/import -F fileUpload=@taxi_data_loader.yaml

All these flows live in the *dezc* namespace.

To run them, you should start by modifying the `gcp_kv_setup` file to include
the data for your GCP credentials.
Then you must execute that workflow to add that data to the KVStore for that
namespace.

Once the credentials are in place, the next step is to create the required
resources in GCP. You can do that running the `gcp_resources_setup` flow.
Once you are finished, you can remove the provisioned resources by running
the `gcp_resources_destroy.yaml` flow.
Beware that the resource destruction flow would fail if the bucket is not
empty.
It should not happen with successful flow executions, but chances are that
some failed flow leaves some trace behind.
In that case, you will have to log into GCP and remove the bucket manually
if you don't want to be charged for it.

Finally, the main flow, the one that gets the NY taxi data and upload it
to the cloud for further processing, is composed by two flows:

  - `process_month` get two input parameters, the taxi color and the
    year-month to be imported into GCP and performs the work. It has been
    simplified (no need to decompress the file prior to upload to GCP) and
    parallelized where it made sense. The flow management have also been
    changed to traditional conditionals instead of the linear approach where
    some tasks are skipped.
  - `taxi_data_loader` is triggered at the beginning of each month to import
    new data for both taxi colors. It calls the previous subworkflow twice
    (once for each taxi type) and runs the imports in parallel.

You can see how it works by running the `taxi_data_loader` to backfill some
data.
Go to the triggers tab and start the backfill for any period between 2019-01
and 2021-07 (included).