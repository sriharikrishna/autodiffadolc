# Introduction


Derivatives are required in many contexts:
* Optimization,
* Sensitivity analysis,
* Uncertainty quantification, and 
* Parameter Estimation.

The radolc package is an interface to ADOL-C -- a C++ library that facilitates the evaluation of 
first and higher derivatives of vector functions that are defined by computer programs. ADOL-C can compute
gradients, the Jacobian matrix, the Hessian matrix, Jacobian × vector products, and Hessian × vector
products.

This document serves as a brief introduction to radolc's interface calls to ADOL-C drivers and demonstrates how to prepare your code for differentiation. It is based on a similar document for ADOL-C itself [4]. A description on how the interface was created is provided in [2]. [1] and [3] are good resources on automatic differentiation (also popularly called autodiff).

# Installation within R
```r
devtools::install_github("https://github.com/sriharikrishna/radolc.git", build=TRUE, build_opts ="")
```

# Phase 1: Preparing a Code Segment for Differentiation

One must follow a four step process to prepare the code for differentiation with radolc. The steps are outlined below. 

1. Use the library `radolc`.


```r
library(radolc)

#Always detach the package
detach(package:radolc, unload=TRUE)
```

2. Define the region that has to be differentiated. That is, mark the active section with the two function calls `trace_on` and `trace_off`.


```r
library(radolc)

trace_on(1)   #Start of active section
#....            
trace_off(1)  #and its end

#Always detach the package
detach(package:radolc, unload=TRUE)               
```

3. Identify all the independent variables and the dependent variables and mark them in the active section.


```r
library(radolc)

trace_on(1)
x <- c(adouble(1.0),adouble(2.0))
badouble_declareIndependent(x)
#... calculations.
badouble_declareDependent(y)
trace_off(1);

#Always detach the package
detach(package:radolc, unload=TRUE) 
```

4. Place all calculation or a call to the calculation between the declarations.


```r
library(radolc)

fr <- function(x) {   ## Rosenbrock Banana function
    x1 <- x[[1]]
    x2 <- x[[2]]
    y <- 100 * (x2 - x1 * x1)* (x2 - x1 * x1) + (1 - x1)*(1 - x1)
    y }

trace_on(1)
x <- c(adouble(1.0),adouble(2.0))
badouble_declareIndependent(x)
y <- fr(x)
badouble_declareDependent(y)
trace_off(1)

#Always detach the package
detach(package:radolc, unload=TRUE) 
```

# Phase 2: Computing the derivatives

Derivatives are computed by invoking an appropriate driver provided by `radolc`. `gradient`, `hessian`, `hess_vec`, and `hess_mat`are appropriate when the computation has a single output i.e., it is scalar valued. They are explained below.

## Derivatives for functions with single output

### Gradient
`gradient` computes the derivatives of the output of a scalar valued function with respect to its input(s). It uses the reverse mode of automatic differentiation.

```r
library(radolc)

fr <- function(x) {   ## Rosenbrock Banana function
    x1 <- x[[1]]
    x2 <- x[[2]]
    y <- 100 * (x2 - x1 * x1)* (x2 - x1 * x1) + (1 - x1)*(1 - x1)
    y }

tag <- 1
trace_on(tag)
x <- c(adouble(1.0),adouble(2.0))
badouble_declareIndependent(x)
y <- fr(x)

badouble_declareDependent(y)
trace_off()
#gradient(tag,n,x,g)
# tag: integer, tape identification
# n  : integer, number of independents n and m = 1
# x[n]: independent vector x
# g[n] :resulting gradient \gradF(x)

x=c(1,2)
g <- c(0.0,0.0)
gradient(1,2,x,g)

#Always detach the package
detach(package:radolc, unload=TRUE) 
```

### Hessian
`hessian` computes the lower triangle of the second order derivatives of the output of a scalar valued function with respect to its input(s). Internally, it simply calls `hess_vec` multiple times.

```r

rm(list=ls())

library('radolc')

#--- testing ADOLC's hessian
fr <- function(x) {   ## Rosenbrock Banana function
  x1 <- x[1]
  x2 <- x[2]
  y <- 100 * (x2 - x1 * x1)* (x2 - x1 * x1) + (1 - x1)*(1 - x1)
  y }

trace_on(1)
x <- adolc_createList(2,2.0)
badouble_declareIndependent(x)
y <- fr(x)
badouble_declareDependent(y)
trace_off()

xx <- c(1.0,2.0)
yy <- matrix(rep(0.0,4), nrow = 2, ncol = 2)
hessian(1,2,xx,yy);
#hessian(tag,n,x,H)
# tag: integer, tape identification
# n  : integer, number of independents n and m = 1
# x[n]: independent vector x
# double H[n][n]: resulting Hessian matrix \nabla^2F(x)
print(yy)     

#Always detach the package
detach(package:radolc, unload=TRUE) 

```

### Hessian Vector Product
`hes_vec` computes the product of the second order derivatives of the output of a scalar valued function with respect to its input(s) on a vector. It uses the reverse mode of automatic differentiation.


