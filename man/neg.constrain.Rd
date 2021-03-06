% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/fact_init.R
\name{neg.constrain}
\alias{neg.constrain}
\title{Constraining positive entries in a matrix}
\usage{
neg.constrain(A)
}
\arguments{
\item{A}{Nonnegative matrix A, \emph{n x n}}
}
\value{
\code{A} Constrained nonnegative A matrix, \emph{n x n}
}
\description{
This function sets to zero the positive elements of a matrix and takes the absolute value of the negative elements.
}
\references{
C. Boutsidis and E. Gallopoulos, SVD-based initialization: A head start for nonnegative matrix factorization, Pattern Recognition, Elsevier
}
\seealso{
Other Factorisation functions: \code{\link{clus.membership}},
  \code{\link{cnmtf}}, \code{\link{consensus.clust}},
  \code{\link{hierarchical.clust}},
  \code{\link{initialise.UV}},
  \code{\link{parameters.cnmtf}},
  \code{\link{plot.parameter}},
  \code{\link{pos.constrain}}, \code{\link{psvd.init}},
  \code{\link{regression.snps}}, \code{\link{score.cnmtf}},
  \code{\link{synthetic.gwas}}
}
\author{
Luis G. Leal, \email{lgl15@imperial.ac.uk}
}
