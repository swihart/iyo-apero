---
title: "gnlm"
subtitle: "Generalized Nonlinear Regression Models"
excerpt: "This is the CRAN maintained version of Jim Lindsey's `gnlm`."
date: 2017-10-16
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
  url: https://github.com/swihart/gnlm
- icon: r-project
  icon_pack: fab
  name: CRAN
  url: https://cran.r-project.org/web/packages/gnlm/index.html
---

I am maintaining Jim Lindsey's `gnlm` on CRAN. Think "glm", but instead of having a predictor $$\beta_0 + \beta_1 X$$ you can have $beta_0 + \exp(\beta_1 X_1)/(\beta_2 X_2 + \beta_3)$

---

$$x = {-b \pm \sqrt{b^2-4ac} \over 2a}.$$
  
Accessed from the [R] help pipermail on 2021-11-27, but [written on 2001-05-29](https://stat.ethz.ch/pipermail/r-help/2001-May/013037.html):

## GLMMs with Gauss-Hermite quadrature

> Jim Lindsey
>
> *Tue May 29 11:37:07 CEST 2001*
>
> There has recently been some discussion of GLMMs on this list.
> Unfortunately, I deleted the messages so that this is from memory.
>
> The original question was about doing a homework problem concerning
> mixed logistic regression in R for a course based on SAS. Clearly, the
> R function to use is my glmm because it uses essentially the same
> algorithm as SAS (the SAS Gauss-Hermite used an adaptive method that
> can reduce the number of quadrature points for the same precision).
>
> Although I have made available this function, I never recommend its
> use because I think this type of model is very artificial, except
> possibly in some animal breeding situations. I have never been able to
> understand why GLMMs, with their normal mixing distribution, are
> popular. If someone must use mixed logistic regression in this sense,
> I strongly recommend using a specialized program such as Sabre or
> Egret for a variety of reasons.
>
> At least two points came up in the discussion that I would like to
> address: approximations and restrictions.
>
> Restrictions
>
> The main restrictions to glmm come from glm itself: 
>
>  1) linear regression and 
>  2) exponential family conditional distribution plus 
>  3) the fact that the normal mixing distribution is imposed on them.
>
> The latter is typical of the sort of general models that statisticians
> love to develop that have no real mechanistic interpretation.
> 
> Troels pointed out that I have more general functions available that
> lift these restrictions. gnlmm removes the two imposed by glm. Any
> nonlinear model can be fitted with a wide variety of conditional
> distributions. However, the mixing distribution is still normal and in
> addition, in nonlinear models, a random "intercept" may often be
> unnatural. However, I also have gnlmix which removes all restrictions.
> It has nonlinear regression with a wide variety of conditional
> distributions where any one nonlinear parameter can be random with a
> mixing distribution chosen from a wide selection. Romberg integration is
> used so that it is essentially exact, if rather slow. It would be
> simple to extend it to say two nonlinear random parameters but time
> would quickly become rather exhorbitant.
> 
> Approximations
> 
> When discussing GLMMs using Gauss-Hermite integration, the question of
> approximations is essentially a red herring. No matter the number of
> quadrature points, the likelihood is always exact (as exact as any
> likelihood can be on a digital computer). It is a finite mixture. The
> approximation question arises in the sense that this finite mixture is
> more or less close to a Gaussian mixing distribution, which is a
> completely artificial choice in the first place. It is quite possible
> for the model with very few quadrature points to fit better than one
> with sufficient for a very close approximation to the normal mixing
> distribution, indicating that normal mixing is not a good choice.
> 
> It is false to say that the properties of this approximation, in the
> latter sense are unknown. GLMMs using Gauss-Hermite go back at least
> to an unpublished tech report by Don Pierce in the mid 70s and the
> published paper by John Hinde in 1982. Since then, there is a vast
> literature on the subject of the approximation in the second sense
> above, especially for the model in question, mixed logistic
> regression, including work by Alan Agresti, Murray Aitkin, David
> Brillinger, Bruce Lindsay, etc.  (There is also another literature on
> approximations replacing Gauss-Hermite, such as Breslow and Clayton.)
> The most recent published reference that I am aware of is earlier this
> year, but I have refereed others that are not yet in print. 15 to 20
> quadrature points gives an extremely close numerical approximation to
> the normal mixing distribution for most data sets, for what that is
> worth.
>
>   Jim



---
