\name{UIS}
\alias{UIS}
\docType{data}




%- Also NEED an '\alias' for EACH other topic documented here.

\title{UIS - The UMARU IMPACT Study - Data}

\description{
Data were from randomized trials related to treatment for drug abuse obtained 
by the University of Massachusetts Aids Research Unit (UMARU) IMPACT Study (UIS). 
The main goal of the study was to compare treatment programs of different 
durations in the reduction of drug abuse and in the prevention of high-risk HIV  
behavior (Hosmer and Lemeshow, 2000). The variables on the dataset included here 
are age at enrollment, drug use history at admission,  race, treatment group, 
treatment site, and patient's status at the end of the treatment program 
(remained drug free or otherwise). These data are  copyrighted by 
John Wiley & Sons Inc. and are used here to illustrate the calculation of 
prevalence ratios and corresponding confidence intervals. }

\usage{
data(UIS)
}


%- maybe also 'usage' for other objects documented here. 
\format{ A data frame with 575 observations on the following 7 
variables:
 \describe{ 
 \item{ID}{Identification code.} 
\item{Age}{Age at enrollment (in years) recoded to 1= 32 years 
or younger, 0= more than 32 years-old.} 
 \item{DrugUse}{Drug use history at admission (1=never, 2=previous, 3=recent). 
Recoded to 1= never and 0= previous or recent.} 
\item{race}{Subject's race (0=white, 1=other).} 
\item{trt}{Treatment group (0=short, 1=long).} 
\item{site}{Treatment site (0=A, 1=B).} 
\item{drugFree}{Returned to drug use prior to the scheduled 
end of the treatment program (1=remained drug free, 
0=otherwise).} } 
 } 

\source{
The data come from \cr
Hosmer and Lemeshow (2000) Applied Logistic Regression. 2nd Edition, New York: John-Wiley & Sons. \cr
These data are copyrighted by John Wiley & Sons Inc. \cr
We acknowledged it and use the data to illustrate the methodology included in this library.
}

\references{
Weisberg, S. (2005) Applied Linear Regression. Wiley-Interscience.
}


\examples{
data("UIS", package = "prLogistic")
 attach(UIS) 
 tmp=table(drugFree,trt)   
 options(digits=2)             
 prop.table(tmp,2)             
}





\keyword{datasets}



