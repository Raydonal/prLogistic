\name{prLogisticDelta}
\alias{prLogisticDelta}


%- Also NEED an '\alias' for EACH other topic documented here.
\title{Estimation of Prevalence Ratios using Logistic Models and Confidence 
Intervals with Delta Method}

\description{
This function estimates prevalence ratios (PRs) and their confidence 
intervals using logistic models.
The estimation of standard errors for PRs is obtained through use of delta method.
Confidence intervals of (1-alpha)\% for PRs are available for standard logistic regression
and for  random-effects logistic models (Santos et al, 2008). The function 
\code{prLogisticDelta} allows estimation of PRs using two
standardization procedures: conditional or marginal (Wilcosky and Chambless, 1985).

\code{glm}, \code{glmer}, \code{prLogisticBootCond}, \code{prLogisticBootMarg} 
}

\usage{
prLogisticDelta(formula, cluster = FALSE, 
		pattern = c("conditional", "marginal"), 
		conf = 0.95, dataset, ...)
}


%- maybe also 'usage' for other objects documented here.
\arguments{
\item{formula}{a symbolic description of the model to be fitted. The details of model 
    specification are given below.}
\item{cluster}{logical argument specifying data clustering. The default is 
    cluster=FALSE. If data is clustered or longitudinal, it
should be set to cluster=TRUE.}
\item{pattern}{the standardization procedure. If \code{pattern} is missing then conditional
    standardization is used. The standardization is set to be the marginal if pattern="marginal".}
\item{conf}{scalar or vector specifying confidence level(s) for estimation. The default is 
    conf = 0.95.}
\item{dataset}{a required data frame containing the variables named in \code{formula}}
\item{\dots}{optional additional arguments. Currently none are used in any methods.}
}

\details{
A typical form used with \code{glm()} function is included in the formula argument as response 
~ terms where response is the (binary) response vector and terms is a series of terms which 
specifies a linear predictor for response. The \code{prLogisticDelta} assumes a binomial 
family associated to the model. The \code{glmer()} function is used when a vertical bar character "|" 
separates an expression for a model matrix and a grouping factor. Currently only binary predictors are allowed. If categorization for predictors 
is other than (0,1), \code{factor()} should be considered.
}

\value{
Returns prevalence ratio and its 95\% confidence intervals.
}


\author{Raydonal Ospina, Department of Statistics, Federal University of Pernambuco, Brazil \cr (raydonal@de.ufpe.br) \cr 
Leila D. Amorim, Department of Statistics, Federal University of Bahia, Brazil \cr (leiladen@ufba.br).
}

\references{
Localio AR, Margolis DJ, Berlin JA (2007). Relative risks and confidence intervals were easily 
computed indirectly from
multivariate logistic regression. \emph{Journal of Clinical Epidemiology},
\bold{60}, 874-882.

Oliveira NF, Santana VS, Lopes AA (1997). Ratio of proportions and the use of the delta method 
for confidence interval estimation
in logistic regression. \emph{Journal of Public Health}, \bold{31}(1), 90-99.

Santos CAST et al (2008).
Estimating adjusted prevalence ratio in clustered cross-sectional epidemiological data.
\emph{BMC Medical Research Methodology}, \bold{8} (80). Available from \cr 
http://www.biomedcentral.com/1471-2280/8/80.

Wilcosky TC, Chambless LE (1985). A comparison of direct adjustment and regression adjustment 
of epidemiologic measures. \emph{Journal of Chronic Diseases}, \bold{34}, 849-856.
}

%\note{
%This work is part of .... }

\seealso{ \code{\link{glm}}, \code{\link{glmer}}, 
 \code{\link{prLogisticBootCond}},\code{\link{prLogisticBootMarg}}}

\examples{
### For independent observations:
# Estimates from logistic regression with conditional standardization - 
# delta method
# Not run:
# data("titanic", package = "prLogistic")
# attach(titanic)
# prLogisticDelta(survived~ sex + pclass + embarked, data = titanic)
# End (Not run:)

# Estimates from logistic regression with marginal standardization - 
# delta method
 prLogisticDelta(survived~ sex + pclass + embarked, 
 data = titanic, pattern="marginal")


### For clustered data
# Estimates from random-effects logistic regression with conditional 
# standardization - delta method
# Not run:
# data("Thailand", package = "prLogistic")
# prLogisticDelta(rgi~  sex + pped + (1|schoolid), 
# data = Thailand, cluster=TRUE)
# End (Not run:)

# Estimates from random-effects logistic regression with marginal 
# Not run:
# standardization -  delta method
# prLogisticDelta(rgi ~  sex + pped + (1|schoolid), data = Thailand,
# pattern="marginal", cluster=TRUE)
# End (Not run:)
}

\keyword{distribution}
\keyword{regression}




