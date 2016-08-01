#!/bin/bash
#
export VERIFYMODEL="income ~ age + I(age^2) + educ + marital + sex"
export VERIFYEPSILON=0.9
export VERIFYUNIT=1000
export VERIFYOUTPUTFILE='OPAQUE_ID_GOES_HERE.png'
export VERIFYOPAQUEID='OPAQUE_ID_GOES_HERE'
R CMD BATCH app.R