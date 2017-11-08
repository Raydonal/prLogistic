\name{prLogisticBootMarg}
\alias{prLogisticBootMarg}




%- Also NEED an '\alias' for EACH other topic documented here.
\title{Estimation of Prevalence Ratios using Logistic Models and Bootstrap Confidence
 Intervals for Marginal Standardization}

\description{
This function estimates prevalence ratios (PRs) 
and bootstrap confidence intervals using logistic models for marginal standardization.
The estimation of standard errors for PRs is obtained through use of bootstrapping.
Confidence intervals of (1-alpha)\% for PRs are available for standard logistic regression
and for  random-effects logistic models (Santos et al, 2008). The function 
\code{prLogisticBootMarg} allows estimation of PRs using marginal standardization procedure 
(Wilcosky and Chambless, 1985). 

%\code{glm}, \code{lmer}, \code{prLogisticDelta}, \code{prLogisticBootCond} 
}

\usage{
prLogisticBootMarg(object, data, conf = 0.95, R = 99, ...)
}


%- maybe also 'usage' for other objects documented here.
\arguments{
\item{object}{any fitted model object from which fixed effects estimates can be 
extracted. The details of model specification are given below.}
\item{data}{a required data frame containing the variables named in \code{object}.}
\item{conf}{scalar or vector specifying confidence level(s) for estimation. The default is 
    \code{conf}= 0.95.}
\item{R}{the number of bootstrap replicates. The default is \code{R}=99.}
\item{\dots}{optional additional arguments. Currently none are used in any methods.}
}

\details{
The fitted model object can be obtained using \code{glm()} function for binary responses
 when unit samples are independent. The \code{glmer()} function should be used
 for correlated binary responses. Only binary predictors are allowed. If categorization for predictors 
is other than (0,1), \code{factor()} should be considered.
}

\value{
Returns prevalence ratio and its 95\% bootstrap confidence intervals for marginal
standardization. Both normal and percentile bootstrap confidence intervals are presented.}


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
of
epidemiologic measures. \emph{Journal of Chronic Diseases}, \bold{34}, 849-856.
}

%\note{
%This work is part of .... }

\seealso{ \code{\link{glm}}, \code{\link{glmer}}, 
 \code{\link{prLogisticDelta}},\code{\link{prLogisticBootCond}}}

\examples{
### For independent observations:
## Estimates from logistic regression with bootstrap confidence intervals -
## marginal standardization
# Not run:
# data("titanic", package = "prLogistic")
# attach(titanic)
# fit.logistic=glm(survived~ sex + pclass + embarked, family=binomial, 
# data = titanic)
# prLogisticBootMarg(fit.logistic, data = titanic)
# End (Not run:)

# Another way for fitting the same model:
# Not run:
# prLogisticBootMarg(glm(survived~ sex + pclass + embarked, 
# family=binomial, data = titanic), data=titanic)
# End (Not run:)
 
### For clustered data
# Estimates from random-effects logistic regression 
## with bootstrap confidence intervals - marginal standardization
# Not run:
# library(lme4)
# data("Thailand", package = "prLogistic")
# attach(Thailand)
# ML = glmer(rgi ~  sex + pped  + (1|schoolid), 
# family = binomial, data = Thailand)
 			
# prLogisticBootMarg(ML, data = Thailand)
# End (Not run:)
}

\keyword{distribution}
\keyword{regression}




