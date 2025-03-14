% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/adg_get.R
\name{adg_get}
\alias{adg_get}
\title{Comprehensive Average Daily Gain (ADG) Calculation Pipeline}
\usage{
adg_get(
  data,
  my_break,
  range_offset = 0.5,
  min_days = 35,
  min_records = 20,
  min_na_perc = 0.3,
  w_threshold = 0.5,
  maxit = 1000,
  entry_weight_limit = 65,
  exit_weight_limit = 85,
  max_weight_limit = 15,
  days_extend = 30,
  step = 1,
  degree = 2,
  print_details = FALSE,
  quiet = FALSE
)
}
\arguments{
\item{data}{Input \code{data.table} containing processed pig weight records
\itemize{
\item \strong{Must contain columns}:
\itemize{
\item \code{responder} (unique identifier)
\item \code{location} (measurement location)
\item \code{date} (date of measurement)
\item \code{seq_days} (sequence days)
\item \code{seq_in_location} (sequence in location)
\item \code{seq_in_day} (sequence in day)
\item \code{weight} (weight measurements in grams)
}
\item \strong{Requires output} from \code{preprocess_data()}
\item Supports parallel processing via data.table optimizations
}}

\item{my_break}{Target weight range specification
\itemize{
\item \strong{Format}: Numeric vector of length 2 \verb{[lower, upper]}
\item \strong{Units}: Kilograms (kg)
\item \strong{Constraint}: \code{my_break[1] < my_break[2]}
\item \strong{Example}: \code{c(30, 120)} for 30-120kg range
}}

\item{range_offset}{Weight range extension buffer
\itemize{
\item \strong{Purpose}: Extends target range for boundary cases
\item \strong{Units}: Kilograms (kg)
\item \strong{Default}: \code{0.5}
\item \strong{Constraint}: Must be positive value
}}

\item{min_days}{Minimum observation period requirement
\itemize{
\item \strong{Purpose}: Filters short-term measurements
\item \strong{Units}: Days
\item \strong{Default}: \code{35}
}}

\item{min_records}{Minimum data points per responder
\itemize{
\item \strong{Purpose}: Ensures sufficient data density
\item \strong{Default}: \code{20}
}}

\item{min_na_perc}{Maximum allowable missing data ratio
\itemize{
\item \strong{Purpose}: Controls data completeness
\item \strong{Format}: Proportion between 0-1
\item \strong{Default}: \code{0.3} (30\% maximum NA)
}}

\item{w_threshold}{Robust regression outlier cutoff
\itemize{
\item \strong{Purpose}: Identifies statistical outliers
\item \strong{Default}: \code{0.5}
\item \strong{Technical}: Weight threshold for MASS::rlm weights
\item \strong{Constraint}: Typically 0.5-1.0
}}

\item{maxit}{Maximum iterations for robust regression
\itemize{
\item \strong{Purpose}: Controls model convergence
\item \strong{Default}: \code{1000}
}}

\item{entry_weight_limit}{Maximum allowable entry weight
\itemize{
\item \strong{Purpose}: Filters over-conditioned starters
\item \strong{Units}: Kilograms (kg)
\item \strong{Default}: \code{65}
\item \strong{Constraint}: Must be < exit_weight_limit
}}

\item{exit_weight_limit}{Minimum required exit weight
\itemize{
\item \strong{Purpose}: Ensures market readiness
\item \strong{Units}: Kilograms (kg)
\item \strong{Default}: \code{85}
\item \strong{Constraint}: Must be > entry_weight_limit
}}

\item{max_weight_limit}{Physiological weight ceiling
\itemize{
\item \strong{Purpose}: Removes biologically implausible values
\item \strong{Units}: Kilograms (kg)
\item \strong{Default}: \code{150}
\item \strong{Constraint}: Should exceed exit_weight_limit
}}

\item{days_extend}{Prediction window extension
\itemize{
\item \strong{Purpose}: Forecast period for growth modeling
\item \strong{Units}: Days
\item \strong{Default}: \code{30}
\item \strong{Constraint}: Must be >= 0
}}

\item{step}{Prediction interval granularity
\itemize{
\item \strong{Purpose}: Controls forecast resolution
\item \strong{Units}: Days
\item \strong{Default}: \code{1}
}}

\item{degree}{Polynomial regression complexity
\itemize{
\item \strong{Purpose}: Determines growth curve flexibility
\item \strong{Default}: \code{2} (quadratic)
\item \strong{Constraint}: 1 <= degree <= 3
}}

\item{print_details}{Diagnostic output control
\itemize{
\item \strong{Purpose}: Enables detailed process reporting
\item \strong{Default}: \code{FALSE}
\item \strong{Note}: Overridden by \code{quiet = TRUE}
}}

\item{quiet}{Logical. If TRUE, suppresses messages and warnings. Default: FALSE.}
}
\value{
Enhanced \code{list} containing:
\itemize{
\item \code{adg_info}:
\itemize{
\item Aggregated growth metrics data.table
\item Contains columns:
\itemize{
\item \code{responder}, \code{location}, \code{stage}
\item \code{start_date_cut}, \code{end_date_cut}
\item \code{min_weight_cut}, \code{max_weight_cut}
\item \code{lm_slope}, \code{r_squared}
\item \code{stage_days}, \code{adg}
}
}
\item \code{adg_data}:
\itemize{
\item Detailed prediction results data.table
\item Contains columns:
\itemize{
\item All columns from \code{cleaned_data}
\item \code{predicted_weight_lm}, \code{lower_lm}, \code{upper_lm}
\item \code{outlier} (prediction status flag)
}
}
}
}
\description{
Integrated system for calculating porcine average daily gain (ADG) through
cleaned weight data, incorporating growth curve modeling and prediction
capabilities. Inherits and extends the functionality of \code{\link[=clean_weight_get]{clean_weight_get()}}.
}
\details{
\strong{Extended Processing Workflow}:
\enumerate{
\item \strong{Data Preparation}:
\itemize{
\item Inherits all cleaning steps from \code{\link[=clean_weight_get]{clean_weight_get()}}
\item Additional outlier handling specific to growth modeling
}

\item \strong{Growth Modeling}:
\itemize{
\item Polynomial regression fitting (degree configurable)
\item Weight trajectory prediction with confidence intervals
\item Dynamic range extension for forward/backward prediction
}

\item \strong{ADG Calculation}:
\itemize{
\item Stage-specific growth rate computation
\item Weight-to-time conversion modeling
\item Prediction range optimization
}
}

\strong{Modeling Features}:
\itemize{
\item Dual prediction modes (linear/polynomial)
\item Automatic outlier boundary detection
\item Confidence interval calculation for predictions
\item Multi-stage growth curve analysis
}
}
\examples{
result_nedap <- preprocess_data(data = mintyr::nedap, station_type = "nedap", quiet = TRUE)
adg_result <- adg_get(result_nedap, my_break = c(30,120), quiet = TRUE)
head(adg_result$adg_info)
head(adg_result$adg_data)
}
\seealso{
\itemize{
\item \code{\link[=clean_weight_get]{clean_weight_get()}} For core data cleaning functionality
\item \code{\link[=preprocess_data]{preprocess_data()}} For input data preparation
}
}
