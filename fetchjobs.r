# Set path
setwd("~/verification-version")

library(httr)	
require(jsonlite)

magic_verify_token <- Sys.getenv("VERIFYPROCESSTOKEN")

process_one_job <- function(x) {
  model <- x["model"]
  epsilon <- x["epsilon"]
  unit <- x["output_unit"]
  myoutputfile <- paste(x["opaque_id"], 'png', sep = ".")
  myopaqueid <- x["opaque_id"]
  print(paste(myopaqueid,model))
  
  cmd <- paste("export VERIFYMODEL='",model, "'; ",
               "export VERIFYEPSILON='", epsilon, "'; ",
               "export VERIFYUNIT='", unit, "'; ",
               "export VERIFYOUTPUTFILE='", myoutputfile, "'; ",
               "export VERIFYOPAQUEID='", myopaqueid, "'; ",
               "export VERIFYTOKEN='", magic_verify_token, "'; ",
               "R CMD BATCH app.r", sep='')
  print(paste(cmd))
  system(cmd)
}

# fetch the list of jobs that need to be processed and run them
url <- "https://YOUR-SERVER-NAME-HERE/app_install/awaiting_remote_processing"
messy_result <- POST(url, encode="multipart",  accept_json(), content_type_json(),
                     query=list(verification_processor_token = magic_verify_token))
cleaned_result <- fromJSON(content(messy_result, "text"))

# element[1] is the status of the REST web service request and should be 'OK'
stopifnot (cleaned_result[1][[1]] == "OK") # bail out now
jobs_to_run <- cleaned_result[2][[1]]
stopifnot (nrow(jobs_to_run) > 0 ) # nothing to process
by(jobs_to_run,1:nrow(jobs_to_run), process_one_job)

