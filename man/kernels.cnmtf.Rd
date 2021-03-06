% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/prep_pop.R
\name{kernels.cnmtf}
\alias{kernels.cnmtf}
\title{Calculates the kernel similarity matrix}
\usage{
kernels.cnmtf(R, pop = c("unknown", "known"))
}
\arguments{
\item{R}{Data matrix of size \link{n x m}}

\item{pop}{Population origin. \code{c("unknown", "known")}}
}
\value{
Kernel matrices:
\itemize{
\item \code{H} Centering matrix of size \link{m x m}
\item \code{L} Side information kernel matrix (i.e. Kernel on the confounder random variable) \link{m x m}
}
}
\description{
Function to construct kernel matrices of ancestry/population origin
}
\references{
Li, Rakitisch, et al. "ccSVM: correcting SVMs for confounding factors in biological data classification" ISMB 2011
}
\seealso{
Other Preprocessing functions: \code{\link{coding.scheme}},
  \code{\link{construct.Vo}}, \code{\link{construct.Wu}},
  \code{\link{create.network}},
  \code{\link{degree.distribution}},
  \code{\link{mapply.snpt.synthetic.gwas}},
  \code{\link{rownet.hub}},
  \code{\link{snpt.synthetic.gwas}}
}
\author{
Luis G. Leal, \email{lgl15@imperial.ac.uk}
}
