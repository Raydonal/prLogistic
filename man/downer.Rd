\name{downer}
\alias{downer}
\docType{data}



\title{Downer Data}

\description{
Data are related to dairy cows with a serious illness that may lead them to death.
 The dairy cows are also called downers because they sometimes lay down. A study was 
 conducted with over 400 downer cows at the Ruakura New
Zealand Animal Health Laboratory during 1983-1984. In this study a variety
 of blood tests were performed.  The main goal of the study was to evaluate 
 if the survival of the cows can be predicted from the blood measurements. For the illustration 
 considered here, we use a subset of the original dataset. The variables on this dataset are serum asparate amino transferase, calving,
   serum creatine phosphokinase, Myopathy and Survival. These data are originally from Clark, Henderson, Hoggard, Ellison,
      and Young (1987). There were missing for some variables. We consider here only the complete cases.}

\usage{
data(downer)
}

\format{
A data frame with 216 observations on the following 5 variables:
\describe{
\item{AST}{Serum asparate amino transferase, in U/l at 30C, recoded to 1 if equal or less than 492, 0= greater than 492.}
\item{CK}{Serum creatine phosphokinase, in U/l at 30C, recoded to 1 if equal or less than 5467, 0= greater than 5467.}
\item{Calving}{Calving (0 if measured before calving, 1 if after).}
\item{Myopathy}{Muscle disorder indicator (1=yes, 0=no).}
\item{Survival}{Survival indicator (1=survived, 0=died or killed).}
}
}

\source{
The data come from \cr
Weisberg, S. (2005) Applied Linear Regression. Wiley-Interscience.
 
 These data are copyrighted by John Wiley & Sons Inc. 
 We acknowledged it and use the data to illustrate the methodology included in this library.
}

\references{
Clark R, Henderson HV, Hoggard GK, Ellison R and Young B (1987) The ability of biochemical
and haematological tests to predict recovery in periparturient recumbent cows.
New Zealand Vet. Journal, 32, 126-133
}



\examples{
data("downer", package = "prLogistic")
attach(downer)
# prop.table(table(Survival))
fit.logist1=glm(Survival ~ Calving + CK + AST + Myopathy, 
family=binomial, data=downer)
# summary(fit.logist1)
exp(fit.logist1$coef)
}

\keyword{datasets}