```r
rm(list=ls())

library('radolc')

#--- testing ADOLC's hessian vector product
fr <- function(x) {   ## Rosenbrock Banana function
  x1 <- x[1]
  x2 <- x[2]
  y <- 100 * (x2 - x1 * x1)* (x2 - x1 * x1) + (1 - x1)*(1 - x1)
  y }

trace_on(1)
x <- adolc_createList(2,2.0)
badouble_declareIndependent(x)
y <- fr(x)
badouble_declareDependent(y)
trace_off()

xx <- c(1.0,2.0)
vv <- c(3.0,5.5)
yy <- c(0.0,0.0)
hess_vec(1,2,xx,vv,yy) # result z = \nambla^2F(x)v
#hess_vec(tag,n,x,v,z)
# tag: integer, tape identification
# n  : integer, number of independents n and m = 1
# x[n]: independent vector x
# v[n]: vector
# z[n]: resulting Hessian vector product

print(yy)     

#Always detach the package
detach(package:radolc, unload=TRUE) 
```

### Hessian Matrix Product
`hes_mat` computes the product of the second order derivatives of the output of a scalar valued function with respect to its input(s) on a matrix. It uses the reverse mode of automatic differentiation.

```r
rm(list=ls())

library('radolc')

#--- testing ADOLC's Hessian matrix product
fr <- function(x) {   ## Rosenbrock Banana function
  x1 <- x[1]
  x2 <- x[2]
  y <- 100 * (x2 - x1 * x1)* (x2 - x1 * x1) + (1 - x1)*(1 - x1)
  y }

trace_on(1)
x <- adolc_createList(2,2.0)
badouble_declareIndependent(x)
y <- fr(x)
badouble_declareDependent(y)
trace_off()

xx <- c(1.0,2.0)
V <- matrix(c(2.2, 1.4, 3.4, 7.4), nrow = 2, ncol = 2)
W <- matrix(rep(0.0,4), nrow = 2, ncol = 2)
hess_mat(1,2,2,xx,V,W) 
# hess_mat(tag, n, q, x[n], V[n][q], W[n][q]) # result z = \nambla^2F(x)v
# tag: integer, tape identification
# n  : integer, number of independents n and m = 1
# q  : dimension of matrix (n*q)
# x[n]: independent vector x
# V[n][q]: matrix
# W[n][q]: resulting Hessian matrix product

print(W)     

#Always detach the package
detach(package:radolc, unload=TRUE) 
```


## Derivatives for computation with multiple outputs


### Jacobian
`jacobian` computes the derivatives of the output of a function that takes one or more inputs and produces one or more outputs. It uses the forward mode of automatic differentiation. 


```r

rm(list=ls())

library('radolc')

#--- testing ADOLC's jacobian

fr <- function(x) {
  x1 <- x[[1]]
  x2 <- x[[2]]
  #Use create list to create adouble objects
  y<-adolc_createList(2,2.0)
  #y <- c(0.0,0.0)
  y[[1]] <- 100 * (x2 - x1 * x1)* (x2 - x1 * x1) + (1 - x1)*(1 - x1)
  y[[2]] <- 100 * (x2 - x1 * x1)+ (x2 - x1 * x1) * (1 - x1)*(1 - x1)
  y}

trace_on(1)
x <- adolc_createList(2,2.0)
badouble_declareIndependent(x)
y <- fr(x)
badouble_declareDependent(y)
trace_off()

xx <- c(1.0,2.0)
yy <- matrix(rep(0.0,4), nrow = 2, ncol = 2)
jacobian(1,2,2,xx,yy);
#jacobian(tag,m,n,x,J)
# tag: integer, tape identification
# m  : integer, number of dependent variables
# n  : integer, number of independent variables n
# x[n]: independent vector x
#J[m][n]; // resulting Jacobian F(x)
print(yy)     

#Always detach the package
detach(package:radolc, unload=TRUE) 
```

### Jacobian Vector Product
`jac_vec` computes the product of the first order derivatives of the output of a scalar valued function with respect to its input(s) on a vector. It uses the forward mode of automatic differentiation.

```r
rm(list=ls())

library('radolc')

#--- testing ADOLC's Jacobian vector product

fr <- function(x) {
  x1 <- x[[1]]
  x2 <- x[[2]]
  #Use create list to create adouble objects
  y<-adolc_createList(2,2.0)
  #y <- c(0.0,0.0)
  y[[1]] <- 100 * (x2 - x1 * x1)* (x2 - x1 * x1) + (1 - x1)*(1 - x1)
  y[[2]] <- 100 * (x2 - x1 * x1)+ (x2 - x1 * x1) * (1 - x1)*(1 - x1)
  y[[3]] <- 100 * (x2 + x1 * x1)+ (x2 + x1 * x1) * (1 + x1)*(1 - x1)
  y}

trace_on(1)
x <- adolc_createList(2,2.0)
badouble_declareIndependent(x)
y <- fr(x)
badouble_declareDependent(y)
trace_off()

xx <- c(1.0,2.0)
vv <- c(3.0,5.5)
yy <- c(0.0,0.0,0)
jac_vec(1,3,2,xx,vv,yy);
# jac_vec(tag,m,n,x,v,z) #result z = F′(x)v
# tag: integer, tape identification
# m  : integer, number of dependents m
# n  : integer, number of independents n
# x[n]: independent vector x
# v[n]: vector
# z[m]: resulting Jacobian vector product

print(yy)     

#Always detach the package
detach(package:radolc, unload=TRUE) 
```

