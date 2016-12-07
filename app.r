#
# process a single verification
#
 
# Set path
setwd("~/verification-version")

library(httr)	
require(jsonlite)

library(VerificationMeasures)

# load original and synthetic data
load("/home/guest/verification-version/cpsOriginal.RData")
load("/synthetic-data/cpsSynthetic.RData")

magic_verify_token <- Sys.getenv("VERIFYTOKEN")
model <- Sys.getenv("VERIFYMODEL")
epsilon <- as.numeric(Sys.getenv("VERIFYEPSILON"))
unit <- as.numeric(Sys.getenv("VERIFYUNIT"))
myoutputfile <- Sys.getenv("VERIFYOUTPUTFILE")
myopaqueid <- Sys.getenv("VERIFYOPAQUEID")

# tell the mothership we have started processing
url <- "https://synthetic.oit.duke.edu/app_install/starting_remote_processing"
messy_result <- PUT(url, encode="multipart",  accept_json(), content_type_json(),
                    query=list(verification_processor_token = magic_verify_token,
                               opaque_id = myopaqueid))
cleaned_result <- fromJSON(content(messy_result, "text"))

# was the REST web service call to the mothership OK? 
stopifnot ( (cleaned_result[1][[1]])[1] == "OK") # bail out now

############ run the verification code ############

# fit the model to the synthetic data
reg = lm( model, data = cpsSynthetic)

# Get predictions and residuals for the original data
y.hat <- predict(object=reg,newdata = cpsOriginal)
residuals <- cpsOriginal$income-y.hat

# Creating the output: private residual plot
D <- cbind(y.hat, residuals)
nplots = PriRP(D, epsilon, unit)

# write the output image file
png(myoutputfile, width = 1024, height = 768)
title <- paste("Residuals for original data with epsilon= ", epsilon, ", model: ",model, sep='')
plot(nplots,pch="+",ylab="residuals", xlab=title)
dev.off()

# upload the result to the mothership 
url <- "https://synthetic.oit.duke.edu/app_install/completed_remote_processing"
actualimagefile <- paste(getwd(),myoutputfile, sep = '/')
messy_result <- PUT(url, encode="multipart",  accept_json(), add_headers("charset=utf-8"),
      body = list( verification_processor_token = magic_verify_token, 
             opaque_id = myopaqueid,		 
             verificationfile = upload_file(actualimagefile, type="image/png")))
cleaned_result <- fromJSON(content(messy_result, "text"))

# was the REST web service call to the mothership OK? 
stopifnot ( (cleaned_result[1][[1]])[1] == "OK") # bail out now
move_to_completed= paste("mv ", actualimagefile, " ./completed/")
system(move_to_completed)
