% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/HelperFunctions.R, R/SmoothKNN.R
\name{SmoothKNN.Seurat}
\alias{SmoothKNN.Seurat}
\alias{SmoothKNN.SingleCellExperiment}
\alias{SmoothKNN}
\title{Smooth signature scores by kNN}
\usage{
\method{SmoothKNN}{Seurat}(
  obj = NULL,
  signature.names = NULL,
  reduction = "pca",
  k = 10,
  BNPARAM = AnnoyParam(),
  BPPARAM = SerialParam(),
  suffix = "_kNN",
  assay = NULL,
  slot = "data",
  sce.expname = NULL,
  sce.assay = NULL
)

\method{SmoothKNN}{SingleCellExperiment}(
  obj = NULL,
  signature.names = NULL,
  reduction = "PCA",
  k = 10,
  BNPARAM = AnnoyParam(),
  BPPARAM = SerialParam(),
  suffix = "_kNN",
  assay = NULL,
  slot = "data",
  sce.expname = c("UCell", "main"),
  sce.assay = NULL
)

SmoothKNN(
  obj = NULL,
  signature.names = NULL,
  reduction = "pca",
  k = 10,
  BNPARAM = AnnoyParam(),
  BPPARAM = SerialParam(),
  suffix = "_kNN",
  assay = NULL,
  slot = "data",
  sce.expname = c("UCell", "main"),
  sce.assay = NULL
)
}
\arguments{
\item{obj}{Input object - either a \link{SingleCellExperiment} object
or a Seurat object.}

\item{signature.names}{The names of the signatures (or any numeric metadata
column) for which to calculate kNN-smoothed scores}

\item{reduction}{Which dimensionality reduction to use for kNN smoothing.
It must be already present in the input object.}

\item{k}{Number of neighbors for kNN smoothing}

\item{BNPARAM}{A \link{BiocNeighborParam} object specifying the algorithm to use
for kNN calculation.}

\item{BPPARAM}{A \code{\link[BiocParallel:register]{BiocParallel::bpparam()}} object for parallel computing,
e.g. \link{MulticoreParam} or \link{SnowParam}}

\item{suffix}{Suffix to append to metadata columns
for the new knn-smoothed scores}

\item{assay}{For Seurat objects only - do smoothing on expression
data from this assay. When NULL, only looks in metadata}

\item{slot}{For Seurat objects only - do smoothing on expression
data from this slot}

\item{sce.expname}{For sce objects only - which experiment stores the
signatures to be smoothed. Set to 'main' for smoothing gene expression
stored in the main sce experiment.}

\item{sce.assay}{For sce objects only - pull data from this assay}
}
\value{
An augmented \code{obj} with the smoothed signatures. If \code{obj}
is a Seurat object, smoothed signatures are added to metadata; if
\code{obj} is a SingleCellExperiment object, smoothed signatures are
returned in a new altExp. See the examples below.
}
\description{
This function performs smoothing of single-cell scores by weighted
average of the k-nearest neighbors. It can be useful to 'impute' scores by
neighboring cells and partially correct data sparsity. While this function
has been designed to smooth UCell scores, it can be applied to any numerical
metadata contained in SingleCellExperiment or Seurat objects
}
\examples{
#### Using Seurat ####
library(Seurat)
gene.sets <- list(Tcell = c("CD2","CD3E","CD3D"),
                Myeloid = c("SPI1","FCER1G","CSF1R"))
data(sample.matrix)
obj <- Seurat::CreateSeuratObject(sample.matrix)                
# Calculate UCell scores
obj <- AddModuleScore_UCell(obj,features = gene.sets, name=NULL)
# Run PCA
obj <- FindVariableFeatures(obj) |> ScaleData() |> RunPCA()
# Smooth signatures
obj <- SmoothKNN(obj, reduction="pca", signature.names=names(gene.sets))
head(obj[[]])

#### Using SingleCellExperiment ####
library(SingleCellExperiment)
library(scater)
data(sample.matrix)
sce <- SingleCellExperiment(list(counts=sample.matrix))
gene.sets <- list( Tcell = c("CD2","CD3E","CD3D"),
                  Myeloid = c("SPI1","FCER1G","CSF1R"))
# Calculate UCell scores
sce <- ScoreSignatures_UCell(sce, features=gene.sets, name=NULL)
# Run PCA
sce <- logNormCounts(sce)
sce <- runPCA(sce, scale=TRUE, ncomponents=20)
# Smooth signatures
sce <- SmoothKNN(sce, reduction="PCA", signature.names=names(gene.sets))
# See results
altExp(sce, 'UCell')
assays(altExp(sce, 'UCell'))
# Plot on UMAP
sce <- runUMAP(sce, dimred="PCA")
plotUMAP(sce, colour_by = "Tcell_kNN", by_exprs_values = "UCell_kNN")

}
