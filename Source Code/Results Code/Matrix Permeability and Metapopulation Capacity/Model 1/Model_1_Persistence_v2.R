# 
# rm(list = ls())
# 
# library(tidyverse)
# library(mgcv)
# 
# # Generate habitat covers for predicting data
# habitat_seq <- data.frame(habitat_cover = seq(0, 45, by = 0.01))
# 
# # Prepare Model Results Data ----------------------------------------------
# 
# # High aggregation group
# ha_vhd <- read.csv("Results/Results_Folder/Matrix Permeability and Metapopulation Capacity/Model 1/ha_csv/ha_vhd.csv")
# ha_hd  <- read.csv("Results/Results_Folder/Matrix Permeability and Metapopulation Capacity/Model 1/ha_csv/ha_hd.csv")
# ha_md  <- read.csv("Results/Results_Folder/Matrix Permeability and Metapopulation Capacity/Model 1/ha_csv/ha_md.csv")
# ha_ld  <- read.csv("Results/Results_Folder/Matrix Permeability and Metapopulation Capacity/Model 1/ha_csv/ha_ld.csv")
# ha_vld <- read.csv("Results/Results_Folder/Matrix Permeability and Metapopulation Capacity/Model 1/ha_csv/ha_vld.csv")
# 
# # Medium aggregation group
# ma_vhd <- read.csv("Results/Results_Folder/Matrix Permeability and Metapopulation Capacity/Model 1/ma_csv/ma_vhd.csv")
# ma_hd  <- read.csv("Results/Results_Folder/Matrix Permeability and Metapopulation Capacity/Model 1/ma_csv/ma_hd.csv")
# ma_md  <- read.csv("Results/Results_Folder/Matrix Permeability and Metapopulation Capacity/Model 1/ma_csv/ma_md.csv")
# ma_ld  <- read.csv("Results/Results_Folder/Matrix Permeability and Metapopulation Capacity/Model 1/ma_csv/ma_ld.csv")
# ma_vld <- read.csv("Results/Results_Folder/Matrix Permeability and Metapopulation Capacity/Model 1/ma_csv/ma_vld.csv")
# 
# # Low aggregation group
# la_vhd <- read.csv("Results/Results_Folder/Matrix Permeability and Metapopulation Capacity/Model 1/la_csv/la_vhd.csv")
# la_hd  <- read.csv("Results/Results_Folder/Matrix Permeability and Metapopulation Capacity/Model 1/la_csv/la_hd.csv")
# la_md  <- read.csv("Results/Results_Folder/Matrix Permeability and Metapopulation Capacity/Model 1/la_csv/la_md.csv")
# la_ld  <- read.csv("Results/Results_Folder/Matrix Permeability and Metapopulation Capacity/Model 1/la_csv/la_ld.csv")
# la_vld <- read.csv("Results/Results_Folder/Matrix Permeability and Metapopulation Capacity/Model 1/la_csv/la_vld.csv")
# 
# 
# # Combine datasets
# # List of dataset names as strings
# dataset_names <- c("ha_vhd", "ha_hd", "ha_md", "ha_ld", "ha_vld",
#                    "ma_vhd", "ma_hd", "ma_md", "ma_ld", "ma_vld",
#                    "la_vhd", "la_hd", "la_md", "la_ld", "la_vld")
# 
# # Initialize empty data frame
# combined_df <- data.frame()
# 
# # Loop through each dataset
# for (name in dataset_names) {
#   df <- get(name)              # Get the actual data frame
#   df$source <- name            # Add a column with the dataset name
#   combined_df <- rbind(combined_df, df)  # Append to the combined data frame
# }
# 
# # calculate agricultural yield
# productivity <- 0.5
# combined_df$yield <- productivity/(1-(combined_df$habitat_cover/100))
# 
# # normalise yield to get relative yield
# 
# combined_df$r_yield <- (combined_df$yield-productivity)/(1-productivity)
# 
# # remove yield column
# combined_df$yield <- NULL
# 
# 
# # Prepare Delta Data ------------------------------------------------------
# 
# 
# # Define movement responses
# # movement can be 'linear', 'concave', or 'convex'
# movements <- c('linear', 'concave', 'convex')
# 
# # Define maximum movement increases (%)
# movement_abilities <- c(50, 500, 5000)
# 
# # Create grid of movement combinations
# movement_combos <- expand.grid(delta_movement = movements, delta_movement_ability = movement_abilities)
# 
# # add the movement combinations to the combined data
# expanded_df <- combined_df %>%
#   slice(rep(1:n(), each = nrow(movement_combos))) %>%
#   bind_cols(movement_combos[rep(1:nrow(movement_combos), times = nrow(combined_df)), ])
# 
# 
# # Create dataframe of slope constants for movement scenarios
# m <- c("linear", "linear", "linear", "linear", "linear", "linear", "concave", "concave", "concave", "concave", "concave", "concave", "convex", "convex", "convex", "convex", "convex", "convex")
# m_a <- c("10", "50", "100", "500", "1000", "5000", "10", "50", "100", "500", "1000", "5000", "10", "50", "100", "500", "1000", "5000")
# s1 <- c(0.1, 0.5, 1, 5, 10, 50, 0.1, 0.5, 1, 5, 10, 50, 4.54e-6, 2.27e-5, 4.54e-5, 2.27e-4, 4.53e-4, 0.00227)
# s2 <- c(NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 0.99999546, 0, 0, 0, 0, 0.99773)
# a <- c(1, 1, 1, 1, 1, 1, 0.1, 0.5, 1, 5, 10, 50, 0, 1, 1, 1, 1, 0)
# 
# slopes <- data.frame(m, m_a, s1, s2, a)
# 
# 
# 
# # Functions for calculating alpha (dispersal distance)
# # Linear
# linear_permeability <- function(y, s, a) {
#   disp_factor = (((s * (1 - y)) + a))
#   return(disp_factor)
# }
# 
# # Concave
# conc_permeability <- function(y, s, a) {
#   disp_factor = (((-(y)^2 * s) + 1) + a)
#   return(disp_factor)
# }
# 
# # Convex
# conv_permeability <- function(y, s, s2, a) {
#   disp_factor = (((exp(10 * (1 - y))) * s) + s2) + a
#   return(disp_factor)
# }
# 
# 
# 
# # Define a function to compute delta_factor for a single row
# compute_delta_factor <- function(delta_movement, delta_ability, yield) {
#   # Get matching row from slopes
#   slope_row <- slopes %>% filter(m == delta_movement, m_a == as.character(delta_ability))
# 
# 
#   s <- as.numeric(slope_row$s1)
#   s2 <- as.numeric(slope_row$s2)
#   a <- as.numeric(slope_row$a)
# 
#   if (delta_movement == "linear") {
#     return(linear_permeability(y = yield, s = s, a = a))
#   } else if (delta_movement == "concave") {
#     return(conc_permeability(y = yield, s = s, a = a))
#   } else if (delta_movement == "convex") {
#     return(conv_permeability(y = yield, s = s, s2 = s2, a = a))
#   } else {
#     return(1)
#   }
# }
# 
# 
# # Apply the function row-wise
# expanded_df$delta_factor <- pmap_dbl(
#   list(expanded_df$delta_movement, expanded_df$delta_movement_ability, expanded_df$r_yield),
#   compute_delta_factor
# )
# 
# expanded_df <- expanded_df %>%
#   separate(movement, into = c("tmp1", "tmp2", "movement", "movement_ability"), sep = "_", remove = FALSE) %>%
#   mutate(movement_ability = as.numeric(movement_ability)) %>%
#   select(-tmp1, -tmp2)
# 
# # Split 'source' into aggregation and dispersal
# expanded_df <- expanded_df %>%
#   mutate(
#     aggregation = substr(source, 1, 2),
#     dispersal = substr(source, 4, 6)
#   )
# 
# write.csv(expanded_df, "Results/Results_Folder/Matrix Permeability and Metapopulation Capacity/Model 1/Persistence/delta_df", row.names = FALSE)
# 
# 


