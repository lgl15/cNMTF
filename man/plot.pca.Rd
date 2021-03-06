% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/prep_pop.R
\name{plot.pca}
\alias{plot.pca}
\title{Plot of PCA for patients}
\usage{
\method{plot}{pca}(res.pca, var.col = NULL, var.name = "Variable", axes.pca,
  show.legend = TRUE, plot.type = c("ggplot", "default"),
  col.manual = NULL, outl = rep(TRUE, length(var.col)))
}
\arguments{
\item{res.pca}{Results of PCA}

\item{var.col}{variable to colour the points (e.g., population)}

\item{axes.pca}{vector of axes to plot}

\item{plot.type}{Using own function or default function}

\item{outl}{Outliers vector to filter out PCA results}
}
\value{
Plot of patients in the principal components space.
}
\description{
Function to plot axes of PCA and depict population structures
}
