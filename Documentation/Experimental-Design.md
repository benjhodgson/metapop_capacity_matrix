---
title: "Experimental Design"
output: 
  html_document: 
    toc: true
    toc_float: true
    keep_md: true
    number_sections: true
date: "2025-04-24"
---

# Exploring Metapopulation Capacity
Source Code: [Exploring Metapopulation Capacity Code](https://github.com/benjhodgson/metapop_capacity_matrix/blob/main/Source%20Code/Source_Code_Index.md#Exploring-Metapopulation-Capacity)

Before considering the effects of matrix quality, it is important to understand how metapopulation capacity changes with landscape structure. That is, how do habitat cover and habitat configuration independently, and interactively, affect metapopulation capacity.

## The independent effects of habitat cover on metapopulation capacity

To investigate the effect of habitat cover independently from the distance between habitat patches, I first generate three hypothetical landscapes with equally distanced habitat patches. This landscape has a resolution of 100 x 100 units and the landscapes have either 2, 5, or 10 habitat patches:

![](Experimental-Design_files/figure-html/area_landscapes-1.png)<!-- -->

The metapopulation capacity is then calculated for each of the three arrangements for landscapes as the area of each habitat patch increases from 1 to 500. The distances between each habitat patch remains constant, despite the area of the habitat patches increasing. Alpha was set at 0.05, which equates to a mean dispersal distance of 20 units.

Results: [Habitat Cover Independent Results LINK]()


## The independent effects of inter-patch distance on metapopulation capacity 

To investigate the effect of the mean distance between habitat patches on metapopulation, I again create three landscapes with 2, 5, and 10 habitat patches. Each of these habitat patches has an area of 100 units and alpha is set to 0.05.

![](Experimental-Design_files/figure-html/distance_landscapes-1.png)<!-- -->

The distance matrix is calculated, however this is then multiplied by a scaling factor between 1 and 5 and the metapopulation capacity is calculated.

Results: [Habitat Distance Independent Results LINK]()
