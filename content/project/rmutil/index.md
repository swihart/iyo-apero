---
title: "rmutil"
subtitle: "Utilities for Nonlinear Regression and Repeated Measurements Models"
excerpt: "This is the CRAN maintained version of Jim Lindsey's `rmutil`."
date: 2017-10-20
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
  url: https://github.com/swihart/rmutil
- icon: r-project
  icon_pack: fab
  name: CRAN
  url: https://cran.r-project.org/web/packages/rmutil/index.html
---

I am maintaining Jim Lindsey's `rmutil` on CRAN. I pronouce it "*R*-*M*-*U*-till" and think it stands for Repeated Measurements Utilities, and is a toolkit of functions for nonlinear regression and repeated measurements not to be used by itself but called by other Lindsey packages such as `gnlm`, `stable`, `growth`, `repeated`, and `event`.

---


Accessed from the [R] help pipermail on 2021-11-27, but [written on 1999-11-09](https://stat.ethz.ch/pipermail/r-help/1999-November/005185.html):

## Re: numerical integration {better than integrate(.)} ?

> Jim Lindsey
>
> *Tue Nov 9 09:37:24 CET 1999*
>
>> 
>> {{I first wanted to send this to R-devel; 
>>   but then thought, maybe first hear of you all.. 
>>   and added a bit more
>> 
>>   Still could ask on R-devel later -- MM}
>> 
>> - In R, there's currently the "integrate" package from Mike Meyer, ported to
>>   R by Thomas Lumley which really relies on multi-dimensional integration
>>   "adapt" and is not particularly efficient for integrating simple 1d functions.
>>   It stops with error/warning many times when I try to use it.
>>   Also, it does not allow indefinite integrals (eg. from 0 to infty)
>> 
>> - MASS package has "area" which is there ``mainly for illustrative purposes''
>> 
>> - Jim Lindsey's non-CRAN "rmutil" package has  `int()'  which looks great,
>>   judged from the help (int.Rd), allowing to choose between Romberg and
>>   TOMS 614 methods, allowing for indefinite integrals and singularities at
>>   the end point(s).
>>   On the other hand, the C code seems somewhat complicated, and (for romberg.c),
>>   quite a bit nested  (romberg -> evalRfn -> ..; interp) and completely
>>   without comments. 
>> 
>>   [Yes: TOMS 614 has the copyright problem; but together with many more TOMS
>>         routines in R...]
>>   The (considerable!) drawback with  int() is that you don't get a
>>   precision estimate back, but maybe that would be easy..
>>   
>> - For nice functions, very fast and accurate Gaussian integration should be 
>>   "easy" to implement, and I remember having seen source for S, years ago,
>>   but can't find it easily now.
>>   The source would be so small that we could just include it in R's base
>>   package (and this might be true for other integration utilities). 
>> 
>> I would propose to include in R a hopefully simple, 
>> and `accurate in good cases'
>> integrate() function [ different name?] for numerical integration of 1d
>> functions. 
>> 
>> e.g. I want to be able to have things like
>> 
>>      integrate(function(x) dt(x,df=2), 0, Inf)
>>      integrate(function(x) x*sqrt(x) dnorm(x), 0, 10, eps = 1e-10)
>> 
>> work
>> [it *does* work with Jim's  int()  
>>     ((when one uses character "infty" instead of Inf)),
>
>That was written before Inf was in R and is obviously easy to fix.
>
>>  but in my experience, one needs a long time of parameter fiddling to make
>>  it produce a proper result with current integrate()]
>> 
>> Comments?
>> Ideas?
>> Jim, would you mind if e.g. I took your  int() & romberg code and
>>  changed it by adding comments, probably change the UI a bit (argument
>>  names; default values,..)?
>
> Absolutely no problem. All of my code is wide open to the R community.
>   Jim
>> 
>> MM
>> 
>>   
>> 
---
