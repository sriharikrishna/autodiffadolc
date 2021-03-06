% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/adolc_constructor.R
\name{adolc_createList}
\alias{adolc_createList}
\title{Constructor to create a list of adoubles}
\usage{
rm(list=ls())

library(radolc)

adolc_createList(count, val)

#Always detach the package
detach(package:radolc, unload=TRUE) 
}
\arguments{
\item{count}{number of elements of the list}

\item{val}{value to be initialize elements of the list}
}
\value{
None
}
\description{
\code{adolc_createList} creates a list of adoubles of
length count. Each element is initialized to a provided value.
}
\examples{
x <- adolc_createList(2,0.0)

}
\seealso{
{\code{\link{trace_off}}, \code{\link{badouble_declareIndependent}}, 
        \code{\link{badouble_declareDependent}}}
}
\keyword{{autodiffadolc}}
