---
title: "A more general logit link"
subtitle: "Inspired by the TBA vs TRA metrics in malaria"
excerpt: "Using a zero-inflated negative binomial model on oocyst counts, we can arrive at estimands for TRA and TBA.  The estimand for TBA is based on the probability of a count being greater than 0, which effectively dichotomizes the counts into 0s and 1s.  And thus a logit-like link is born.  What info can we recover if we only know if a count is greater than 0 or equal to 0?"
date: 2021-12-22
author: "Bruce Swihart"
draft: false
images:
series:
tags:
categories:
  - Musings
layout: single-sidebar
---

## ZINBRI

Zero-inflated negative binomial random intercept (ZINBRI) models.  A work horse.

`$$P(Y_{ik} > 0) = (1-\pi)\left(1-\left(\frac{\theta}{\lambda_i + \theta} \right)^\theta \right)$$` 

---

Graveyard below here.

---
I'm not very familiar with HGLMs.  My introduction to them was probably in 2009 when I was writing my thesis on bridging distributions.  Lee and Nelder had published a couple of papers critiquing ("offering another view") of the transfer function approach to getting marginal beta coefficients from a conditional model that was put forth by Heagerty (1999) and Heagerty and Zeger (2000).

Fast-forward to this morning and I had the notion of trying to get `gnlrim` to fit a Binomial-Beta HGLM -- or at least exploring the similarities.

My thinking was I know `gnlrim` can fit Binomial random intercept models and I feel comfortable editing in different mixture distributions.  Spoiler alert -- it took a little tinkering and head-scratching, but in the end I was able to add some functionality to `gnlrim` and show off a few features of `gnlrim` along the way.  The results from `gnlrim` didn't exactly match up with those of `hglm`, and maybe I'll dig deeper into that another day.



