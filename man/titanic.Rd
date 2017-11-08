\name{titanic}
\alias{titanic}
\docType{data}




%- Also NEED an '\alias' for EACH other topic documented here.
\title{Titanic Data}

\description{
Data describes the survival status of individual passengers on the British
 luxury passenger liner Titanic that sank when it struck an iceberg on April 1912, on its maiden voyage to 
 New York City from Southampton, England (Weisberg, 2003). Information were 
 obtained from Encyclopedia Titanica. The variables on the dataset called 
 titanic3 were made available by Harrell Jr (2001) and contains pclass, sex, 
 embarked and survival status for each person on the board of the Titanic. 
 pclass refers to passenger class (1st, 2nd, 3rd), and is a proxy for socio-economic class.
  embarked indicates the place where the passenger embarked on the ship.
   The variables pclass and embarked were recoded in the present version of the dataset.
  These data were used to compute prevalence ratios and corresponding confidence intervals.
  }

\usage{
data(titanic)
}


%- maybe also 'usage' for other objects documented here.
\format{
A data frame with 1307 observations on the following 4 variables:
\describe{
\item{pclass}{The passenger class (1st, 2nd, 3rd) in the ship. 
Recoded to 1=1st class and 0=2nd or 3rd classes.}
\item{survived}{The survival status of the passenger (1=yes, 0=no).}
\item{sex}{Sex of the passenger (1=female, 0=male).}
\item{embarked}{The place where the passenger embarked for the trip 
(Q=Queenstown, S=Southampton, C=Cherbourg). Recoded to 1=Queenstown or 
Cherbourg and 0=Southampton.}
}
}

\source{
The data were originally obtained from \cr
Dawson, Robert J. MacG. (1995), The Unusual Episode Data Revisited. Journal of
Statistics Education, 3.
http://www.amstat.org/publications/jse/v3n3/datasets.dawson.html
}

\references{
Weisberg, S. (2005) Applied Linear Regression. Third Edition. New Jersey: John-Wiley & Sons.

Frank E. Harrell Jr (2001) Regression Modelling Strategies. New York: Springer-Verlag.
}

\examples{
data("titanic", package = "prLogistic")
attach(titanic)
dim(titanic)
library(Hmisc)
describe(as.factor(pclass))
table(survived,pclass)
glm(survived ~ as.factor(pclass), family=binomial, data=titanic)
}





\keyword{datasets}





