
rm(list = ls())

library(tidyverse)
library(cowplot)
library(patchwork)

df <- read.csv("Results/Results_Folder/Exploring Metapopulation Capacity/Configuration Distance Relationship/config_dist_summary.csv")

p1 <- ggplot(df, aes(x = as.factor(p), y = edge_density)) +
  geom_boxplot() +
  labs(x = "p", y = "Edge Density") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  theme_cowplot()

p2 <- ggplot(df, aes(x = as.factor(p), y = mean_distance )) +
  geom_boxplot() +
  labs(x = "p", y = "Mean inter-patch Distance") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  theme_cowplot()

p3 <- ggplot(df, aes(x = as.factor(p), y = mean_nearest_distance )) +
  geom_boxplot() +
  labs(x = "p", y = "Mean nearest-neighbour Distance") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  theme_cowplot()

p4 <- ggplot(df, aes(x = as.factor(p), y = num_patches )) +
  geom_boxplot() +
  labs(x = "p", y = "Number of Patches") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  theme_cowplot()

p5 <- ggplot(df, aes(x = as.factor(p), y = mean_patch_area )) +
  geom_boxplot() +
  labs(x = "p", y = "Mean Habitat Patch Area") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  theme_cowplot()

p1 + p2 + p3 + p4 + p5
