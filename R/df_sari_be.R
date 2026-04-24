#' Belgian SARI data
#'
#' Sciensano, the Belgian Institute for Health, coordinates a surveillance network of hospitals
#' that record all cases of severe acute respiratory infection (SARI). These data are used to estimate
#' the weekly incidence of SARI hospitalisations in Belgium.
#'
#' This data set contains synthetic data that mimics the behavior of the real estimated incidences
#' for the period 2021-06-21 to 2025-05-26.
#'
#' @format ## `df_sari_be`
#' A data frame with 206 rows and 2 columns:
#' \describe{
#'   \item{index}{Week encoded as Monday of that week (Date variable)}
#'   \item{rate}{Belgian SARI incidence per 100,000 inhabitants (numerical variable)}
#' }
#' @source <https://www.sciensano.be/en/projects/severe-acute-respiratory-infection-surveillance-a-sentinel-network-hospitals>
"df_sari_be"
