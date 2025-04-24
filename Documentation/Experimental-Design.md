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
Before considering the effects of matrix quality, it is important to understand how metapopulation capacity changes with landscape structure. That is, how do habitat cover and habitat configuration independently, and interactively, affect metapopulation capacity.

## The independent effects of habitat cover on metapopulation capacity

To investigate the effect of habitat cover independently from the distance between habitat patches, I first generate three hypothetical landscapes with equally distanced habitat patches. This landscape has a resolution of 100 x 100 units and the landscapes have either 2, 5, or 10 habitat patches:

![](Experimental-Design_files/figure-html/area_landscapes-1.png)<!-- -->

The metapopulation capacity is then calculated for each of the three arrangements for landscapes as the area of each habitat patch increases from 1 to 500. The distances between each habitat patch remains constant, despite the area of the habitat patches increasing. 

Results: [Habitat Cover Independent Results]()


## The independent effects of inter-patch distance on metapopulation capacity 
