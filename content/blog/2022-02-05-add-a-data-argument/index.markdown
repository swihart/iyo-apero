---
title: "How to add a data argument to your function"
subtitle: "Stop. Using. Attach()."
excerpt: "Adding a data argument has been on my list of to-dos and I decided to document the journey.  "
date: 2022-02-05
author: "Bruce Swihart"
draft: false
images:
series:
tags:
categories:
  - Musings
layout: single-sidebar
---

I am maintaining code that was originally created to make extensive use of `attach()`.  I have come to learn (and be adamantly told) that this is not preferrable for deployable code ([see this SO](https://stackoverflow.com/q/10067680/2727349)).  So, I'd like to investigate adding a data argument to my function call that fits a regression, and I'm going to investigate how `lm` does it to get more knowledgeable.

## lm

Let's get the guts of `lm()` and use the example from `?lm()` and just go an iterative, sequential, journey of commenting out lines and getting a handle on what happens to the `data` argument as it makes it way through the function.

## The setup of the example


```r
ctl <- c(4.17,5.58,5.18,6.11,4.50,4.61,5.17,4.53,5.33,5.14)
trt <- c(4.81,4.17,4.41,3.59,5.87,3.83,6.03,4.89,4.32,4.69)
group <- gl(2, 10, 20, labels = c("Ctl","Trt"))
weight <- c(ctl, trt)
lm.D9 <- lm(weight ~ group)


## make a dataset and use data argument
dat_gw <- data.frame(group= group,
           weight = weight)

lm.dat <- lm(weight~group, data=dat_gw)
```

## What does match.call do?

We comment out everything below match.call in our function `my_lm()` which is just a copy and paste of the guts of `lm`, which I got from typing `lm` (no parentheses!) in R:


```r
    ## guts of lm:
my_lm <-
function (formula, data, subset, weights, na.action, method = "qr",
          model = TRUE, x = FALSE, y = FALSE, qr = TRUE, singular.ok = TRUE,
          contrasts = NULL, offset, ...){
  ret.x <- x
  ret.y <- y
  cl <- match.call()
  
  cl
  # mf <- match.call(expand.dots = FALSE)
  # m <- match(c("formula", "data", "subset", "weights", "na.action", 
  #              "offset"), names(mf), 0L)
  # mf <- mf[c(1L, m)]
  # mf$drop.unused.levels <- TRUE
  # mf[[1L]] <- quote(stats::model.frame)
  # mf <- eval(mf, parent.frame())
  # if (method == "model.frame") 
  #   return(mf)
  # else if (method != "qr") 
  #   warning(gettextf("method = '%s' is not supported. Using 'qr'", 
  #                    method), domain = NA)
  # mt <- attr(mf, "terms")
  # y <- model.response(mf, "numeric")
  # w <- as.vector(model.weights(mf))
  # if (!is.null(w) && !is.numeric(w)) 
  #   stop("'weights' must be a numeric vector")
  # offset <- model.offset(mf)
  # mlm <- is.matrix(y)
  # ny <- if (mlm) 
  #   nrow(y)
  # else length(y)
  # if (!is.null(offset)) {
  #   if (!mlm) 
  #     offset <- as.vector(offset)
  #   if (NROW(offset) != ny) 
  #     stop(gettextf("number of offsets is %d, should equal %d (number of observations)", 
  #                   NROW(offset), ny), domain = NA)
  # }
  # if (is.empty.model(mt)) {
  #   x <- NULL
  #   z <- list(coefficients = if (mlm) matrix(NA_real_, 0, 
  #                                            ncol(y)) else numeric(), residuals = y, fitted.values = 0 * 
  #               y, weights = w, rank = 0L, df.residual = if (!is.null(w)) sum(w != 
  #                                                                               0) else ny)
  #   if (!is.null(offset)) {
  #     z$fitted.values <- offset
  #     z$residuals <- y - offset
  #   }
  # }
  # else {
  #   x <- model.matrix(mt, mf, contrasts)
  #   z <- if (is.null(w)) 
  #     lm.fit(x, y, offset = offset, singular.ok = singular.ok, 
  #            ...)
  #   else lm.wfit(x, y, w, offset = offset, singular.ok = singular.ok, 
  #                ...)
  # }
  # class(z) <- c(if (mlm) "mlm", "lm")
  # z$na.action <- attr(mf, "na.action")
  # z$offset <- offset
  # z$contrasts <- attr(x, "contrasts")
  # z$xlevels <- .getXlevels(mt, mf)
  # z$call <- cl
  # z$terms <- mt
  # if (model) 
  #   z$model <- mf
  # if (ret.x) 
  #   z$x <- x
  # if (ret.y) 
  #   z$y <- y
  # if (!qr) 
  #   z$qr <- NULL
  # z
}
```

So I have seen match.call() before in my years of R-ing, but I actually don't know what it does.  `?match.call` makes it seems like it return the call with the full names.  Look at these calls where I type out less and less of the word `data`:

```

my_lm(weight~group, data=dat_gw)

my_lm(weight~group, dat=dat_gw)

my_lm(weight~group, da=dat_gw)

my_lm(weight~group, d=dat_gw)
```

and for each they execute returning the full word `data`.  Good to know!


```r
my_lm(weight~group, data=dat_gw)
```

```
## my_lm(formula = weight ~ group, data = dat_gw)
```

```r
my_lm(weight~group, dat=dat_gw)
```

```
## my_lm(formula = weight ~ group, data = dat_gw)
```

```r
my_lm(weight~group, da=dat_gw)
```

```
## my_lm(formula = weight ~ group, data = dat_gw)
```

```r
my_lm(weight~group, d=dat_gw)
```

```
## my_lm(formula = weight ~ group, data = dat_gw)
```

Okay, so let's revise my_lm to go through more lines, keeping an eye out for anything involving `data`.


```r
    ## guts of lm:
my_lm <-
function (formula, data, subset, weights, na.action, method = "qr",
          model = TRUE, x = FALSE, y = FALSE, qr = TRUE, singular.ok = TRUE,
          contrasts = NULL, offset, ...){
  ret.x <- x
  ret.y <- y
  cl <- match.call()
  mf <- match.call(expand.dots = FALSE)
  mf
  # m <- match(c("formula", "data", "subset", "weights", "na.action", 
  #              "offset"), names(mf), 0L)
  # mf <- mf[c(1L, m)]
  # mf$drop.unused.levels <- TRUE
  # mf[[1L]] <- quote(stats::model.frame)
  # mf <- eval(mf, parent.frame())
  # if (method == "model.frame") 
  #   return(mf)
  # else if (method != "qr") 
  #   warning(gettextf("method = '%s' is not supported. Using 'qr'", 
  #                    method), domain = NA)
  # mt <- attr(mf, "terms")
  # y <- model.response(mf, "numeric")
  # w <- as.vector(model.weights(mf))
  # if (!is.null(w) && !is.numeric(w)) 
  #   stop("'weights' must be a numeric vector")
  # offset <- model.offset(mf)
  # mlm <- is.matrix(y)
  # ny <- if (mlm) 
  #   nrow(y)
  # else length(y)
  # if (!is.null(offset)) {
  #   if (!mlm) 
  #     offset <- as.vector(offset)
  #   if (NROW(offset) != ny) 
  #     stop(gettextf("number of offsets is %d, should equal %d (number of observations)", 
  #                   NROW(offset), ny), domain = NA)
  # }
  # if (is.empty.model(mt)) {
  #   x <- NULL
  #   z <- list(coefficients = if (mlm) matrix(NA_real_, 0, 
  #                                            ncol(y)) else numeric(), residuals = y, fitted.values = 0 * 
  #               y, weights = w, rank = 0L, df.residual = if (!is.null(w)) sum(w != 
  #                                                                               0) else ny)
  #   if (!is.null(offset)) {
  #     z$fitted.values <- offset
  #     z$residuals <- y - offset
  #   }
  # }
  # else {
  #   x <- model.matrix(mt, mf, contrasts)
  #   z <- if (is.null(w)) 
  #     lm.fit(x, y, offset = offset, singular.ok = singular.ok, 
  #            ...)
  #   else lm.wfit(x, y, w, offset = offset, singular.ok = singular.ok, 
  #                ...)
  # }
  # class(z) <- c(if (mlm) "mlm", "lm")
  # z$na.action <- attr(mf, "na.action")
  # z$offset <- offset
  # z$contrasts <- attr(x, "contrasts")
  # z$xlevels <- .getXlevels(mt, mf)
  # z$call <- cl
  # z$terms <- mt
  # if (model) 
  #   z$model <- mf
  # if (ret.x) 
  #   z$x <- x
  # if (ret.y) 
  #   z$y <- y
  # if (!qr) 
  #   z$qr <- NULL
  # z
}
```

```

my_lm(weight~group, data=dat_gw)

my_lm(weight~group, dat=dat_gw)

my_lm(weight~group, da=dat_gw)

my_lm(weight~group, d=dat_gw)
```

Ok.  So not much going on.  I tried it with `match.call(expand=TRUE)` as well...it seems as though the first one is call with `expand=FALSE` and the second one is expand=TRUE (default for `match.call`) ... then they combine them. 


```r
my_lm(weight~group, data=dat_gw)
```

```
## my_lm(formula = weight ~ group, data = dat_gw)
```

```r
my_lm(weight~group, dat=dat_gw)
```

```
## my_lm(formula = weight ~ group, data = dat_gw)
```

```r
my_lm(weight~group, da=dat_gw)
```

```
## my_lm(formula = weight ~ group, data = dat_gw)
```

```r
my_lm(weight~group, d=dat_gw)
```

```
## my_lm(formula = weight ~ group, data = dat_gw)
```



Okay, so let's revise my_lm to go through more lines, keeping an eye out for anything involving `data`.


```r
    ## guts of lm:
my_lm <-
function (formula, data, subset, weights, na.action, method = "qr",
          model = TRUE, x = FALSE, y = FALSE, qr = TRUE, singular.ok = TRUE,
          contrasts = NULL, offset, ...){
  ret.x <- x
  ret.y <- y
  cl <- match.call()
  mf <- match.call(expand.dots = FALSE)
  m <- match(c("formula", "data", "subset", "weights", "na.action", 
                "offset"), names(mf), 0L)
  m
  # mf <- mf[c(1L, m)]
  # mf$drop.unused.levels <- TRUE
  # mf[[1L]] <- quote(stats::model.frame)
  # mf <- eval(mf, parent.frame())
  # if (method == "model.frame") 
  #   return(mf)
  # else if (method != "qr") 
  #   warning(gettextf("method = '%s' is not supported. Using 'qr'", 
  #                    method), domain = NA)
  # mt <- attr(mf, "terms")
  # y <- model.response(mf, "numeric")
  # w <- as.vector(model.weights(mf))
  # if (!is.null(w) && !is.numeric(w)) 
  #   stop("'weights' must be a numeric vector")
  # offset <- model.offset(mf)
  # mlm <- is.matrix(y)
  # ny <- if (mlm) 
  #   nrow(y)
  # else length(y)
  # if (!is.null(offset)) {
  #   if (!mlm) 
  #     offset <- as.vector(offset)
  #   if (NROW(offset) != ny) 
  #     stop(gettextf("number of offsets is %d, should equal %d (number of observations)", 
  #                   NROW(offset), ny), domain = NA)
  # }
  # if (is.empty.model(mt)) {
  #   x <- NULL
  #   z <- list(coefficients = if (mlm) matrix(NA_real_, 0, 
  #                                            ncol(y)) else numeric(), residuals = y, fitted.values = 0 * 
  #               y, weights = w, rank = 0L, df.residual = if (!is.null(w)) sum(w != 
  #                                                                               0) else ny)
  #   if (!is.null(offset)) {
  #     z$fitted.values <- offset
  #     z$residuals <- y - offset
  #   }
  # }
  # else {
  #   x <- model.matrix(mt, mf, contrasts)
  #   z <- if (is.null(w)) 
  #     lm.fit(x, y, offset = offset, singular.ok = singular.ok, 
  #            ...)
  #   else lm.wfit(x, y, w, offset = offset, singular.ok = singular.ok, 
  #                ...)
  # }
  # class(z) <- c(if (mlm) "mlm", "lm")
  # z$na.action <- attr(mf, "na.action")
  # z$offset <- offset
  # z$contrasts <- attr(x, "contrasts")
  # z$xlevels <- .getXlevels(mt, mf)
  # z$call <- cl
  # z$terms <- mt
  # if (model) 
  #   z$model <- mf
  # if (ret.x) 
  #   z$x <- x
  # if (ret.y) 
  #   z$y <- y
  # if (!qr) 
  #   z$qr <- NULL
  # z
}
```

```

my_lm(weight~group, data=dat_gw)

my_lm(weight~group, dat=dat_gw)

my_lm(weight~group, da=dat_gw)

my_lm(weight~group, d=dat_gw)
```

Ok.  `m` seems to be returning location info.


```r
my_lm(weight~group, data=dat_gw)
```

```
## [1] 2 3 0 0 0 0
```

```r
my_lm(weight~group, dat=dat_gw)
```

```
## [1] 2 3 0 0 0 0
```

```r
my_lm(weight~group, da=dat_gw)
```

```
## [1] 2 3 0 0 0 0
```

```r
my_lm(weight~group, d=dat_gw)
```

```
## [1] 2 3 0 0 0 0
```


Okay, so let's revise my_lm to go through more lines, keeping an eye out for anything involving `data`.


```r
    ## guts of lm:
my_lm <-
function (formula, data, subset, weights, na.action, method = "qr",
          model = TRUE, x = FALSE, y = FALSE, qr = TRUE, singular.ok = TRUE,
          contrasts = NULL, offset, ...){
  ret.x <- x
  ret.y <- y
  cl <- match.call()
  mf <- match.call(expand.dots = FALSE)
  m <- match(c("formula", "data", "subset", "weights", "na.action", 
                "offset"), names(mf), 0L)
   mf <- mf[c(1L, m)]
   mf
  # mf$drop.unused.levels <- TRUE
  # mf[[1L]] <- quote(stats::model.frame)
  # mf <- eval(mf, parent.frame())
  # if (method == "model.frame") 
  #   return(mf)
  # else if (method != "qr") 
  #   warning(gettextf("method = '%s' is not supported. Using 'qr'", 
  #                    method), domain = NA)
  # mt <- attr(mf, "terms")
  # y <- model.response(mf, "numeric")
  # w <- as.vector(model.weights(mf))
  # if (!is.null(w) && !is.numeric(w)) 
  #   stop("'weights' must be a numeric vector")
  # offset <- model.offset(mf)
  # mlm <- is.matrix(y)
  # ny <- if (mlm) 
  #   nrow(y)
  # else length(y)
  # if (!is.null(offset)) {
  #   if (!mlm) 
  #     offset <- as.vector(offset)
  #   if (NROW(offset) != ny) 
  #     stop(gettextf("number of offsets is %d, should equal %d (number of observations)", 
  #                   NROW(offset), ny), domain = NA)
  # }
  # if (is.empty.model(mt)) {
  #   x <- NULL
  #   z <- list(coefficients = if (mlm) matrix(NA_real_, 0, 
  #                                            ncol(y)) else numeric(), residuals = y, fitted.values = 0 * 
  #               y, weights = w, rank = 0L, df.residual = if (!is.null(w)) sum(w != 
  #                                                                               0) else ny)
  #   if (!is.null(offset)) {
  #     z$fitted.values <- offset
  #     z$residuals <- y - offset
  #   }
  # }
  # else {
  #   x <- model.matrix(mt, mf, contrasts)
  #   z <- if (is.null(w)) 
  #     lm.fit(x, y, offset = offset, singular.ok = singular.ok, 
  #            ...)
  #   else lm.wfit(x, y, w, offset = offset, singular.ok = singular.ok, 
  #                ...)
  # }
  # class(z) <- c(if (mlm) "mlm", "lm")
  # z$na.action <- attr(mf, "na.action")
  # z$offset <- offset
  # z$contrasts <- attr(x, "contrasts")
  # z$xlevels <- .getXlevels(mt, mf)
  # z$call <- cl
  # z$terms <- mt
  # if (model) 
  #   z$model <- mf
  # if (ret.x) 
  #   z$x <- x
  # if (ret.y) 
  #   z$y <- y
  # if (!qr) 
  #   z$qr <- NULL
  # z
}
```

```

my_lm(weight~group, data=dat_gw)

my_lm(weight~group, dat=dat_gw)

my_lm(weight~group, da=dat_gw)

my_lm(weight~group, d=dat_gw)
```

Ok.  ` mf <- mf[c(1L, m)]` seems to be returning 1L, 2, 3 because m had 2,3.


```r
my_lm(weight~group, data=dat_gw)
```

```
## my_lm(formula = weight ~ group, data = dat_gw)
```

```r
my_lm(weight~group, dat=dat_gw)
```

```
## my_lm(formula = weight ~ group, data = dat_gw)
```

```r
my_lm(weight~group, da=dat_gw)
```

```
## my_lm(formula = weight ~ group, data = dat_gw)
```

```r
my_lm(weight~group, d=dat_gw)
```

```
## my_lm(formula = weight ~ group, data = dat_gw)
```


Okay, so let's revise my_lm to go through more lines, keeping an eye out for anything involving `data`.


```r
    ## guts of lm:
my_lm <-
function (formula, data, subset, weights, na.action, method = "qr",
          model = TRUE, x = FALSE, y = FALSE, qr = TRUE, singular.ok = TRUE,
          contrasts = NULL, offset, ...){
  ret.x <- x
  ret.y <- y
  cl <- match.call()
  mf <- match.call(expand.dots = FALSE)
  m <- match(c("formula", "data", "subset", "weights", "na.action", 
                "offset"), names(mf), 0L)
   mf <- mf[c(1L, m)]
   mf$drop.unused.levels <- TRUE
   mf[[1L]] <- quote(stats::model.frame)
   
   mf
   
  # mf <- eval(mf, parent.frame())
  # if (method == "model.frame") 
  #   return(mf)
  # else if (method != "qr") 
  #   warning(gettextf("method = '%s' is not supported. Using 'qr'", 
  #                    method), domain = NA)
  # mt <- attr(mf, "terms")
  # y <- model.response(mf, "numeric")
  # w <- as.vector(model.weights(mf))
  # if (!is.null(w) && !is.numeric(w)) 
  #   stop("'weights' must be a numeric vector")
  # offset <- model.offset(mf)
  # mlm <- is.matrix(y)
  # ny <- if (mlm) 
  #   nrow(y)
  # else length(y)
  # if (!is.null(offset)) {
  #   if (!mlm) 
  #     offset <- as.vector(offset)
  #   if (NROW(offset) != ny) 
  #     stop(gettextf("number of offsets is %d, should equal %d (number of observations)", 
  #                   NROW(offset), ny), domain = NA)
  # }
  # if (is.empty.model(mt)) {
  #   x <- NULL
  #   z <- list(coefficients = if (mlm) matrix(NA_real_, 0, 
  #                                            ncol(y)) else numeric(), residuals = y, fitted.values = 0 * 
  #               y, weights = w, rank = 0L, df.residual = if (!is.null(w)) sum(w != 
  #                                                                               0) else ny)
  #   if (!is.null(offset)) {
  #     z$fitted.values <- offset
  #     z$residuals <- y - offset
  #   }
  # }
  # else {
  #   x <- model.matrix(mt, mf, contrasts)
  #   z <- if (is.null(w)) 
  #     lm.fit(x, y, offset = offset, singular.ok = singular.ok, 
  #            ...)
  #   else lm.wfit(x, y, w, offset = offset, singular.ok = singular.ok, 
  #                ...)
  # }
  # class(z) <- c(if (mlm) "mlm", "lm")
  # z$na.action <- attr(mf, "na.action")
  # z$offset <- offset
  # z$contrasts <- attr(x, "contrasts")
  # z$xlevels <- .getXlevels(mt, mf)
  # z$call <- cl
  # z$terms <- mt
  # if (model) 
  #   z$model <- mf
  # if (ret.x) 
  #   z$x <- x
  # if (ret.y) 
  #   z$y <- y
  # if (!qr) 
  #   z$qr <- NULL
  # z
}
```

```

my_lm(weight~group, data=dat_gw)

my_lm(weight~group, dat=dat_gw)

my_lm(weight~group, da=dat_gw)

my_lm(weight~group, d=dat_gw)
```

Ok.  Okay, so we can add arguments like `drop.unused.levels` and change it from lm() stats::model.frame().


```r
my_lm(weight~group, data=dat_gw)
```

```
## stats::model.frame(formula = weight ~ group, data = dat_gw, drop.unused.levels = TRUE)
```

```r
my_lm(weight~group, dat=dat_gw)
```

```
## stats::model.frame(formula = weight ~ group, data = dat_gw, drop.unused.levels = TRUE)
```

```r
my_lm(weight~group, da=dat_gw)
```

```
## stats::model.frame(formula = weight ~ group, data = dat_gw, drop.unused.levels = TRUE)
```

```r
my_lm(weight~group, d=dat_gw)
```

```
## stats::model.frame(formula = weight ~ group, data = dat_gw, drop.unused.levels = TRUE)
```


I'm guessing the mf[[1L]] is what the name of the function call is because that's how we changed my_lm to stats::model.frame().  Then the 2,3 was the formulat and data argument.  

So maybe we are close to seeing how regression models add data arguments ... a little bit of book keeping with match.call() and then passing things to stats:model.frame().  Because that would execute as:


```r
stats::model.frame(formula = weight ~ group, data = dat_gw, drop.unused.levels = TRUE)
```

```
##    weight group
## 1    4.17   Ctl
## 2    5.58   Ctl
## 3    5.18   Ctl
## 4    6.11   Ctl
## 5    4.50   Ctl
## 6    4.61   Ctl
## 7    5.17   Ctl
## 8    4.53   Ctl
## 9    5.33   Ctl
## 10   5.14   Ctl
## 11   4.81   Trt
## 12   4.17   Trt
## 13   4.41   Trt
## 14   3.59   Trt
## 15   5.87   Trt
## 16   3.83   Trt
## 17   6.03   Trt
## 18   4.89   Trt
## 19   4.32   Trt
## 20   4.69   Trt
```

which is not all too different than the dataset itself:


```r
dat_gw
```

```
##    group weight
## 1    Ctl   4.17
## 2    Ctl   5.58
## 3    Ctl   5.18
## 4    Ctl   6.11
## 5    Ctl   4.50
## 6    Ctl   4.61
## 7    Ctl   5.17
## 8    Ctl   4.53
## 9    Ctl   5.33
## 10   Ctl   5.14
## 11   Trt   4.81
## 12   Trt   4.17
## 13   Trt   4.41
## 14   Trt   3.59
## 15   Trt   5.87
## 16   Trt   3.83
## 17   Trt   6.03
## 18   Trt   4.89
## 19   Trt   4.32
## 20   Trt   4.69
```

Okay, so let's revise my_lm to go through more lines, keeping an eye out for anything involving `data`.


```r
    ## guts of lm:
my_lm <-
function (formula, data, subset, weights, na.action, method = "qr",
          model = TRUE, x = FALSE, y = FALSE, qr = TRUE, singular.ok = TRUE,
          contrasts = NULL, offset, ...){
  ret.x <- x
  ret.y <- y
  cl <- match.call()
  mf <- match.call(expand.dots = FALSE)
  m <- match(c("formula", "data", "subset", "weights", "na.action", 
                "offset"), names(mf), 0L)
   mf <- mf[c(1L, m)]
   mf$drop.unused.levels <- TRUE
   mf[[1L]] <- quote(stats::model.frame)
  mf <- eval(mf, parent.frame())
  mf
  # if (method == "model.frame") 
  #   return(mf)
  # else if (method != "qr") 
  #   warning(gettextf("method = '%s' is not supported. Using 'qr'", 
  #                    method), domain = NA)
  # mt <- attr(mf, "terms")
  # y <- model.response(mf, "numeric")
  # w <- as.vector(model.weights(mf))
  # if (!is.null(w) && !is.numeric(w)) 
  #   stop("'weights' must be a numeric vector")
  # offset <- model.offset(mf)
  # mlm <- is.matrix(y)
  # ny <- if (mlm) 
  #   nrow(y)
  # else length(y)
  # if (!is.null(offset)) {
  #   if (!mlm) 
  #     offset <- as.vector(offset)
  #   if (NROW(offset) != ny) 
  #     stop(gettextf("number of offsets is %d, should equal %d (number of observations)", 
  #                   NROW(offset), ny), domain = NA)
  # }
  # if (is.empty.model(mt)) {
  #   x <- NULL
  #   z <- list(coefficients = if (mlm) matrix(NA_real_, 0, 
  #                                            ncol(y)) else numeric(), residuals = y, fitted.values = 0 * 
  #               y, weights = w, rank = 0L, df.residual = if (!is.null(w)) sum(w != 
  #                                                                               0) else ny)
  #   if (!is.null(offset)) {
  #     z$fitted.values <- offset
  #     z$residuals <- y - offset
  #   }
  # }
  # else {
  #   x <- model.matrix(mt, mf, contrasts)
  #   z <- if (is.null(w)) 
  #     lm.fit(x, y, offset = offset, singular.ok = singular.ok, 
  #            ...)
  #   else lm.wfit(x, y, w, offset = offset, singular.ok = singular.ok, 
  #                ...)
  # }
  # class(z) <- c(if (mlm) "mlm", "lm")
  # z$na.action <- attr(mf, "na.action")
  # z$offset <- offset
  # z$contrasts <- attr(x, "contrasts")
  # z$xlevels <- .getXlevels(mt, mf)
  # z$call <- cl
  # z$terms <- mt
  # if (model) 
  #   z$model <- mf
  # if (ret.x) 
  #   z$x <- x
  # if (ret.y) 
  #   z$y <- y
  # if (!qr) 
  #   z$qr <- NULL
  # z
}
```

```

my_lm(weight~group, data=dat_gw)

my_lm(weight~group, dat=dat_gw)

my_lm(weight~group, da=dat_gw)

my_lm(weight~group, d=dat_gw)
```

Ok.  `eval(mf,parent.frame)` is just like when I typed out and excuted the `stats::model.frame(formula = weight ~ group, data = dat_gw, drop.unused.levels = TRUE)`.  So again, looks like it has been a little bit of book keeping within the function to set things up, and then we use eval to evaluate a function in the parent frame.  This might be good enough for our purposes (adding data argument to `gnlrim`), but let's keep going.


```r
my_lm(weight~group, data=dat_gw)
```

```
##    weight group
## 1    4.17   Ctl
## 2    5.58   Ctl
## 3    5.18   Ctl
## 4    6.11   Ctl
## 5    4.50   Ctl
## 6    4.61   Ctl
## 7    5.17   Ctl
## 8    4.53   Ctl
## 9    5.33   Ctl
## 10   5.14   Ctl
## 11   4.81   Trt
## 12   4.17   Trt
## 13   4.41   Trt
## 14   3.59   Trt
## 15   5.87   Trt
## 16   3.83   Trt
## 17   6.03   Trt
## 18   4.89   Trt
## 19   4.32   Trt
## 20   4.69   Trt
```

```r
my_lm(weight~group, dat=dat_gw)
```

```
##    weight group
## 1    4.17   Ctl
## 2    5.58   Ctl
## 3    5.18   Ctl
## 4    6.11   Ctl
## 5    4.50   Ctl
## 6    4.61   Ctl
## 7    5.17   Ctl
## 8    4.53   Ctl
## 9    5.33   Ctl
## 10   5.14   Ctl
## 11   4.81   Trt
## 12   4.17   Trt
## 13   4.41   Trt
## 14   3.59   Trt
## 15   5.87   Trt
## 16   3.83   Trt
## 17   6.03   Trt
## 18   4.89   Trt
## 19   4.32   Trt
## 20   4.69   Trt
```

```r
my_lm(weight~group, da=dat_gw)
```

```
##    weight group
## 1    4.17   Ctl
## 2    5.58   Ctl
## 3    5.18   Ctl
## 4    6.11   Ctl
## 5    4.50   Ctl
## 6    4.61   Ctl
## 7    5.17   Ctl
## 8    4.53   Ctl
## 9    5.33   Ctl
## 10   5.14   Ctl
## 11   4.81   Trt
## 12   4.17   Trt
## 13   4.41   Trt
## 14   3.59   Trt
## 15   5.87   Trt
## 16   3.83   Trt
## 17   6.03   Trt
## 18   4.89   Trt
## 19   4.32   Trt
## 20   4.69   Trt
```

```r
my_lm(weight~group, d=dat_gw)
```

```
##    weight group
## 1    4.17   Ctl
## 2    5.58   Ctl
## 3    5.18   Ctl
## 4    6.11   Ctl
## 5    4.50   Ctl
## 6    4.61   Ctl
## 7    5.17   Ctl
## 8    4.53   Ctl
## 9    5.33   Ctl
## 10   5.14   Ctl
## 11   4.81   Trt
## 12   4.17   Trt
## 13   4.41   Trt
## 14   3.59   Trt
## 15   5.87   Trt
## 16   3.83   Trt
## 17   6.03   Trt
## 18   4.89   Trt
## 19   4.32   Trt
## 20   4.69   Trt
```




Okay, so let's revise my_lm to go through more lines, keeping an eye out for anything involving `data`.


```r
    ## guts of lm:
my_lm <-
function (formula, data, subset, weights, na.action, method = "qr",
          model = TRUE, x = FALSE, y = FALSE, qr = TRUE, singular.ok = TRUE,
          contrasts = NULL, offset, ...){
  ret.x <- x
  ret.y <- y
  cl <- match.call()
  mf <- match.call(expand.dots = FALSE)
  m <- match(c("formula", "data", "subset", "weights", "na.action", 
                "offset"), names(mf), 0L)
   mf <- mf[c(1L, m)]
   mf$drop.unused.levels <- TRUE
   mf[[1L]] <- quote(stats::model.frame)
  mf <- eval(mf, parent.frame())
   if (method == "model.frame") 
     return(mf)
   else if (method != "qr") 
     warning(gettextf("method = '%s' is not supported. Using 'qr'", 
                      method), domain = NA)
  
  
     warning(gettextf("method = '%s' is not supported. Using 'qr'", 
                      method), domain = NA)
  
  # mt <- attr(mf, "terms")
  # y <- model.response(mf, "numeric")
  # w <- as.vector(model.weights(mf))
  # if (!is.null(w) && !is.numeric(w)) 
  #   stop("'weights' must be a numeric vector")
  # offset <- model.offset(mf)
  # mlm <- is.matrix(y)
  # ny <- if (mlm) 
  #   nrow(y)
  # else length(y)
  # if (!is.null(offset)) {
  #   if (!mlm) 
  #     offset <- as.vector(offset)
  #   if (NROW(offset) != ny) 
  #     stop(gettextf("number of offsets is %d, should equal %d (number of observations)", 
  #                   NROW(offset), ny), domain = NA)
  # }
  # if (is.empty.model(mt)) {
  #   x <- NULL
  #   z <- list(coefficients = if (mlm) matrix(NA_real_, 0, 
  #                                            ncol(y)) else numeric(), residuals = y, fitted.values = 0 * 
  #               y, weights = w, rank = 0L, df.residual = if (!is.null(w)) sum(w != 
  #                                                                               0) else ny)
  #   if (!is.null(offset)) {
  #     z$fitted.values <- offset
  #     z$residuals <- y - offset
  #   }
  # }
  # else {
  #   x <- model.matrix(mt, mf, contrasts)
  #   z <- if (is.null(w)) 
  #     lm.fit(x, y, offset = offset, singular.ok = singular.ok, 
  #            ...)
  #   else lm.wfit(x, y, w, offset = offset, singular.ok = singular.ok, 
  #                ...)
  # }
  # class(z) <- c(if (mlm) "mlm", "lm")
  # z$na.action <- attr(mf, "na.action")
  # z$offset <- offset
  # z$contrasts <- attr(x, "contrasts")
  # z$xlevels <- .getXlevels(mt, mf)
  # z$call <- cl
  # z$terms <- mt
  # if (model) 
  #   z$model <- mf
  # if (ret.x) 
  #   z$x <- x
  # if (ret.y) 
  #   z$y <- y
  # if (!qr) 
  #   z$qr <- NULL
  # z
}
```

```

my_lm(weight~group, data=dat_gw)

my_lm(weight~group, dat=dat_gw)

my_lm(weight~group, da=dat_gw)

my_lm(weight~group, d=dat_gw)
```

Ok.  that `%s` trick is nice.  Does it refer to the if() condition?  Moving on.


```r
my_lm(weight~group, data=dat_gw)
```

```
## Warning in my_lm(weight ~ group, data = dat_gw): method = 'qr' is not supported.
## Using 'qr'
```

```r
my_lm(weight~group, dat=dat_gw)
```

```
## Warning in my_lm(weight ~ group, dat = dat_gw): method = 'qr' is not supported.
## Using 'qr'
```

```r
my_lm(weight~group, da=dat_gw)
```

```
## Warning in my_lm(weight ~ group, da = dat_gw): method = 'qr' is not supported.
## Using 'qr'
```

```r
my_lm(weight~group, d=dat_gw)
```

```
## Warning in my_lm(weight ~ group, d = dat_gw): method = 'qr' is not supported.
## Using 'qr'
```

Okay, so let's revise my_lm to go through more lines, keeping an eye out for anything involving `data`.


```r
    ## guts of lm:
my_lm <-
function (formula, data, subset, weights, na.action, method = "qr",
          model = TRUE, x = FALSE, y = FALSE, qr = TRUE, singular.ok = TRUE,
          contrasts = NULL, offset, ...){
  ret.x <- x
  ret.y <- y
  cl <- match.call()
  mf <- match.call(expand.dots = FALSE)
  m <- match(c("formula", "data", "subset", "weights", "na.action", 
                "offset"), names(mf), 0L)
   mf <- mf[c(1L, m)]
   mf$drop.unused.levels <- TRUE
   mf[[1L]] <- quote(stats::model.frame)
  mf <- eval(mf, parent.frame())
   if (method == "model.frame") 
     return(mf)
   else if (method != "qr") 
     warning(gettextf("method = '%s' is not supported. Using 'qr'", 
                      method), domain = NA)
   mt <- attr(mf, "terms")
   mt
  # y <- model.response(mf, "numeric")
  # w <- as.vector(model.weights(mf))
  # if (!is.null(w) && !is.numeric(w)) 
  #   stop("'weights' must be a numeric vector")
  # offset <- model.offset(mf)
  # mlm <- is.matrix(y)
  # ny <- if (mlm) 
  #   nrow(y)
  # else length(y)
  # if (!is.null(offset)) {
  #   if (!mlm) 
  #     offset <- as.vector(offset)
  #   if (NROW(offset) != ny) 
  #     stop(gettextf("number of offsets is %d, should equal %d (number of observations)", 
  #                   NROW(offset), ny), domain = NA)
  # }
  # if (is.empty.model(mt)) {
  #   x <- NULL
  #   z <- list(coefficients = if (mlm) matrix(NA_real_, 0, 
  #                                            ncol(y)) else numeric(), residuals = y, fitted.values = 0 * 
  #               y, weights = w, rank = 0L, df.residual = if (!is.null(w)) sum(w != 
  #                                                                               0) else ny)
  #   if (!is.null(offset)) {
  #     z$fitted.values <- offset
  #     z$residuals <- y - offset
  #   }
  # }
  # else {
  #   x <- model.matrix(mt, mf, contrasts)
  #   z <- if (is.null(w)) 
  #     lm.fit(x, y, offset = offset, singular.ok = singular.ok, 
  #            ...)
  #   else lm.wfit(x, y, w, offset = offset, singular.ok = singular.ok, 
  #                ...)
  # }
  # class(z) <- c(if (mlm) "mlm", "lm")
  # z$na.action <- attr(mf, "na.action")
  # z$offset <- offset
  # z$contrasts <- attr(x, "contrasts")
  # z$xlevels <- .getXlevels(mt, mf)
  # z$call <- cl
  # z$terms <- mt
  # if (model) 
  #   z$model <- mf
  # if (ret.x) 
  #   z$x <- x
  # if (ret.y) 
  #   z$y <- y
  # if (!qr) 
  #   z$qr <- NULL
  # z
}
```

```

my_lm(weight~group, data=dat_gw)

my_lm(weight~group, dat=dat_gw)

my_lm(weight~group, da=dat_gw)

my_lm(weight~group, d=dat_gw)
```

Ok.  That `mt` is a bunch of attribute stuff.  Not sure about it.


```r
my_lm(weight~group, data=dat_gw)
```

```
## weight ~ group
## attr(,"variables")
## list(weight, group)
## attr(,"factors")
##        group
## weight     0
## group      1
## attr(,"term.labels")
## [1] "group"
## attr(,"order")
## [1] 1
## attr(,"intercept")
## [1] 1
## attr(,"response")
## [1] 1
## attr(,".Environment")
## <environment: R_GlobalEnv>
## attr(,"predvars")
## list(weight, group)
## attr(,"dataClasses")
##    weight     group 
## "numeric"  "factor"
```

```r
my_lm(weight~group, dat=dat_gw)
```

```
## weight ~ group
## attr(,"variables")
## list(weight, group)
## attr(,"factors")
##        group
## weight     0
## group      1
## attr(,"term.labels")
## [1] "group"
## attr(,"order")
## [1] 1
## attr(,"intercept")
## [1] 1
## attr(,"response")
## [1] 1
## attr(,".Environment")
## <environment: R_GlobalEnv>
## attr(,"predvars")
## list(weight, group)
## attr(,"dataClasses")
##    weight     group 
## "numeric"  "factor"
```

```r
my_lm(weight~group, da=dat_gw)
```

```
## weight ~ group
## attr(,"variables")
## list(weight, group)
## attr(,"factors")
##        group
## weight     0
## group      1
## attr(,"term.labels")
## [1] "group"
## attr(,"order")
## [1] 1
## attr(,"intercept")
## [1] 1
## attr(,"response")
## [1] 1
## attr(,".Environment")
## <environment: R_GlobalEnv>
## attr(,"predvars")
## list(weight, group)
## attr(,"dataClasses")
##    weight     group 
## "numeric"  "factor"
```

```r
my_lm(weight~group, d=dat_gw)
```

```
## weight ~ group
## attr(,"variables")
## list(weight, group)
## attr(,"factors")
##        group
## weight     0
## group      1
## attr(,"term.labels")
## [1] "group"
## attr(,"order")
## [1] 1
## attr(,"intercept")
## [1] 1
## attr(,"response")
## [1] 1
## attr(,".Environment")
## <environment: R_GlobalEnv>
## attr(,"predvars")
## list(weight, group)
## attr(,"dataClasses")
##    weight     group 
## "numeric"  "factor"
```

Okay, so let's revise my_lm to go through more lines, keeping an eye out for anything involving `data`.


```r
    ## guts of lm:
my_lm <-
function (formula, data, subset, weights, na.action, method = "qr",
          model = TRUE, x = FALSE, y = FALSE, qr = TRUE, singular.ok = TRUE,
          contrasts = NULL, offset, ...){
  ret.x <- x
  ret.y <- y
  cl <- match.call()
  mf <- match.call(expand.dots = FALSE)
  m <- match(c("formula", "data", "subset", "weights", "na.action", 
                "offset"), names(mf), 0L)
   mf <- mf[c(1L, m)]
   mf$drop.unused.levels <- TRUE
   mf[[1L]] <- quote(stats::model.frame)
  mf <- eval(mf, parent.frame())
   if (method == "model.frame") 
     return(mf)
   else if (method != "qr") 
     warning(gettextf("method = '%s' is not supported. Using 'qr'", 
                      method), domain = NA)
   mt <- attr(mf, "terms")
   y <- model.response(mf, "numeric")
   y
  # w <- as.vector(model.weights(mf))
  # if (!is.null(w) && !is.numeric(w)) 
  #   stop("'weights' must be a numeric vector")
  # offset <- model.offset(mf)
  # mlm <- is.matrix(y)
  # ny <- if (mlm) 
  #   nrow(y)
  # else length(y)
  # if (!is.null(offset)) {
  #   if (!mlm) 
  #     offset <- as.vector(offset)
  #   if (NROW(offset) != ny) 
  #     stop(gettextf("number of offsets is %d, should equal %d (number of observations)", 
  #                   NROW(offset), ny), domain = NA)
  # }
  # if (is.empty.model(mt)) {
  #   x <- NULL
  #   z <- list(coefficients = if (mlm) matrix(NA_real_, 0, 
  #                                            ncol(y)) else numeric(), residuals = y, fitted.values = 0 * 
  #               y, weights = w, rank = 0L, df.residual = if (!is.null(w)) sum(w != 
  #                                                                               0) else ny)
  #   if (!is.null(offset)) {
  #     z$fitted.values <- offset
  #     z$residuals <- y - offset
  #   }
  # }
  # else {
  #   x <- model.matrix(mt, mf, contrasts)
  #   z <- if (is.null(w)) 
  #     lm.fit(x, y, offset = offset, singular.ok = singular.ok, 
  #            ...)
  #   else lm.wfit(x, y, w, offset = offset, singular.ok = singular.ok, 
  #                ...)
  # }
  # class(z) <- c(if (mlm) "mlm", "lm")
  # z$na.action <- attr(mf, "na.action")
  # z$offset <- offset
  # z$contrasts <- attr(x, "contrasts")
  # z$xlevels <- .getXlevels(mt, mf)
  # z$call <- cl
  # z$terms <- mt
  # if (model) 
  #   z$model <- mf
  # if (ret.x) 
  #   z$x <- x
  # if (ret.y) 
  #   z$y <- y
  # if (!qr) 
  #   z$qr <- NULL
  # z
}
```

```

my_lm(weight~group, data=dat_gw)

my_lm(weight~group, dat=dat_gw)

my_lm(weight~group, da=dat_gw)

my_lm(weight~group, d=dat_gw)
```

Ok.  model.response is based on mf so this should be straightforward and just list the 'y' or dependent variable:


```r
my_lm(weight~group, data=dat_gw)
```

```
##    1    2    3    4    5    6    7    8    9   10   11   12   13   14   15   16 
## 4.17 5.58 5.18 6.11 4.50 4.61 5.17 4.53 5.33 5.14 4.81 4.17 4.41 3.59 5.87 3.83 
##   17   18   19   20 
## 6.03 4.89 4.32 4.69
```

```r
my_lm(weight~group, dat=dat_gw)
```

```
##    1    2    3    4    5    6    7    8    9   10   11   12   13   14   15   16 
## 4.17 5.58 5.18 6.11 4.50 4.61 5.17 4.53 5.33 5.14 4.81 4.17 4.41 3.59 5.87 3.83 
##   17   18   19   20 
## 6.03 4.89 4.32 4.69
```

```r
my_lm(weight~group, da=dat_gw)
```

```
##    1    2    3    4    5    6    7    8    9   10   11   12   13   14   15   16 
## 4.17 5.58 5.18 6.11 4.50 4.61 5.17 4.53 5.33 5.14 4.81 4.17 4.41 3.59 5.87 3.83 
##   17   18   19   20 
## 6.03 4.89 4.32 4.69
```

```r
my_lm(weight~group, d=dat_gw)
```

```
##    1    2    3    4    5    6    7    8    9   10   11   12   13   14   15   16 
## 4.17 5.58 5.18 6.11 4.50 4.61 5.17 4.53 5.33 5.14 4.81 4.17 4.41 3.59 5.87 3.83 
##   17   18   19   20 
## 6.03 4.89 4.32 4.69
```

Similar with `w`?

Okay, so let's revise my_lm to go through more lines, keeping an eye out for anything involving `data`.


```r
    ## guts of lm:
my_lm <-
function (formula, data, subset, weights, na.action, method = "qr",
          model = TRUE, x = FALSE, y = FALSE, qr = TRUE, singular.ok = TRUE,
          contrasts = NULL, offset, ...){
  ret.x <- x
  ret.y <- y
  cl <- match.call()
  mf <- match.call(expand.dots = FALSE)
  m <- match(c("formula", "data", "subset", "weights", "na.action", 
                "offset"), names(mf), 0L)
   mf <- mf[c(1L, m)]
   mf$drop.unused.levels <- TRUE
   mf[[1L]] <- quote(stats::model.frame)
  mf <- eval(mf, parent.frame())
   if (method == "model.frame") 
     return(mf)
   else if (method != "qr") 
     warning(gettextf("method = '%s' is not supported. Using 'qr'", 
                      method), domain = NA)
   mt <- attr(mf, "terms")
   y <- model.response(mf, "numeric")
   w <- as.vector(model.weights(mf))
   w
  # if (!is.null(w) && !is.numeric(w)) 
  #   stop("'weights' must be a numeric vector")
  # offset <- model.offset(mf)
  # mlm <- is.matrix(y)
  # ny <- if (mlm) 
  #   nrow(y)
  # else length(y)
  # if (!is.null(offset)) {
  #   if (!mlm) 
  #     offset <- as.vector(offset)
  #   if (NROW(offset) != ny) 
  #     stop(gettextf("number of offsets is %d, should equal %d (number of observations)", 
  #                   NROW(offset), ny), domain = NA)
  # }
  # if (is.empty.model(mt)) {
  #   x <- NULL
  #   z <- list(coefficients = if (mlm) matrix(NA_real_, 0, 
  #                                            ncol(y)) else numeric(), residuals = y, fitted.values = 0 * 
  #               y, weights = w, rank = 0L, df.residual = if (!is.null(w)) sum(w != 
  #                                                                               0) else ny)
  #   if (!is.null(offset)) {
  #     z$fitted.values <- offset
  #     z$residuals <- y - offset
  #   }
  # }
  # else {
  #   x <- model.matrix(mt, mf, contrasts)
  #   z <- if (is.null(w)) 
  #     lm.fit(x, y, offset = offset, singular.ok = singular.ok, 
  #            ...)
  #   else lm.wfit(x, y, w, offset = offset, singular.ok = singular.ok, 
  #                ...)
  # }
  # class(z) <- c(if (mlm) "mlm", "lm")
  # z$na.action <- attr(mf, "na.action")
  # z$offset <- offset
  # z$contrasts <- attr(x, "contrasts")
  # z$xlevels <- .getXlevels(mt, mf)
  # z$call <- cl
  # z$terms <- mt
  # if (model) 
  #   z$model <- mf
  # if (ret.x) 
  #   z$x <- x
  # if (ret.y) 
  #   z$y <- y
  # if (!qr) 
  #   z$qr <- NULL
  # z
}
```

```

my_lm(weight~group, data=dat_gw)

my_lm(weight~group, dat=dat_gw)

my_lm(weight~group, da=dat_gw)

my_lm(weight~group, d=dat_gw)
```

Ok.  if weights aren't specified they're NULL.


```r
my_lm(weight~group, data=dat_gw)
```

```
## NULL
```

```r
my_lm(weight~group, dat=dat_gw)
```

```
## NULL
```

```r
my_lm(weight~group, da=dat_gw)
```

```
## NULL
```

```r
my_lm(weight~group, d=dat_gw)
```

```
## NULL
```


Okay, so let's revise my_lm to go through more lines, keeping an eye out for anything involving `data`.


```r
    ## guts of lm:
my_lm <-
function (formula, data, subset, weights, na.action, method = "qr",
          model = TRUE, x = FALSE, y = FALSE, qr = TRUE, singular.ok = TRUE,
          contrasts = NULL, offset, ...){
  ret.x <- x
  ret.y <- y
  cl <- match.call()
  mf <- match.call(expand.dots = FALSE)
  m <- match(c("formula", "data", "subset", "weights", "na.action", 
                "offset"), names(mf), 0L)
   mf <- mf[c(1L, m)]
   mf$drop.unused.levels <- TRUE
   mf[[1L]] <- quote(stats::model.frame)
  mf <- eval(mf, parent.frame())
   if (method == "model.frame") 
     return(mf)
   else if (method != "qr") 
     warning(gettextf("method = '%s' is not supported. Using 'qr'", 
                      method), domain = NA)
   mt <- attr(mf, "terms")
   y <- model.response(mf, "numeric")
   w <- as.vector(model.weights(mf))
  if (!is.null(w) && !is.numeric(w))
    stop("'weights' must be a numeric vector")
  offset <- model.offset(mf)
   mlm <- is.matrix(y)
   mlm
  # ny <- if (mlm) 
  #   nrow(y)
  # else length(y)
  # if (!is.null(offset)) {
  #   if (!mlm) 
  #     offset <- as.vector(offset)
  #   if (NROW(offset) != ny) 
  #     stop(gettextf("number of offsets is %d, should equal %d (number of observations)", 
  #                   NROW(offset), ny), domain = NA)
  # }
  # if (is.empty.model(mt)) {
  #   x <- NULL
  #   z <- list(coefficients = if (mlm) matrix(NA_real_, 0, 
  #                                            ncol(y)) else numeric(), residuals = y, fitted.values = 0 * 
  #               y, weights = w, rank = 0L, df.residual = if (!is.null(w)) sum(w != 
  #                                                                               0) else ny)
  #   if (!is.null(offset)) {
  #     z$fitted.values <- offset
  #     z$residuals <- y - offset
  #   }
  # }
  # else {
  #   x <- model.matrix(mt, mf, contrasts)
  #   z <- if (is.null(w)) 
  #     lm.fit(x, y, offset = offset, singular.ok = singular.ok, 
  #            ...)
  #   else lm.wfit(x, y, w, offset = offset, singular.ok = singular.ok, 
  #                ...)
  # }
  # class(z) <- c(if (mlm) "mlm", "lm")
  # z$na.action <- attr(mf, "na.action")
  # z$offset <- offset
  # z$contrasts <- attr(x, "contrasts")
  # z$xlevels <- .getXlevels(mt, mf)
  # z$call <- cl
  # z$terms <- mt
  # if (model) 
  #   z$model <- mf
  # if (ret.x) 
  #   z$x <- x
  # if (ret.y) 
  #   z$y <- y
  # if (!qr) 
  #   z$qr <- NULL
  # z
}
```

```

my_lm(weight~group, data=dat_gw)

my_lm(weight~group, dat=dat_gw)

my_lm(weight~group, da=dat_gw)

my_lm(weight~group, d=dat_gw)
```

Ok. so y is not a matrix.  In the gnlrim binomial outcome case, it might be.


```r
my_lm(weight~group, data=dat_gw)
```

```
## [1] FALSE
```

```r
my_lm(weight~group, dat=dat_gw)
```

```
## [1] FALSE
```

```r
my_lm(weight~group, da=dat_gw)
```

```
## [1] FALSE
```

```r
my_lm(weight~group, d=dat_gw)
```

```
## [1] FALSE
```


Okay, so let's revise my_lm to go through more lines, keeping an eye out for anything involving `data`.


```r
    ## guts of lm:
my_lm <-
function (formula, data, subset, weights, na.action, method = "qr",
          model = TRUE, x = FALSE, y = FALSE, qr = TRUE, singular.ok = TRUE,
          contrasts = NULL, offset, ...){
  ret.x <- x
  ret.y <- y
  cl <- match.call()
  mf <- match.call(expand.dots = FALSE)
  m <- match(c("formula", "data", "subset", "weights", "na.action", 
                "offset"), names(mf), 0L)
   mf <- mf[c(1L, m)]
   mf$drop.unused.levels <- TRUE
   mf[[1L]] <- quote(stats::model.frame)
  mf <- eval(mf, parent.frame())
   if (method == "model.frame") 
     return(mf)
   else if (method != "qr") 
     warning(gettextf("method = '%s' is not supported. Using 'qr'", 
                      method), domain = NA)
   mt <- attr(mf, "terms")
   y <- model.response(mf, "numeric")
   w <- as.vector(model.weights(mf))
   if (!is.null(w) && !is.numeric(w)) 
     stop("'weights' must be a numeric vector")
   offset <- model.offset(mf)
   mlm <- is.matrix(y)
   ny <- if (mlm) 
     nrow(y)
   else length(y)
  if (!is.null(offset)) {
    if (!mlm)
      offset <- as.vector(offset)
    if (NROW(offset) != ny)
      stop(gettextf("number of offsets is %d, should equal %d (number of observations)",
                    NROW(offset), ny), domain = NA)
  }
  if (is.empty.model(mt)) {
    x <- NULL
    z <- list(coefficients = if (mlm) matrix(NA_real_, 0,
                                             ncol(y)) else numeric(), residuals = y, fitted.values = 0 *
                y, weights = w, rank = 0L, df.residual = if (!is.null(w)) sum(w !=
                                                                                0) else ny)
    if (!is.null(offset)) {
      z$fitted.values <- offset
      z$residuals <- y - offset
    }
  }
  else {
    x <- model.matrix(mt, mf, contrasts)
    z <- if (is.null(w))
      lm.fit(x, y, offset = offset, singular.ok = singular.ok,
             ...)
    else lm.wfit(x, y, w, offset = offset, singular.ok = singular.ok,
                 ...)
  }
  x
  
  # class(z) <- c(if (mlm) "mlm", "lm")
  # z$na.action <- attr(mf, "na.action")
  # z$offset <- offset
  # z$contrasts <- attr(x, "contrasts")
  # z$xlevels <- .getXlevels(mt, mf)
  # z$call <- cl
  # z$terms <- mt
  # if (model) 
  #   z$model <- mf
  # if (ret.x) 
  #   z$x <- x
  # if (ret.y) 
  #   z$y <- y
  # if (!qr) 
  #   z$qr <- NULL
  # z
}
```

```

my_lm(weight~group, data=dat_gw)

my_lm(weight~group, dat=dat_gw)

my_lm(weight~group, da=dat_gw)

my_lm(weight~group, d=dat_gw)
```

Ok.  `x` is what we came here for.  it's based on `mt`, which was that thing with the attributes, and mf which was the thing that was build from match.calls and any contrasts (which is an argument in lm() with a default value of NULL). So this is a workhorse line -- takes the attribute info about factors etc and makes an intercept and a binary numeric variable so we can actually sent the "human interface" code of a specified lm() to the "computer interace" code of lm.fit().  lm.fit() doesn't have a data argument because lm() has basically served as a wrapper around it to take the info of the formula and data and make an x.  If humans weren't so lazy they'd just use lm.fit...(?).






```r
my_lm(weight~group, data=dat_gw)
```

```
##    (Intercept) groupTrt
## 1            1        0
## 2            1        0
## 3            1        0
## 4            1        0
## 5            1        0
## 6            1        0
## 7            1        0
## 8            1        0
## 9            1        0
## 10           1        0
## 11           1        1
## 12           1        1
## 13           1        1
## 14           1        1
## 15           1        1
## 16           1        1
## 17           1        1
## 18           1        1
## 19           1        1
## 20           1        1
## attr(,"assign")
## [1] 0 1
## attr(,"contrasts")
## attr(,"contrasts")$group
## [1] "contr.treatment"
```

```r
my_lm(weight~group, dat=dat_gw)
```

```
##    (Intercept) groupTrt
## 1            1        0
## 2            1        0
## 3            1        0
## 4            1        0
## 5            1        0
## 6            1        0
## 7            1        0
## 8            1        0
## 9            1        0
## 10           1        0
## 11           1        1
## 12           1        1
## 13           1        1
## 14           1        1
## 15           1        1
## 16           1        1
## 17           1        1
## 18           1        1
## 19           1        1
## 20           1        1
## attr(,"assign")
## [1] 0 1
## attr(,"contrasts")
## attr(,"contrasts")$group
## [1] "contr.treatment"
```

```r
my_lm(weight~group, da=dat_gw)
```

```
##    (Intercept) groupTrt
## 1            1        0
## 2            1        0
## 3            1        0
## 4            1        0
## 5            1        0
## 6            1        0
## 7            1        0
## 8            1        0
## 9            1        0
## 10           1        0
## 11           1        1
## 12           1        1
## 13           1        1
## 14           1        1
## 15           1        1
## 16           1        1
## 17           1        1
## 18           1        1
## 19           1        1
## 20           1        1
## attr(,"assign")
## [1] 0 1
## attr(,"contrasts")
## attr(,"contrasts")$group
## [1] "contr.treatment"
```

```r
my_lm(weight~group, d=dat_gw)
```

```
##    (Intercept) groupTrt
## 1            1        0
## 2            1        0
## 3            1        0
## 4            1        0
## 5            1        0
## 6            1        0
## 7            1        0
## 8            1        0
## 9            1        0
## 10           1        0
## 11           1        1
## 12           1        1
## 13           1        1
## 14           1        1
## 15           1        1
## 16           1        1
## 17           1        1
## 18           1        1
## 19           1        1
## 20           1        1
## attr(,"assign")
## [1] 0 1
## attr(,"contrasts")
## attr(,"contrasts")$group
## [1] "contr.treatment"
```


[to be continued]

