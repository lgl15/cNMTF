% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/fact_cons.R
\name{consensus.clust}
\alias{consensus.clust}
\title{Find consensus clustering and SNV score}
\usage{
consensus.clust(R, Wv, Wu = NULL, DWD = NULL, HLH, Vo, k, lparameters,
  iters, labelsU, labelsV, run.t, calcObj, calcObj2, init, parallel.opt,
  n.cores = NULL, set.alg = NULL, set.clus.V = NULL, export.res = TRUE,
  V.init = NULL, U.init = NULL, do.U = TRUE, do.V = TRUE, do.O = TRUE,
  find.parameters = FALSE, estimate.penalisation = FALSE,
  display.iters = FALSE)
}
\arguments{
\item{R}{Relationship matrix}

\item{Wv}{Prior knowledge networks for SNVs}

\item{HLH}{Matrices to correct for confounders}

\item{k}{Number of clusters}

\item{lparameters}{Penalization parameters}

\item{iters}{Number of iterations}

\item{labelsU}{Labels of SNVs}

\item{labelsV}{Labels of Patients}

\item{run.t}{Number of repetitions}

\item{calcObj}{Number of iterations to check convergency}

\item{calcObj2}{Number of iterations to check convergency after \code{calcObj} iterations}

\item{parallel.opt}{Run the algorithm in parallel}

\item{n.cores}{Number of cores to use in the parallel processing}

\item{set.alg}{Set of algorithm results can be provided to find consensus results}

\item{set.clus.V}{Set of clustering of patients provided to find consensus results}

\item{export.res}{Whether the object with list of results is returned}

\item{V.init}{Initialisation of V using PSVD}

\item{U.init}{Initialisation of U using PSVD}

\item{do.U}{Logical. Perform consensus clustering on U matrix}

\item{do.V}{Logical. Perform consensus clustering on V matrix}

\item{do.O}{Logical. Perform consensus clustering on Omega matrix}

\item{find.parameters}{Logical. Run the NMTF algorithm to find estimations of parameters}

\item{estimate.penalisation}{Logical. Return the penalisation terms evaluated in the last iteration.}

\item{display.iters}{Logical. Display the iterations of function cnmtf}

\item{ini}{Type of seeding/initialisation of matrices in the algorithm}
}
\value{
\itemize{
\item \code{rho} List of dispersion coefficients for the avg. consensus matrices of U and V
\item \code{clus.U, clus.V} Clustering memberships
\item \code{Os} Consensus SNV score
\item \code{lniters, lJ, lrelErr} Variables to follow-up the algorithm performance
\item \code{res.alg} Object with all the matrices at each repetition. Only IF parallel.opt = FALSE
\item \code{max.parameters} sObject with the penalisation terms estimated in the last iteration of each repetition.
\item \code{lparameters}  If \code{find.parameters = TRUE} this function only returns a list of estimations for the parameters
}
}
\description{
Function for running the cNMTF algorithm a number of times and extract consensus results
}
\seealso{
Other Factorisation functions: \code{\link{clus.membership}},
  \code{\link{cnmtf}}, \code{\link{hierarchical.clust}},
  \code{\link{initialise.UV}}, \code{\link{neg.constrain}},
  \code{\link{parameters.cnmtf}},
  \code{\link{plot.parameter}},
  \code{\link{pos.constrain}}, \code{\link{psvd.init}},
  \code{\link{regression.snps}}, \code{\link{score.cnmtf}},
  \code{\link{synthetic.gwas}}
}
\author{
Luis G. Leal, \email{lgl15@imperial.ac.uk}
}