### Vector Transpose Jacobian Product
`vec_jac` computes the action of a vector on the the first order derivatives of the output of a scalar valued function with respect to its input(s). It uses the reverse mode of automatic differentiation.

```r
rm(list=ls())

library('radolc')

#--- testing ADOLC's jacobian

fr <- function(x) {
  x1 <- x[[1]]
  x2 <- x[[2]]
  #Use create list to create adouble objects
  y<-adolc_createList(2,2.0)
  #y <- c(0.0,0.0)
  y[[1]] <- 100 * (x2 - x1 * x1)* (x2 - x1 * x1) + (1 - x1)*(1 - x1)
  y[[2]] <- 100 * (x2 - x1 * x1)+ (x2 - x1 * x1) * (1 - x1)*(1 - x1)
  y[[3]] <- 100 * (x2 + x1 * x1)+ (x2 + x1 * x1) * (1 + x1)*(1 - x1)
  y}

trace_on(1)
x <- adolc_createList(2,2.0)
badouble_declareIndependent(x)
y <- fr(x)
badouble_declareDependent(y)
trace_off()

xx <- c(1.0,2.0)
vv <- c(3.0,5.5,1,1)
yy <- c(0.0,0.0)
vec_jac(1,3,2,0,xx,vv,yy);
# vec_jac(tag,m,n,repeat,x,u,z) #result z = u^TF′(x)
# tag: integer, tape identification
# m  : integer, number of dependents m
# n  : integer, number of independents n
#repeat: ID of tape to reuse. Leave at 0 for no repetition
# x[n]: independent vector x
# u[m]: vector
# z[n]: resulting Jacobian vector product

print(yy)     

#Always detach the package
detach(package:radolc, unload=TRUE) 
```

# Comparisons to alternatives

Compared to finite differences:

* radolc requires tracing.

* radolc does not suffer from rounding and truncation errors. 

* radolc can efficiently compute adjoints using the reverse mode of automatic differentiation. using the reverse mode is more efficient when the code involves more independents than dependents.

* radolc can exploit sparsity in the Jacobian and Hessain. 

Compared to `NumDeriv`:
* radolc requires tracing.

* radolc does not suffer from rounding and truncation errors. 

* radolc can efficiently compute adjoints using the reverse mode of automatic differentiation. using the reverse mode is more efficient when the code involves more independents than dependents.

* radolc can exploit sparsity in the Jacobian and Hessain.

Compared to `madness`:
* radolc requires tracing.

* radolc can efficiently compute adjoints using the reverse mode of automatic differentiation. using the reverse mode is more efficient when the code involves more independents than dependents.

* `madness` does not allow operations between variables of differing dimensions, i.e. scalar-vector multiplication, which is critical in many modeling situations.

# Future work
We plan to address shortcomings such as the lack of support of function such as `solve`.

# Acknowledgement
We thank Prasanna Balaprakash, Paul Hovland, Joseph Wang, 
and Richard Beare for their suggestions. 

# Funding Sources
This work was funded in part by a grant from DAAD
Project Based Personnel Exchange Programme, the  National Science Foundation
Mathematical Sciences Graduate Internship, and by 
support from the U.S. Department of Energy, 
Office of Science, under contract DE-AC02-06CH11357.

# References
1. [A. Griewank and A. Walther, Evaluating Derivatives: Principles and Techniques of Algorithmic Differentiation, 2nd ed., Society for Industrial and Applied Mathematics, Philadelphia, PA, USA, 2008.][https://doi.org/10.1137/1.9780898717761]

2. [K. Kulshreshtha, S. Narayanan, J. Bessac, and K. MacIntyre, Efficient computation of derivatives for solving optimization problems in R and Python using SWIG-generated interfaces to ADOL-C, Optimization Methods and Software 33 (2018), pp. 1173--1191.][https://doi.org/10.1080/10556788.2018.1425861]

3. [U. Naumann, The Art of Differentiating Computer Programs: An Introduction to Algorithmic Differentiation, Society for Industrial and Applied Mathematics, Philadelphia, PA, USA, 2012.][https://doi.org/10.1137/1.9781611972078]

4. [A. Walther and A. Griewank, Getting started with ADOL-C, in Combinatorial Scientific Computing, U. Naumann and O. Schenk, eds., chap.~7, Chapman-Hall CRC Computational Science,  2012, pp. 181--202.][https://pdfs.semanticscholar.org/9953/5b1991470c0e0e3f7f1c1733689cf5fb055c.pdf]
