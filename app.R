# Set path
setwd("~/verification-version")

# load the package
library(VerificationMeasures)


# load original and synthetic data
load("/home/guest/verification-version/cpsOriginal.RData")
load("/synthetic-data/cpsSynthetic.RData")

model <- Sys.getenv("VERIFYMODEL")
epsilon <- as.numeric(Sys.getenv("VERIFYEPSILON"))
unit <- as.numeric(Sys.getenv("VERIFYUNIT"))
myoutputfile <- Sys.getenv("VERIFYOUTPUTFILE")
myopaqueid <- Sys.getenv("VERIFYOPAQUEID")

#model <- 'income~age + I(age^2) + educ + marital + sex'
#epsilon <- 1.0
#unit <- 1.0

# fit the model to the synthetic data
reg = lm( model, data = cpsSynthetic)

# Get predictions and residuals for the original data
y.hat <- predict(object=reg,newdata = cpsOriginal)
residuals <- cpsOriginal$income-y.hat


# Creating the output: private residual plot
D <- cbind(y.hat, residuals)
nplots = PriRP(D, epsilon, unit)

# write it to the output file
png(myoutputfile, width = 1024, height = 768)
plot(nplots,pch="+",ylab="residuals", xlab="predicted values")
dev.off()

