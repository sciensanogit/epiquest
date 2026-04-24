# epiquest

The goal of epiquest is to compute **quantile epidemic state (QUEST)
thresholds**, developed in 2025 at Sciensano, the Belgian Institute for
Health. While other methods for thresholds of respiratory surveillance
signals aim to classify seasonal intensity, allowing for comparison
between seasons, the QUEST thresholds were developed to do
**week-to-week surveillance** of the epidemiogical situation. A central
objective during development was to ensure these thresholds were **easy
to interpret** and directly relevant to **monitoring the burden of
respiratory pathogens** on the healthcare system. In short, the method
uses a **hidden Markov model** to define the epidemic state and defines
thresholds as specific **quantiles** of observed epidemic state
incidences.

# Getting started

If you are new to the QUEST methodology, we recommend starting with our
primary guides:

- [Get started with
  QUEST](https://sciensanogit.github.io/epiquest/articles/getting-started.md)

- [Dealing with new
  data](https://sciensanogit.github.io/epiquest/articles/dealing-with-new-data.md)

## Installation

You can install the development version of epiquest from
[GitHub](https://github.com/sciensanogit/epiquest) as follows.

``` r

# install.packages("pak")
pak::pkg_install("sciensanogit/epiquest")
```
