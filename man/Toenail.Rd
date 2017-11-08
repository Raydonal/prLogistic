\name{Toenail}
\alias{Toenail}
\docType{data}




%- Also NEED an '\alias' for EACH other topic documented here.
\title{Toenail Data}

\description{
Data are from a multicenter study comparing two oral treatments for toe-nail infection, including information 
for 294 patients measured at 7 weeks, comprising a total of  1908 measurements. The outcome binary variable "onycholysis" indicates
the degree of separation of the nail plate from the nail-bed (none or mild versus moderate or severe). Patients were evaluated at baseline 
(week 0) and at weeks 4, 8, 12, 24, 36, and 48 thereafter.}

\usage{
data(Toenail)
}


%- maybe also 'usage' for other objects documented here.
\format{
A data frame with 1,908 observations on the following 5 variables:
\describe{
\item{ID}{Subject's identification.}
\item{Response}{Degree of onycholysis (0 if none or mild, 1 if moderate or severe).}
\item{Treatment}{Oral treatment indicator (1=Treatment A, 0= Treatment B).}
\item{Month}{Exact timing of measurements, in months.}
\item{Visit}{Visit number (visit numbers
1-7 correspond to scheduled visits at 0, 4, 8, 12, 24, 36, and
48 weeks).}
}
}

\source{
The data come from \cr
Data courtesy of Novoartis, Belgium
(http://www.blackwellpublishing.com/rss/datasets/C4827r.txt)
 }


\references{
De Backer, M., De Vroey, C., Lesaffre, E., Scheys, I., and De Keyser, P. (1998).
Twelve weeks of continuous oral therapy for toenail onychomycosis caused by dermatophytes: 
A double-blind comparative trial of terbinafine 250 mg/day versus itraconazole 200 mg/day.
Journal of the American Academy of Dermatology, 38, 57-63.

Lesaffre, E. and Spiessens, B. (2001). On the effect of the number of quadrature 
points in a logistic random-effects model: An example. Journal of the Royal Statistical 
Society, Series C, 50, 325-335.

Rabe-Hesketh S, Skrondal A (2008). Multilevel and Longitudinal Modeling Using Stata. Mahwah, NJ: Lawrence Erlbaum Associates. Second Edition.}


\examples{
data("Toenail", package = "prLogistic")
attach(Toenail)
summary(Toenail)
}

\keyword{datasets}





