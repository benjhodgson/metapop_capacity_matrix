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

Return to Model README: [README](https://github.com/benjhodgson/metapop_capacity_matrix/blob/main/README.md)

# Exploring Metapopulation Capacity
Source Code: [Exploring Metapopulation Capacity - Code](https://github.com/benjhodgson/metapop_capacity_matrix/blob/main/Source%20Code/Source_Code_Index.md#Exploring-Metapopulation-Capacity)

Before considering the effects of matrix quality, it is important to understand how metapopulation capacity changes with landscape structure. That is, how do habitat cover and habitat configuration independently, and interactively, affect metapopulation capacity.

## The independent effects of habitat cover on metapopulation capacity

To investigate the effect of habitat cover independently from the distance between habitat patches, I first generate three hypothetical landscapes with equally distanced habitat patches. This landscape has a resolution of 100 x 100 units and the landscapes have either 2, 5, or 10 habitat patches:

![](Experimental-Design_files/figure-html/area_landscapes-1.png)<!-- -->

The metapopulation capacity is then calculated for each of the three arrangements for landscapes as the area of each habitat patch increases from 1 to 500. The distances between each habitat patch remains constant, despite the area of the habitat patches increasing. Alpha was set at 0.05, which equates to a mean dispersal distance of 20 units.

Results: [The independent effects of habitat cover on metapopulation capacity- Results](https://github.com/benjhodgson/metapop_capacity_matrix/blob/main/Results/Results.md#the-independent-effects-of-habitat-cover-on-metapopulation-capacity)


## The independent effects of inter-patch distance on metapopulation capacity

To investigate the effect of the mean distance between habitat patches on metapopulation, I again create three landscapes with 2, 5, and 10 habitat patches. Each of these habitat patches has an area of 100 units and alpha is set to 0.05.

![](Experimental-Design_files/figure-html/distance_landscapes-1.png)<!-- -->

The distance matrix is calculated, however this is then multiplied by a scaling factor between 1 and 5 and the metapopulation capacity is calculated.

Results: [The independent effects of inter-patch distance on metapopulation capacity - Results](https://github.com/benjhodgson/metapop_capacity_matrix/blob/main/Results/Results.md#the-independent-effects-of-inter-patch-distance-on-metapopulation-capacity)


## The effects of habitat configuration on patch distances and areas

The level of spatial aggregation of habitat patches (habitat configuration) will affect the mean inter-patch distance between habitat patches. To explore this relationship, random landscapes with varying values of p will be generated and the edge density (a measure of spatial aggregation), mean nearest-neighbour distance, mean inter-patch distance, number of habitat patches, and mean habitat patch area will be recorded.

Landscapes will be 100 x 100 with a set habitat proportion of 0.15.

p values, which dictate the level of spatial aggregation will be 0.01, 0.1, 0.2, 0.4.

An example of each of these landscapes can be seen here:

![](Experimental-Design_files/figure-html/config_distance_landscapes-1.png)<!-- -->


There will be 100 unique landscapes for each p value.

Results: [The effects of habitat configuration on patch distances and areas - Results](https://github.com/benjhodgson/metapop_capacity_matrix/blob/main/Results/Results.md#the-effects-of-habitat-configuration-on-patch-distances-and-areas)

## The effects of habitat cover on patch distances and areas
Habitat area will rarely change without also affecting the nearest distance between patches. Increasing the habitat cover, therefore will likely indirectly affect metapopulation capacity by decreasing the mean inter-patch distance between habitat patches. To explore the effect of habitat cover on


![](Experimental-Design_files/figure-html/cover_distance_landscapes-1.png)<!-- -->


Results: [The effects of habitat cover on patch distances and areas - Results](https://github.com/benjhodgson/metapop_capacity_matrix/blob/main/Results/Results.md#the-effects-of-habitat-cover-on-patch-distances-and-areas)



# The effect of Matrix Quality on Metapopulation Capacity and Persistence

To explore how different dispersal responses to changes in non-habitat matrix quality affect metapopulation capacity, and subsequently metapopulation persistence, a number of simulations are run.

## The effect of Matrix Quality on Metapopulation Capacity

### Landscape Generation

Landscapes are 100 x 100 km with a resolution of 0.5 km. Landscapes are conserved between replicates for each movement scenario but differ between replicates. Percentage habitat cover varies randomly between ~ 1% and ~ 45%.

### Factorial Design

Each movement scenario was run within a factorial design of dispersal and aggregation scenarios. The dispersal level refers to the mean dispersal distance under a relative yield = 1 landscape. As the relative yield of the matrix reduces, this mean dispersal level will increase in line with the movement scenario function. 


|Dispersal / Aggregation |High Aggregation     |Medium Aggregation  |Low Aggregation     |
|:-----------------------|:--------------------|:-------------------|:-------------------|
|**High Dispersal**      |High agg/High disp   |Mid agg/ High disp  |Low agg/ High disp  |
|**Medium Dispersal**    |High agg/ Mid disp   |Mid agg/ Mid disp   |Low agg/ Mid disp   |
|**Low Dispersal**       |High agg/ Low disp   |Low agg/ Mid disp   |Low agg/ Low disp   |
|**Very Low Dispersal**  |High agg/ V Low disp |Mid agg/ V Low disp |Low agg/ V Low disp |

The parameters used for the factorial design are as follows: 


Table: Parameters for Habitat Configuration

|Configuration      |    p|
|:------------------|----:|
|High aggregation   | 0.40|
|Medium aggregation | 0.20|
|Low aggregation    | 0.01|


Table: Parameters for Mean Dispersal at Relative Yield = 1

|Configuration      | Mean Dispersal Distance at Relative Yield = 1 (km)|
|:------------------|--------------------------------------------------:|
|High dispersal     |                                               5.00|
|Medium dispersal   |                                               1.00|
|Low dispersal      |                                               0.10|
|Very low dispersal |                                               0.01|

### Movement Scenarios

Movement responses to matrix yield follow the three functions described in [](), with mean dispersal distance increases of **10%** (1.1x), **50%** (1.5x), **500%** (6x), **1000%** (11x) and **5000%** (51x) at a relative yield of 0 compared to a relative yield of 1. 


## The effect of Matrix Quality on the Threshold of Metapopulation Persistence


