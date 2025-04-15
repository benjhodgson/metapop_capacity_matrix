---
title: "Metapopulation Capacity Model User Guide"
output: 
  html_document: 
    toc: true
    toc_float: true
    keep_md: true
    number_sections: true
date: "2025-04-11"
---



# Metapopulation Capacity
## Overview
Metapopulation capacity ($\lambda_{M}$) is a spatially explicit version of the Levin's model. It is a unitless metric of landscape suitability for population persistence and is determined by the leading (largest) eigenvalue of a given landscape matrix. The only necessary data that are required for calculating metapopulation capacity are the areas of habitat patches, the pairwise distances between habitat patches, and the average migration distance of a given species. 

To determine whether a given landscape can support a metapopulation indefinitely, the species-specific colonisation constant $c$ and extinction constant $e$ must also be known.

A species will persist indefinitely if

\begin{equation}
\lambda_{M} > \delta
\end{equation}
where 
\begin{equation}
\delta = \frac{e}{c}
\end{equation}

## Calculating Metapopulation Capacity
The landscape matrix used to calculate metapopulation capacity is defined as:

\begin{equation}
  m_{ij} =
  \left[ {\begin{array}{cccc}
    0 & e^{-\alpha\textit{d}_{12}}A_{1}A_{2} & \cdots & e^{-\alpha\textit{d}_{1j}}A_{1}A_{j}\\\\
    e^{-\alpha\textit{d}_{21}}A_{2}A_{1} & 0 & \cdots & e^{-\alpha\textit{d}_{2j}}A_{2}A_{j}\\
    \vdots & \vdots & \ddots & \vdots\\
    e^{-\alpha\textit{d}_{i1}}A_{i}A_{1} & e^{-\alpha\textit{d}_{i2}}A_{i}A_{2} & \cdots & 0\\
  \end{array} } \right]
  i\neq j
\end{equation}

where $d_{ij}$ is the distance between habitat patches $i$ and $j$, $A_i$ and $A_j$ are the sizes of habitat patches $i$ and $j$ respectively, and $\alpha$ is the inverse of the mean dispersal distance.

In R, we can create the landscape matrix from a distance matrix named `dist_matrix` and an area matrix named `area_matrix`. The eigenvalues are then extracted and the leading eigenvalue, or metapopulation capacity $\lambda_{M}$, is isolated.  


``` r
metapop <- exp(-alpha * dist_matrix) # exponent of -alpha * distances
    diag(metapop) <- 0 # set diagonal back to 0
    
    area_matrix <- outer(patch_area_df$area, patch_area_df$area, FUN = "*")
    # create a matrix of area products
    
    metapop2 <- metapop * area_matrix # multiply metapop by areas of both habitat patches
    
    eig <- eigen(metapop2) # extract eigenvalues
    
    metapop_cap <- eig$values[1] # isolate leading eigenvalue
```

# Including Plots

You can also embed plots, for example:

``` {echo="FALSE"}
```

Note that the `echo = FALSE` parameter was added to the code chunk to prevent printing of the R code that generated the plot.