Here are some resources:


  * [Youtube Playlist on HGLM](https://www.youtube.com/playlist?list=PLn1OmZECD-n15vnYzvJDy5GxjNpVV5Jr8)

  * [R Journal `hglm`](https://journal.r-project.org/archive/2010/RJ-2010-009/RJ-2010-009.pdf) See Section 2.8.

  * [Lee & Nelder (1996)](https://rss.onlinelibrary.wiley.com/doi/pdfdirect/10.1111/j.2517-6161.1996.tb02105.x)  Pay attention to Sections 2.5 and 6.3.
  
  

```r
library(hglm)
library(gnlrim) ## github
```


### The `hglm::hglm()` Binomial-Beta fit
#### Seed Germination Data

From Section 2.8 of the [hglm vignette](https://cran.rstudio.com/web/packages/hglm/vignettes/hglm.pdf), we can fit a Binomial-Beta HGLM using hglm and access the estimates in a variety of ways.  I'll be focusing on the Fixed Effects and the Dispersion parameter.


```r
data(seeds)
germ.hglm <- 
  hglm(fixed = r/n ~ extract * I(seed == "O73"), 
       weights = n, 
       data = seeds,
       random = ~1 | plate, 
       family = binomial(), 
       rand.family = Beta(), 
       fix.disp = 1)
## print just fixed effects
germ.hglm$fixef 
```

```
##                          (Intercept)                      extractCucumber 
##                          -0.54240130                           1.33915914 
##                 I(seed == "O73")TRUE extractCucumber:I(seed == "O73")TRUE 
##                           0.07650678                          -0.82567005
```

```r
## print out random intercept predictions
germ.hglm$ranef 
```

```
##  as.factor(plate)1  as.factor(plate)2  as.factor(plate)3  as.factor(plate)4 
##          0.4429638          0.5021001          0.4404746          0.5802314 
##  as.factor(plate)5  as.factor(plate)6  as.factor(plate)7  as.factor(plate)8 
##          0.5342301          0.5325513          0.4772745          0.4581874 
##  as.factor(plate)9 as.factor(plate)10 as.factor(plate)11 as.factor(plate)12 
##          0.5665867          0.4654001          0.5188250          0.5192904 
## as.factor(plate)13 as.factor(plate)14 as.factor(plate)15 as.factor(plate)16 
##          0.5536540          0.4632428          0.4249292          0.5200586 
## as.factor(plate)17 as.factor(plate)18 as.factor(plate)19 as.factor(plate)20 
##          0.4405599          0.5123750          0.4949617          0.5642943 
## as.factor(plate)21 
##          0.4878092
```

```r
## list all random intercept predictions
print(germ.hglm, print.ranef = TRUE) 
```

```
## Call: 
## hglm.formula(family = binomial(), rand.family = Beta(), fixed = r/n ~ 
##     extract * I(seed == "O73"), random = ~1 | plate, data = seeds, 
##     weights = n, fix.disp = 1)
## 
## ---------------------------
## Estimates of the mean model
## ---------------------------
## 
## Fixed effects:
##                          (Intercept)                      extractCucumber 
##                          -0.54240130                           1.33915914 
##                 I(seed == "O73")TRUE extractCucumber:I(seed == "O73")TRUE 
##                           0.07650678                          -0.82567005 
## 
## Random effects:
##  as.factor(plate)1  as.factor(plate)2  as.factor(plate)3  as.factor(plate)4 
##          0.4429638          0.5021001          0.4404746          0.5802314 
##  as.factor(plate)5  as.factor(plate)6  as.factor(plate)7  as.factor(plate)8 
##          0.5342301          0.5325513          0.4772745          0.4581874 
##  as.factor(plate)9 as.factor(plate)10 as.factor(plate)11 as.factor(plate)12 
##          0.5665867          0.4654001          0.5188250          0.5192904 
## as.factor(plate)13 as.factor(plate)14 as.factor(plate)15 as.factor(plate)16 
##          0.5536540          0.4632428          0.4249292          0.5200586 
## as.factor(plate)17 as.factor(plate)18 as.factor(plate)19 as.factor(plate)20 
##          0.4405599          0.5123750          0.4949617          0.5642943 
## as.factor(plate)21 
##          0.4878092 
## 
## Dispersion parameter for the mean model: 1 
## 
## Dispersion parameter for the random effects: 0.02441951 
## 
## Estimation converged in 10 iterations
```

Stray observations:  the random intercepts are all really close to 0.50, which makes me think the shape parameter `\(a\)` for the `\({\rm Beta}(a,a)\)` distribution must be considerably large (remember, `\({\rm Beta}(1,1)\)` is uniform (in purple below) and as `\(a\)` increases the density for `\({\rm Beta}(a,a)\)` gets more and more concentrated about 0.50 (blue; red).  As `\(a\)` gets below 1 it starts "blowing up" near x=0 and x=1 (orange).)


```r
plot (seq(0,1,0.001),dbeta(seq(0,1,0.001),36.0,36.0), col="red"   , lwd=3, 
      type="l", xlab="x", ylab="beta densities")
lines(seq(0,1,0.001),dbeta(seq(0,1,0.001),20.0,20.0), col="blue"  , lwd=3,)
lines(seq(0,1,0.001),dbeta(seq(0,1,0.001), 1.0, 1.0), col="purple", lwd=3,)
lines(seq(0,1,0.001),dbeta(seq(0,1,0.001), 0.5, 0.5), col="orange", lwd=3,)
```

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-3-1.png" width="672" />


### `gnlrim::gnlrim()` fit
#### Seed Germination Data
Using `gnlrim` requires a little bit of setup.

```r
ybind <- cbind(seeds$r,seeds$n-seeds$r)
x1 <- (seeds$extract == "Cucumber") + 0L
x2 <- I(seeds$seed == "O73") + 0L
x3 <- x1*x2
plate.id <- seeds$plate
```

Our first approach is to just use the built in `mixture="beta"` that was left over from `repeated::gnlmix()`.  The random intercept is listed as `rand`.  This did not successfully run, see the commented error message.  My initial guess was that [Beta densities](https://en.wikipedia.org/wiki/Beta_prime_distribution) go off to Inf at 0 and 1 for values `\(\alpha=\beta < 1\)` and this was causing problems.  


```r
germ.gnlrim <-
 gnlrim(y=ybind,
         mu = ~ plogis(Intercept + 
                         x1*extract + 
                         x2*seed73 + 
                         x3*intx + 
                         rand
                       ),
         pmu = c(Intercept=0,extract=0,seed73=0,intx=0),
         pmix=c(alp1_eq_alp2=2),
         p_uppb = c(  1,   2,  1,  1, 20),
         p_lowb = c( -2,  -1, -1, -1, 0.2),
         distribution="binomial",
         nest=plate.id,
         random="rand",
         mixture="beta",
         ooo=TRUE,
         compute_hessian = FALSE,
         compute_kkt = FALSE,
         trace=1,
         method='nlminb'
  )
# 
# [1] NaN
# Error in gnlrim(y = ybind, mu = ~plogis(Intercept + x1 * extract + x2 *  : 
#   Likelihood returns Inf or NAs: invalid initial values, wrong model, or probabilities too small to calculate
# In addition: Warning message:
# In log(int1(fn, 0, 1)) : NaNs produced
```

I started tinkering, and for some reason switched `int1` with `intb` in the code guts and things started successfully running.  So I implemented `mixture= "beta-HGLM"`, and was pleased to see I was getting somewhere.  But the intercept was a bit off --  `-1.037249` vs `-0.54240130`. 


```r
germ.gnlrim <-
  gnlrim(y=ybind,
         mu = ~ plogis(Intercept + 
                         x1*extract + 
                         x2*seed73 + 
                         x3*intx + 
                         rand),
         pmu = c(Intercept=0,extract=0,seed73=0,intx=0),
         pmix=c(alp1_eq_alp2=20),
         p_uppb = c(  1,   2,  1,  1, 30),
         p_lowb = c( -2,  -1, -1, -1, 0.2),
         distribution="binomial",
         nest=plate.id,
         random="rand",
         mixture="beta-HGLM", ## NEW!
         ooo=TRUE,
         compute_hessian = FALSE,
         compute_kkt = FALSE,
         trace=1,
         method='nlminb'
  )
```

```
## [1] 5
##    Intercept      extract       seed73         intx alp1_eq_alp2 
##            0            0            0            0           20 
## [1] 105.1805
## fn is  fn 
## Looking for method =  nlminb 
## Function has  5  arguments
## par[ 1 ]:  -2   <? 0   <? 1     In Bounds  
## par[ 2 ]:  -1   <? 0   <? 2     In Bounds  
## par[ 3 ]:  -1   <? 0   <? 1     In Bounds  
## par[ 4 ]:  -1   <? 0   <? 1     In Bounds  
## par[ 5 ]:  0.2   <? 20   <? 30     In Bounds  
## Analytic gradient not made available.
## Analytic Hessian not made available.
## Scale check -- log parameter ratio= 0   log bounds ratio= 1.173186 
## Method:  nlminb 
##   0:     105.18050:  0.00000  0.00000  0.00000  0.00000  20.0000
##   1:     83.118771: -0.411568 0.0176480 -0.182449 -0.0579764  19.9992
##   2:     71.615196: -0.397623 0.465302 -0.189915 0.0175473  19.9981
##   3:     68.849150: -1.12431 0.932748 -0.443211 -0.103486  19.9963
##   4:     57.306469: -0.910638  1.23649 -0.202672 -0.206293  19.9947
##   5:     54.872043: -0.986377  1.26815 -0.0188867 -0.613507  19.9916
##   6:     54.812823: -1.04228  1.24899 0.0356366 -0.621323  19.9911
##   7:     54.773386: -1.03510  1.28044 0.107810 -0.637923  19.9903
##   8:     54.630094: -1.03607  1.30032 0.0993523 -0.715737  19.9885
##   9:     54.619972: -1.07010  1.31373 0.149612 -0.767008  19.9827
##  10:     54.606723: -1.05495  1.32540 0.154010 -0.806907  19.9686
##  11:     54.602594: -1.05667  1.32415 0.130489 -0.776576  19.9575
##  12:     54.601299: -1.05539  1.31624 0.136687 -0.777549  19.9570
##  13:     54.600967: -1.05615  1.31904 0.138874 -0.781279  19.9483
##  14:     54.600609: -1.05483  1.31977 0.136954 -0.781582  19.9204
##  15:     54.600134: -1.05486  1.32082 0.137137 -0.782596  19.8797
##  16:     54.594799: -1.05446  1.32817 0.137526 -0.789655  19.3262
##  17:     54.583898: -1.05395  1.33765 0.137912 -0.798797  18.1044
##  18:     54.536645: -1.05233  1.36214 0.138092 -0.822597  13.6860
##  19:     54.501549: -1.05426  1.36679 0.137611 -0.829537  12.3374
##  20:     53.615308: -1.06616  1.40697 0.134271 -0.884521  1.54857
##  21:     53.599527: -1.06644  1.40731 0.134160 -0.885248  1.41363
##  22:     53.562982: -1.08221  1.38819 0.124948 -0.890580  1.41288
##  23:     53.550610: -1.07212  1.38548 0.126469 -0.886293  1.38841
##  24:     53.529651: -1.06636  1.37505 0.116778 -0.875162  1.24171
##  25:     53.511425: -1.03567  1.33780 0.0708442 -0.832114  1.11958
##  26:     53.509124: -1.03522  1.32476 0.0749947 -0.814325  1.21273
##  27:     53.508508: -1.03756  1.32961 0.0761466 -0.820161  1.18082
##  28:     53.508499: -1.03699  1.32989 0.0748661 -0.820428  1.17969
##  29:     53.508495: -1.03712  1.32969 0.0751627 -0.820155  1.17895
##  30:     53.508495: -1.03712  1.32969 0.0751654 -0.820146  1.17915
##  31:     53.508495: -1.03712  1.32970 0.0751612 -0.820142  1.17913
## Post processing for method  nlminb 
## Successful convergence! 
## Save results from method  nlminb 
## $par
##    Intercept      extract       seed73         intx alp1_eq_alp2 
##  -1.03711927   1.32969519   0.07516125  -0.82014188   1.17913289 
## 
## $message
## [1] "relative convergence (4)"
## 
## $convcode
## [1] 0
## 
## $value
## [1] 53.5085
## 
## $fevals
## function 
##       43 
## 
## $gevals
## gradient 
##      190 
## 
## $nitns
## [1] 31
## 
## $kkt1
## [1] NA
## 
## $kkt2
## [1] NA
## 
## $xtimes
## user.self 
##     2.926 
## 
## Assemble the answers
```

```r
## compare -- pretty close!  except the intercept
rbind(
  hglm=as.numeric(germ.hglm$fixef),
  gnlrim.rand=germ.gnlrim[1:4]
)
```

```
##              Intercept  extract     seed73       intx
## hglm        -0.5424013 1.339159 0.07650678 -0.8256701
## gnlrim.rand -1.0371193 1.329695 0.07516125 -0.8201419
```

I realized that while putting `rand ~ Beta(alp1_eq_alp2,alp1_eq_alp2)` was correct, it really needed to be logit linked.  To test the waters I put a `log(rand)`:



```r
germ.gnlrim.logrand <-
 gnlrim(y=ybind,
         mu = ~ plogis(Intercept + 
                         x1*extract + 
                         x2*seed73 + 
                         x3*intx + 
                         log(rand)  ## try a log.
                       ),
         pmu = c(Intercept=0,extract=0,seed73=0,intx=0),
         pmix=c(alp1_eq_alp2=2),
         p_uppb = c(  1,   2,  1,  1, 20),
         p_lowb = c( -2,  -1, -1, -1, 0.2),
         distribution="binomial",
         nest=plate.id,
         random="rand",
         mixture="beta-HGLM",
         ooo=TRUE,
         compute_hessian = FALSE,
         compute_kkt = FALSE,
         trace=0,
         method='nlminb'
  )
```

```
## [1] 5
##    Intercept      extract       seed73         intx alp1_eq_alp2 
##            0            0            0            0            2 
## [1] 98.54433
```

```r
## log.rand not quite what we wanted
rbind(
  hglm=as.numeric(germ.hglm$fixef),
  gnlrim.rand=germ.gnlrim[1:4],
  gnlrim.log.rand= germ.gnlrim.logrand[1:4]
)
```

```
##                  Intercept  extract     seed73       intx
## hglm            -0.5424013 1.339159 0.07650678 -0.8256701
## gnlrim.rand     -1.0371193 1.329695 0.07516125 -0.8201419
## gnlrim.log.rand  0.1751775 1.331796 0.09617131 -0.8118160
```

So naturally I would just type `log(rand/(1-rand))` and everything would work right?

Right?


```r
germ.gnlrim.logitrand <-
 gnlrim(y=ybind,
         mu = ~ plogis(Intercept + 
                         x1*extract + 
                         x2*seed73 + 
                         x3*intx + 
                         log(rand/(1-rand)) ## logit
                       ),
         pmu = c(Intercept=0,extract=0,seed73=0,intx=0),
         pmix=c(alp1_eq_alp2=2),
         p_uppb = c(  1,   2,  1,  1, 20),
         p_lowb = c( -2,  -1, -1, -1, 0.2),
         distribution="binomial",
         nest=plate.id,
         random="rand",
         mixture="beta-HGLM",
         ooo=TRUE,
         compute_hessian = FALSE,
         compute_kkt = FALSE,
         trace=0,
         method='nlminb'
  )
# 
# Error in gnlrim(y = ybind, mu = ~plogis(Intercept + x1 * extract + x2 *  : 
#   Likelihood returns Inf or NAs: invalid initial values, wrong model, or probabilities too small to calculate
# In addition: There were 50 or more warnings (use warnings() to see the first 50)
# > warnings()
# Warning messages:
# 1: In log(rand/(1 - rand)) : NaNs produced
# 2: In log(rand/(1 - rand)) : NaNs produced
```

Swing and a miss!

I thought I was stuck but then started skimming Wikipedia for Related Distributions and transformations involving the Beta distribution.  We were in luck!
I learned that if u~beta, then u/(1-u) is betaprime [(thanks to Wikipedia)](https://en.wikipedia.org/wiki/Beta_prime_distribution). If we can get `rand` to be betaprime, then we can take the log of that.  So I found `extraDistr::dbetapr()` and added it into the `gnlrim` functionality by specifying `mixture="betaprime"`.  Going forward in this exercise, `rand` has a betaprime distribution and taking the log of it should be in the spirit of the Binomial-Beta HGLM.  Since betaprime has the [0,infty] domain, we use intb to do the integration (this is a note to self).

To aid our investigation, we can use another feature of `gnlrim` when `method="nlminb"`:  provide upper and lower bounds and put them so tightly we effectively lock down the estimates.

Let's just go ahead and lock down the coefficients to those we got from `hglm::hglm` and see what the corresponding shape parameters `alp1_eq_alp2` would be for the beta mixture distribution.  We do a little algebra and add a 5th column onto our summary table to bring into the picture what the shape parameter estimates have been for each fitting:


```r
ldhc <- lock.down.hglm.coef <- as.numeric(germ.hglm$fixef)

gnlrim.logit.rand.ldhc <-
  gnlrim(y=ybind,
         mu = ~ plogis(Intercept + 
                         x1*extract + 
                         x2*seed73 + 
                         x3*intx + 
                         log(rand) ## log(betaprime)
                       ),
         pmu = c(Intercept=ldhc[1],extract=ldhc[2],seed73=ldhc[3],intx=ldhc[4]),
         pmix=c(alp1_eq_alp2=20),
         p_uppb = c(  ldhc,  100),
         p_lowb = c(  ldhc,  0),
         distribution="binomial",
         nest=plate.id,
         random="rand",
         mixture="betaprime", ## NEW!
         ooo=TRUE,
         compute_hessian = FALSE,
         compute_kkt = FALSE,
         trace=0,
         method='nlminb'
  )
```

```
## [1] 5
##    Intercept      extract       seed73         intx alp1_eq_alp2 
##  -0.54240130   1.33915914   0.07650678  -0.82567005  20.00000000 
## [1] 54.03772
```

```r
## Lee and Nelder 1996 JRSS-B
##   from section 6.3, page 640  
## the dispersion should be:
1/(2*gnlrim.logit.rand.ldhc[5]+1)
```

```
##        alp1_eq_alp2
## nlminb   0.01401273
```

```r
## which doesn't match up with hglm::hglm():
(disp.hglm.seeds <- 0.0244)
```

```
## [1] 0.0244
```

```r
(alpha.hglm.seeds <- 0.5*(1/disp.hglm.seeds-1)) 
```

```
## [1] 19.9918
```

```r
rbind(
  hglm=c(as.numeric(germ.hglm$fixef),alpha.hglm.seeds),
  gnlrim.rand=germ.gnlrim[1:5],
  gnlrim.log.rand= germ.gnlrim.logrand[1:5],
  gnlrim.logit.rand.ldhc= gnlrim.logit.rand.ldhc[1:5]
)
```

```
##                         Intercept  extract     seed73       intx alp1_eq_alp2
## hglm                   -0.5424013 1.339159 0.07650678 -0.8256701    19.991803
## gnlrim.rand            -1.0371193 1.329695 0.07516125 -0.8201419     1.179133
## gnlrim.log.rand         0.1751775 1.331796 0.09617131 -0.8118160     9.576689
## gnlrim.logit.rand.ldhc -0.5424013 1.339159 0.07650678 -0.8256701    35.181828
```

I don't quite know what's going on in the first and last row of the table above -- I would have expected the gap to be closer than `35.18` vs `19.99` for the alpha=alpha1=alpha2 of the beta distribution.  

So let's go the opposite direction: lock down the shape parameter and see how different the coefficients are...



```r
gnlrim.logit.rand.ldha <-
  gnlrim(y=ybind,
         mu = ~ plogis(Intercept + x1*extract + x2*seed73 + x3*intx + log(rand)),
         pmu = c(Intercept=0,extract=0,seed73=0,intx=0),
         pmix=c(alp1_eq_alp2=alpha.hglm.seeds),
         p_uppb = c(  1,   2,  1,  1, alpha.hglm.seeds),
         p_lowb = c( -2,  -1, -1, -1, alpha.hglm.seeds),
         distribution="binomial",
         nest=plate.id,
         random="rand",
         mixture="betaprime",
         ooo=TRUE,
         compute_hessian = FALSE,
         compute_kkt = FALSE,
         trace=0,
         method='nlminb'
  )
```

```
## [1] 5
##    Intercept      extract       seed73         intx alp1_eq_alp2 
##       0.0000       0.0000       0.0000       0.0000      19.9918 
## [1] 68.74008
```

```r
rbind(
hglm=c(as.numeric(germ.hglm$fixef),alpha.hglm.seeds),
gnlrim.rand=germ.gnlrim[1:5],
gnlrim.log.rand= germ.gnlrim.logrand[1:5],
gnlrim.logit.rand.ldhc= gnlrim.logit.rand.ldhc[1:5],
gnlrim.logit.rand.ldha= gnlrim.logit.rand.ldha[1:5]
)
```

```
##                         Intercept  extract     seed73       intx alp1_eq_alp2
## hglm                   -0.5424013 1.339159 0.07650678 -0.8256701    19.991803
## gnlrim.rand            -1.0371193 1.329695 0.07516125 -0.8201419     1.179133
## gnlrim.log.rand         0.1751775 1.331796 0.09617131 -0.8118160     9.576689
## gnlrim.logit.rand.ldhc -0.5424013 1.339159 0.07650678 -0.8256701    35.181828
## gnlrim.logit.rand.ldha -0.5482479 1.354207 0.07470074 -0.8335489    19.991803
```

The coefficients of the last row and first row are pretty similar, I suppose.

Let's not lock any thing down and let gnlrim try to hit this HGLM-style model -- we'll put it on the top row of the summary table to compare with the hglm output.


```r
binomial.beta.gnlrim <-
  gnlrim(y=ybind,
         mu = ~ plogis(Intercept + x1*extract + x2*seed73 + x3*intx + log(rand)),
         pmu = c(Intercept=0,extract=0,seed73=0,intx=0),
         pmix=c(alp1_eq_alp2=alpha.hglm.seeds),
         p_uppb = c(  1,   2,  1,  1, 1e02),
         p_lowb = c( -2,  -1, -1, -1, 1e-3),
         distribution="binomial",
         nest=plate.id,
         random="rand",
         mixture="betaprime",
         ooo=TRUE,
         compute_hessian = FALSE,
         compute_kkt = FALSE,
         trace=0,
         method='nlminb'
  )
```

```
## [1] 5
##    Intercept      extract       seed73         intx alp1_eq_alp2 
##       0.0000       0.0000       0.0000       0.0000      19.9918 
## [1] 68.74008
```

```r
print(
  rbind(
    binomial.beta.gnlrim = binomial.beta.gnlrim[1:5],
    hglm=c(as.numeric(germ.hglm$fixef),alpha.hglm.seeds),
    gnlrim.rand=germ.gnlrim[1:5],
    gnlrim.log.rand= germ.gnlrim.logrand[1:5],
    gnlrim.logit.rand.ldhc= gnlrim.logit.rand.ldhc[1:5],
    gnlrim.logit.rand.ldha= gnlrim.logit.rand.ldha[1:5]
  ),
  digits=4)
```

```
##                        Intercept extract  seed73    intx alp1_eq_alp2
## binomial.beta.gnlrim     -0.5486   1.337 0.09731 -0.8103       36.498
## hglm                     -0.5424   1.339 0.07651 -0.8257       19.992
## gnlrim.rand              -1.0371   1.330 0.07516 -0.8201        1.179
## gnlrim.log.rand           0.1752   1.332 0.09617 -0.8118        9.577
## gnlrim.logit.rand.ldhc   -0.5424   1.339 0.07651 -0.8257       35.182
## gnlrim.logit.rand.ldha   -0.5482   1.354 0.07470 -0.8335       19.992
```

<!-- THIS ISNOT TRUE.  LOOKS LIKE YOU NEED OVERDISPERSED BINOMAIL n=1 which is nonsensical -->
<!-- # Upon reading the 1996 paper more closely, I think they did a binomial-normal GLMM for the middle column of Table 2 -- we can do that by quickly changing mixture distributions and using identity link for rand: -->
 

This is what Clayton and Breslow 1993 fit for germination, straight up ML:

Ahhhh!  ML.  That's what `gnlrim` does.  Does gnlrim need REML?  [Ben Bolker doesn't seem to think so.](https://stats.stackexchange.com/q/49039/35034)

[BIAS intercept for rare events. see page 700](https://gking.harvard.edu/files/baby0s.pdf#Page=11)


```r
binomial.norm.glmm <-
  gnlrim(y=ybind,
         mu = ~ plogis(Intercept + x1*extract + x2*seed73 + x3*intx + rand),
         pmu = c(Intercept=0,extract=0,seed73=0,intx=0),
         pmix=c(alp1_eq_alp2=alpha.hglm.seeds),
         p_uppb = c(  1,   2,  1,  1, 1e02),
         p_lowb = c( -2,  -1, -1, -1, 1e-3),
         distribution="binomial",
         nest=plate.id,
         random="rand",
         mixture="normal-var",
         ooo=TRUE,
         compute_hessian = FALSE,
         compute_kkt = FALSE,
         trace=0,
         method='nlminb'
  )
```

```
## [1] 5
##    Intercept      extract       seed73         intx alp1_eq_alp2 
##       0.0000       0.0000       0.0000       0.0000      19.9918 
## [1] 89.12256
```

```r
print(
  rbind(
    binomial.beta.gnlrim = binomial.beta.gnlrim[1:5],
    hglm=c(as.numeric(germ.hglm$fixef),alpha.hglm.seeds),
    gnlrim.rand=germ.gnlrim[1:5],
    gnlrim.log.rand= germ.gnlrim.logrand[1:5],
    gnlrim.logit.rand.ldhc= gnlrim.logit.rand.ldhc[1:5],
    gnlrim.logit.rand.ldha= gnlrim.logit.rand.ldha[1:5],
    binomial.norm.glmm= binomial.norm.glmm[1:5]
  ),
  digits=4)
```

```
##                        Intercept extract  seed73    intx alp1_eq_alp2
## binomial.beta.gnlrim     -0.5486   1.337 0.09731 -0.8103     36.49794
## hglm                     -0.5424   1.339 0.07651 -0.8257     19.99180
## gnlrim.rand              -1.0371   1.330 0.07516 -0.8201      1.17913
## gnlrim.log.rand           0.1752   1.332 0.09617 -0.8118      9.57669
## gnlrim.logit.rand.ldhc   -0.5424   1.339 0.07651 -0.8257     35.18183
## gnlrim.logit.rand.ldha   -0.5482   1.354 0.07470 -0.8335     19.99180
## binomial.norm.glmm       -0.5484   1.337 0.09699 -0.8105      0.05581
```



I'll have to dig into this more at a later date.  But at the end of the day this little exercise has led to:

  * A blog post
  * Learning about the betaprime distribution
  * implementing betaprime and beta-HGLM in gnlrim
  * getting a little more familiar with HGLM
