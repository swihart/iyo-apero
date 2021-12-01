---
title: "growth"
subtitle: "Multivariate Normal and Elliptically-Contoured Repeated Measurements Models"
excerpt: "This is the CRAN maintained version of Jim Lindsey's `growth`."
date: 2017-10-14
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
  url: https://github.com/swihart/growth
- icon: r-project
  icon_pack: fab
  name: CRAN
  url: https://cran.r-project.org/web/packages/growth/index.html
---

I am maintaining Jim Lindsey's `growth` on CRAN which contains functions for fitting various normal theory (growth curve) and elliptically-contoured repeated measurements models with ARMA and random effects dependence.

---


Accessed from the [R] help pipermail on 2021-11-27, but [written on 1999-11-25](https://stat.ethz.ch/pipermail/r-help/1999-November/005421.html):

## [R] gnls

> **Jim Lindsey**
>
> *Thu Nov 25 17:00:25 CET 1999*
>
> Doug,
>
>   I have been attempting to learn a little bit about nlme without too
> much documentation except the online help. The Latex file in the nlme
> directory looks interesting but uses packages that I do not have so
> that I have not been able to read it.
>   I have run the example from gnls to compare it with the results I
> get from my libraries (code below - I have not included output as it
> is rather long and easy to reproduce).
>   For the model with variance a power function of the mean (fm1), I
> get very similar results with a slightly better log likelihood fit.
>   For the AR(1) (fm2), I get a very much better fit using a continuous
> AR(1) with my elliptic function. At first, looking at the
> autocorrelation produced, I thought this was because gnls was
> erroneously assuming a discrete AR with equally-spaced unit time
> intervals when the data are in fact unequally space. (Note that, in
> contrast to dataframes, this kind of error is impossible with my data
> objects because the times must be associated with the response values
> for such models to be fitted.) So I tricked my data objects and
> functions into fitting the discrete time AR. The resulting model fits
> a lot worse than the (correct) CAR but still very much better than that
> from gnls. Something else appears to be wrong but I am not sure what.
>   Fitting the AR(1) with gnls is also extremely slow: that one model
> takes longer than the time fitting all of the others together in the
> file below.
>   I shall continue exploring nlme... Jim
>
> ---------------------------------------------------------------------------

````
library(nlme)
library(growth)

#example from gnls
data(Soybean)
# variance increases with a power of the absolute fitted values
summary(fm1 <- gnls(weight ~ SSlogis(Time, Asym, xmid, scal), Soybean,
            weights = varPower()))
# errors follow an auto-regressive process of order 1
summary(fm2 <- gnls(weight ~ SSlogis(Time, Asym, xmid, scal), Soybean,
            correlation = corAR1()))

# lines commented out are for fitting a discrete time AR(1)

# construct data objects from dataframe
soybean <- list()
#ctimes <- list()
plot <- variety <- year <- NULL
for(i in as.character(unique(Soybean[1]))){
	soybean <- c(soybean,list(as.matrix(Soybean[5:4][Soybean[1]==i,])))
# for discrete time AR(1), correct times must be stored as a
#time-varying covariate
#	soybean <- c(soybean,list(cbind(Soybean[5][Soybean[1]==i],
#		1:length(Soybean[5][Soybean[1]==i]))))
#	ctimes <- c(ctimes,list(as.matrix(Soybean[4][Soybean[1]==i])))
	plot <- c(plot,Soybean[1][Soybean[1]==i][1])
	variety <- c(variety,Soybean[2][Soybean[1]==i][1])
	year <- c(year,Soybean[3][Soybean[1]==i][1])}
# unfortunately, category names of factor variables were lost here by c()
data <- rmna(restovec(soybean),
	ccov=tcctomat(data.frame(plot,variety=variety-1,
	year=as.factor(year)),dataframe=F))
# for discrete time AR(1)
#data <- rmna(restovec(soybean),
#	ccov=tcctomat(data.frame(plot,variety=variety-1,
#	year=as.factor(year)),dataframe=F),tvc=tvctomat(ctimes,name="ctimes"))
#rm(Soybean,soybean,plot,variety,year,ctimes)
rm(Soybean,soybean,plot,variety,year)

# builtin four-parameter generalized logistic curve
elliptic(data,model="logistic",preg=c(-1,3,-10,3))
# with AR(1)
elliptic(data,model="logistic",preg=c(-1,3,-10,3),par=0.8)

# standard logistic growth curve
elliptic(data,model=~Asym/(1+exp((xmid-times)/scal)),preg=c(20,50,10))

# when variance depends on mean, must use functions instead of formulae
# same logistic growth curve
mu <- function(p) p[1]/(1+exp((p[2]-times)/p[3]))
elliptic(data,model=mu,preg=c(17,50,8))
# variance increases with power of absolute fitted values: model fm1
# note: function for log(variance) is fitted
shape <- function(p,mu) p[1]*log(abs(mu))+p[2]
elliptic(data,model=mu,preg=c(17,50,8),varfn=shape,pvar=c(1,2),shfn=T)

# CAR(1): model fm2
elliptic(data,model=~Asym/(1+exp((xmid-times)/scal)),preg=c(17,50,8),par=0.5)
# fit the discrete time AR(1)
#elliptic(data,model=~Asym/(1+exp((xmid-ctimes)/scal)),preg=c(17,50,8),par=0.5)
# CAR(1) and variance depending on mean
elliptic(data,model=mu,preg=c(19,55,8),varfn=shape,pvar=c(1,2),shfn=T,par=0.95)

# fix power of the mean at 2 in variance function
shape2 <- function(p,mu) 2*log(abs(mu))+p[1]
elliptic(data,model=mu,preg=c(19,55,8),varfn=shape2,pvar=-2,shfn=T,par=0.95)
# dependence of the variance on time with the same function as the mean but
# different parameters
elliptic(data,model=~Asym/(1+exp((xmid-times)/scal)),preg=c(17,50,8),
	varfn=~log(Asym/(1+exp((xmid-times)/scal))),pvar=c(3,10,1),par=0.95)
# random intercept?
elliptic(data,model=mu,preg=c(17,51,7.5),varfn=shape,pvar=c(1.8,-2),
	shfn=T,par=0.9,pre=1)

# check if thick tails
# multivariate Student t
elliptic(data,model=mu,preg=c(17,51,7.5),varfn=shape,pvar=c(1.8,-2),shfn=T,
	par=0.9,dist="Student",pell=1)
# multivariate power exponential
elliptic(data,model=mu,preg=c(17,51,7.5),varfn=shape,pvar=c(1.8,-2),shfn=T,
	par=0.9,dist="power exp",pell=1)

# the following could be more easily done with formulae if the variance
# did not depend on the mean
#asymptote depends on variety?
mu2 <- function(p) (p[1]+p[4]*variety)/(1+exp((p[2]-times)/p[3]))
elliptic(data,model=mu2,preg=c(17,52,7.5,0),varfn=shape,pvar=c(1.8,-2.2),
	shfn=T,par=0.9,dist="Student",pell=6.5)
# also on year?
mu3 <- function(p) (p[1]+p[4]*variety+p[5]*year2+p[6]*year3)/
	(1+exp((p[2]-times)/p[3]))
elliptic(data,model=mu3,preg=c(14.5,52,7.5,4.5,0,0),varfn=shape,
	pvar=c(1.8,-2.2),shfn=T,par=0.9,dist="Student",pell=8)
# etc.
````

---
