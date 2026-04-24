#' Belgian GP workload data
#'
#' Sciensano, the Belgian Institute for Health, coordinates a surveillance network of about
#' 100 general practices all over Belgium. They report data every week about
#' different health problems, including their workload due to acute respiratory infections
#' on a 5-point scale (very low/low/normal/high/very high). The percentage of responding GPs
#' with a high or very high workload is an important epidemiological surveillance signal.
#'
#' This data set contains synthetic data that mimics the behavior of the real workload data
#' for the period 2021-02-22 to 2026-02-02.
#'
#' @format ## `df_gp_be`
#' A data frame with 259 rows and 3 columns:
#' \describe{
#'   \item{index}{Week encoded as Monday of that week (Date variable)}
#'   \item{num}{Number of GPs indicating a high or very high workload due to acute respiratory infection (integer variable)}
#'   \item{denom}{Number of responding GPS (integer variable)}
#' }
#' @source <https://www.sciensano.be/en/projects/network-general-practitioners>
"df_gp_be"
