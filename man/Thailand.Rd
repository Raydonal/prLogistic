\name{Thailand}
\alias{Thailand}
\docType{data}



%- Also NEED an '\alias' for EACH other topic documented here.
\title{Thailand Data}

\description{
Data are from a national survey of primary education in Thailand, including information for 8,582 sixth graders nested within 411 schools
(Raudenbush & Bhumirat, 1992). The outcome binary variable "rgi" indicates whether a pupil has repeated a grade during primary
 education (0=no, 1=yes). The predictor variables are: child's sex (0=male, 1=female) and child's pre-primary education (0=no, 1=yes). 
 Every level-1 record corresponds to a student.}

\usage{
data(Thailand)
}


%- maybe also 'usage' for other objects documented here.
\format{
A data frame with 8,582 observations on the following 4 variables:
\describe{
\item{schoolid}{School identification.}
\item{sex}{Child's sex (0 if boy, 0 if girl).}
\item{pped}{Pre-primary education indicator (1=yes, 0=no).}
\item{rgi}{Repeated grade indicator (1=yes, 0=no).}
}
}

\source{
The data come from \cr
Raudenbush, S, Bhumirat C. (1992) The distribution of resources for primary education and its consequences
for educational achievement in Thailand. \emph{International Journal of Educational Research}, 17, 143-164.
 }

\references{
Raudenbush et al (2000) HLM 5. Hierarquical Linear and Nonlinear Modeling. Chicago: Scientific Software International.

Hox J (2002). Multilevel Analysis. Techniques and Applications. Mahwah, NJ: Lawrence Erlbaum Associates
}


\examples{
data("Thailand", package = "prLogistic")
attach(Thailand)
summary(Thailand)
}

\keyword{datasets}