# Calculate Differences ---------------------------------------------------

rm(list = ls())

library(tidyverse)
library(mgcv)

delta_df <- read.csv("Results/Results_Folder/Matrix Permeability and Metapopulation Capacity/Model 1/Persistence/delta_df",
                        header = TRUE)



# calculate delta
delta_df$c_intense <- 0.01
delta_df$c <- delta_df$c_intense * delta_df$delta_factor
delta_df$e <- 0.5
delta_df$delta <- delta_df$e/delta_df$c

# calculate difference (persistence)
delta_df$difference <- delta_df$metapop_cap - delta_df$delta


# remove the none column baseline
delta_df <- delta_df %>%
  filter(movement_ability != 0)

# remove some movement abilities
delta_df <- delta_df %>%
  filter(movement_ability != 10)
delta_df <- delta_df %>%
  filter(movement_ability != 100)
delta_df <- delta_df %>%
  filter(movement_ability != 1000)

# Plot graphs -------------------------------------------------------------

library(ggforce)


# Get unique combinations of movement_ability and aggregation for pagination
unique_pages <- delta_df %>%
  distinct(movement_ability, aggregation)


# Total number of pages
n_pages <- nrow(unique_pages)

# Loop through pages and plot each
for (i in 1:n_pages) {
  
  # Filter for current movement_ability and aggregation
  current_filter <- unique_pages[i, ]
  plot_data <- delta_df %>%
    filter(
      movement_ability == current_filter$movement_ability,
      aggregation == current_filter$aggregation
    )
  
  # Create plot with scatter + GAM smoothing and free y-axis
  p <- ggplot(plot_data, aes(x = habitat_cover, y = difference, 
                             color = interaction(delta_movement, delta_movement_ability))) +
    geom_point(alpha = 0.4, size = 0.8) +
    geom_smooth(method = "gam", se = FALSE, formula = y ~ s(x, bs = "cs"), alpha = 0.3) +
    facet_wrap(~ dispersal + movement, scales = "free_y") +
    labs(
      title = paste("Movement ability:", current_filter$movement_ability,
                    "| Aggregation:", current_filter$aggregation),
      color = "Delta movement & ability"
    ) +
    theme_minimal()
  
  print(p)
}
