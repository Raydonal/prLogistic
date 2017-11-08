\name{LBW}
\alias{LBW}
\docType{data}


%- Also NEED an '\alias' for EACH other topic documented here.
\title{Low Birth Weight Data}

\description{
Data are from a hypothetical study to evaluate factors associated to low birth weight. This data set contains information 
on 488 births to 188 women seen in an obstetrics clinic, comprising 1 to 3 births for each woman and yielding an average of 2.6 births per women.
The outcome binary variable "low" indicates low birth weight defined as birth weight less than 2500 grams. These data are 
   copyrighted by John Wiley & Sons Inc. and are used here to illustrate the 
   calculation of prevalence ratios and corresponding confidence intervals. }

\usage{
data(LBW)
}


%- maybe also 'usage' for other objects documented here.
\format{
A data frame with 488 observations on the following 6 variables:
\describe{
\item{ID}{Subject's identification.}
\item{birth}{Birth order.}
\item{smoke}{Smoking Status During Pregnancy (1=Yes, 0= No).}
\item{race}{Race (1=White, 0= Others).}
\item{age}{Age of Mother (1= age greater than 35 years, 0= age less or equal to 35 years).}
\item{low}{Low Birth Weight (1 if birth weight less than 2500 grams, 0 if birth weight greater or equal to 2500 grams).}
}
}

\source{
The data come from \cr
Data courtesy of University of Massachusetts Amherst
(http://www.umass.edu/statdata/statdata/stat-logistic.html)

These data are copyrighted by John Wiley & Sons Inc. 
 We acknowledged it and use the data to illustrate the methodology included in this library.
 }


\references{
Hosmer and Lemeshow (2000) Applied Logistic Regression. New York: Wiley Inter-Science. Second Edition.  
}


\examples{
data("LBW", package = "prLogistic")
attach(LBW)
summary(LBW)
}

\keyword{datasets}




