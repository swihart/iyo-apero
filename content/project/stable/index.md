---
title: "stable"
subtitle: "Probability Functions and Generalized Regression Models for Stable Distributions"
excerpt: "This is the CRAN maintained version of Jim Lindsey's `stable`."
date: 2017-10-12
author: "Jim Lindsey and maintained by Bruce Swihart"
draft: false
tags:
  - hugo-site
categories:
  - R
  - package
# layout options: single or single-sidebar
layout: single-sidebar
links:
- icon: door-open
  icon_pack: fas
  name: website
  url: https://www.commanster.eu/rcode.html
- icon: github
  icon_pack: fab
  name: code
  url: https://github.com/swihart/stable
- icon: r-project
  icon_pack: fab
  name: CRAN
  url: https://cran.r-project.org/web/packages/stable/index.html
---

I am maintaining Jim Lindsey's `stable` on CRAN.

The package contains density, distribution, quantile and hazard functions of a stable variate; generalized regression models for the parameters of a stable distribution. See github for a journal article using stable regression.  

Also consult the [Github README](https://github.com/swihart/stable#the-example-above-but-using-sd2s-and-s2sd) for functions  `stable::sd2s()` and `stable::s2sd()` that change the parameterization between `stable` and the current standard of Nolan's parameterization as in `stabledist` and `libstableR`. Also included are functions that convert from the Nolan parameterizations `pm=0` to `pm=1` (and the reverse):  `stable::pm0_to_pm1()` and `stable::pm1_to_pm0()`.

---

---
