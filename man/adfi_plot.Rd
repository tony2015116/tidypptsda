% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/adfi_plot.R
\name{adfi_plot}
\alias{adfi_plot}
\title{Plot Average Daily Feed Intake (ADFI) Curves}
\usage{
adfi_plot(
  data,
  responders = NULL,
  locations = NULL,
  color_theme = "d3",
  save_path = NULL,
  file_prefix = "loc",
  file_suffix = NULL,
  dpi = 300,
  device = "png",
  quiet = FALSE
)
}
\arguments{
\item{data}{A list object returned by the \code{adfi_get()} function, containing ADFI data and related information.}

\item{responders}{Character vector specifying which pig IDs to include. Default is \code{NULL} (all responders).}

\item{locations}{Character vector specifying which locations to include. Default is \code{NULL} (all locations).}

\item{color_theme}{Character string specifying the color theme to use from the \code{ggsci} package.
Default is "d3". Available themes include: "npg", "aaas", "nejm", "lancet", "jama", "bjm", "jco",
"d3", "observable", "locuszoom", "igv", "cosmic", "uchicago", "startrek", "tron", "futurama",
"rickandmorty", "simpsons", "flatui", "frontiers", "ucscgb".}

\item{save_path}{Character string specifying the path to save plots. Default is \code{NULL} (plots not saved).}

\item{file_prefix}{Character string for the prefix of saved filenames. Default is "loc".}

\item{file_suffix}{Character string for the suffix of saved filenames. Default is \code{NULL} (automatically set to "grow").}

\item{dpi}{Numeric value for the resolution of saved plots. Default is 300.}

\item{device}{Character string specifying the file format for saved plots. Default is "png".
Supported formats: "png", "pdf", "jpeg", "tiff".}

\item{quiet}{Logical. If TRUE, suppresses messages and warnings. Default: FALSE.}
}
\value{
A \code{data.table} containing:
\itemize{
\item \code{location}: Location identifier
\item \code{data}: List of data for each location
\item \code{plot}: List of ggplot2 objects for each location
}
}
\description{
Creates and optionally saves visualization plots for pig feed intake data based on ADFI (Average Daily Feed Intake)
calculations. The function generates detailed feed intake curve plots with original and corrected values,
smoothing lines, and state indicators.
}
\details{
The plots created by \code{adfi_plot} include:
\itemize{
\item Original daily feed intake values (gray points)
\item Corrected daily feed intake values (colored by state)
\item LOESS smoothing line for corrected values
\item Horizontal reference lines showing average corrected ADFI
\item Text annotations showing original and corrected ADFI values
}
}
\examples{
result_nedap <- preprocess_data(data = mintyr::nedap, station_type = "nedap", quiet = TRUE)
adg_result <- adg_get(result_nedap, my_break = c(30,120), quiet = TRUE)
adfi_result <- adfi_get(result_nedap, adg_result, quiet = TRUE)
res <- adfi_plot(data = adfi_result, save_path = tempdir(), location = "101", quiet = TRUE)
# Check exported files
list.files(path = tempdir(), pattern = "png", recursive = TRUE)
# Clean up exported files
files <- list.files(
  path = tempdir(),         # Default export directory
  pattern = "png",          # File type pattern to search
  recursive = TRUE,         # Search in subdirectories
  full.names = TRUE         # Return full file paths
)
file.remove(files)          # Remove all exported files
}
\seealso{
\code{\link{adfi_get}} for calculating ADFI data
\code{\link{adg_plot}} for plotting Average Daily Gain data
}
