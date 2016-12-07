# synthetic-verification

This is a component of the application found here: https://github.com/mccahill/synthetic-data

This is the backend process that is run from cron to fetch regression 
models submitted by users for verification against the real data.

## how does this work?

We assume you are running this on a server with access to the (sensitive) data against which
user-submitted regressions are to be run. Edit your crontab to periodically run the bash shell script
```
     run-fetch-and-process.sh
```

You will need to edit run-fetch-and-process.sh to set the VERIFYPROCESSTOKEN token used by the 
synthetic-data Ruby-on-Rails app to validate the identity of this process. 

The run-fetch-and-process.sh script sets an environment variable with VERIFYPROCESSTOKEN and calls 
and R script
```
     fetchjobs.r
```

You will need to edit the fetchjobs.r script to set the URL so that it points to the server where
your synthetic-data Rails app runs.

After fetching any pending jobs that have been submitted, we call the R script
```
     app.r
```
to process individual jobs and send the results back to the synthetic-data Rails app. Again,
this script needs to know the URL of the server where your synthetic-data Rails app runs, so
you will need to edit this file as well



