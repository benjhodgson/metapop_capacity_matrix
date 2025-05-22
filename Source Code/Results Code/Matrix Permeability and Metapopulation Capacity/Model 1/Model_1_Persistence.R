
rm(list = ls())

library(tidyverse)
library(mgcv)

# Generate habitat covers for predicting data
habitat_seq <- data.frame(habitat_cover = seq(0, 45, by = 0.1))

# Prepare Model Results Data ----------------------------------------------

# High aggregation group
ha_vhd <- read.csv("Results/Results_Folder/Matrix Permeability and Metapopulation Capacity/Model 1/ha_csv/ha_vhd.csv")
ha_hd  <- read.csv("Results/Results_Folder/Matrix Permeability and Metapopulation Capacity/Model 1/ha_csv/ha_hd.csv")
ha_md  <- read.csv("Results/Results_Folder/Matrix Permeability and Metapopulation Capacity/Model 1/ha_csv/ha_md.csv")
ha_ld  <- read.csv("Results/Results_Folder/Matrix Permeability and Metapopulation Capacity/Model 1/ha_csv/ha_ld.csv")
ha_vld <- read.csv("Results/Results_Folder/Matrix Permeability and Metapopulation Capacity/Model 1/ha_csv/ha_vld.csv")

# Medium aggregation group
ma_vhd <- read.csv("Results/Results_Folder/Matrix Permeability and Metapopulation Capacity/Model 1/ma_csv/ma_vhd.csv")
ma_hd  <- read.csv("Results/Results_Folder/Matrix Permeability and Metapopulation Capacity/Model 1/ma_csv/ma_hd.csv")
ma_md  <- read.csv("Results/Results_Folder/Matrix Permeability and Metapopulation Capacity/Model 1/ma_csv/ma_md.csv")
ma_ld  <- read.csv("Results/Results_Folder/Matrix Permeability and Metapopulation Capacity/Model 1/ma_csv/ma_ld.csv")
ma_vld <- read.csv("Results/Results_Folder/Matrix Permeability and Metapopulation Capacity/Model 1/ma_csv/ma_vld.csv")

# Low aggregation group
la_vhd <- read.csv("Results/Results_Folder/Matrix Permeability and Metapopulation Capacity/Model 1/la_csv/la_vhd.csv")
la_hd  <- read.csv("Results/Results_Folder/Matrix Permeability and Metapopulation Capacity/Model 1/la_csv/la_hd.csv")
la_md  <- read.csv("Results/Results_Folder/Matrix Permeability and Metapopulation Capacity/Model 1/la_csv/la_md.csv")
la_ld  <- read.csv("Results/Results_Folder/Matrix Permeability and Metapopulation Capacity/Model 1/la_csv/la_ld.csv")
la_vld <- read.csv("Results/Results_Folder/Matrix Permeability and Metapopulation Capacity/Model 1/la_csv/la_vld.csv")


# Function to process the model results, run GAM models and predict metapopulation capacities

process_dataset <- function(df, dataset_name, movement_pct, habitat_grid) {
  # Filter by movement % increase (string ends with movement_pct)
  pattern <- paste0(movement_pct, "$")
  df_sub <- df[grepl(pattern, as.character(df$movement)), ]
  
  # Extract dispersal shape 'linear', 'concave', or 'convex'
  
  shapes <- c("convex", "concave", "linear")
  
  results <- list()
  
  for(shape in shapes) {
    # Filter by shape (case insensitive)
    df_shape <- df_sub[grepl(shape, df_sub$movement, ignore.case = TRUE), ]
    
    # Clean data: remove NA and non-positive metapop_cap
    df_shape <- subset(df_shape, !is.na(habitat_cover) & !is.na(metapop_cap) & metapop_cap > 0 & is.finite(metapop_cap))
    
    if(nrow(df_shape) < 10) {  # Avoid fitting if too few points
      warning(paste(dataset_name, movement_pct, shape, "has too few rows, skipping GAM fit"))
      next
    }
    
    # Fit GAM on log(metapop_cap) ~ s(habitat_cover)
    gam_model <- gam(log(metapop_cap) ~ s(habitat_cover), data = df_shape)
    
    # Predict on habitat grid
    pred_vals <- predict(gam_model, newdata = habitat_grid)
    pred_df <- data.frame(habitat_cover = habitat_grid$habitat_cover, pred = pred_vals)
    
    # Create names for returned objects
    pred_name <- paste0(dataset_name, "_", movement_pct, "_", shape, "_pred")
    gam_name  <- paste0(dataset_name, "_", movement_pct, "_", shape, "_gam")
    data_name <- paste0(dataset_name, "_", movement_pct, "_", shape)
    
    # Store in list
    results[[pred_name]] <- pred_df
    results[[gam_name]]  <- gam_model
    results[[data_name]] <- df_shape
  }
  
  return(results)
}

# Apply function to model outputs

# Your original dataset names as strings:
dataset_names <- c("ha_vhd", "ha_hd", "ha_md", "ha_ld", "ha_vld",
                   "ma_vhd", "ma_hd", "ma_md", "ma_ld", "ma_vld",
                   "la_vhd", "la_hd", "la_md", "la_ld", "la_vld")

# Movement percentages to filter by
movement_pcts <- c("50", "500", "5000")

all_results <- list()

for(ds_name in dataset_names) {
  cat("Processing dataset:", ds_name, "\n")
  
  # Get dataset from global env by name
  df <- get(ds_name)
  
  for(mov_pct in movement_pcts) {
    cat("  Movement pct:", mov_pct, "\n")
    
    res <- process_dataset(df, ds_name, mov_pct, habitat_seq)
    
    # Store all returned elements into all_results
    all_results <- c(all_results, res)
  }
}


# Prepare Delta Data ------------------------------------------------------


# Define movement responses
# movement can be 'linear', 'concave', or 'convex'
movements <- c('linear', 'concave', 'convex')

# Define maximum movement increases (%)
movement_abilities <- c(50, 500, 5000)

# Create grid of movement combinations
movement_combos <- expand.grid(movement = movements, movement_ability = movement_abilities)

# Create a new row for null movement
new_row <- data.frame(movement = "none", movement_ability = 0)

# Add the new row to the grid
movement_combos <- rbind(movement_combos, new_row)
rm(new_row)

# Set movement as a character
movement_combos$movement <- as.character(movement_combos$movement)

# Create dataframe of slope constants for movement scenarios
m <- c("linear", "linear", "linear", "linear", "linear", "linear", "concave", "concave", "concave", "concave", "concave", "concave", "convex", "convex", "convex", "convex", "convex", "convex")
m_a <- c("10", "50", "100", "500", "1000", "5000", "10", "50", "100", "500", "1000", "5000", "10", "50", "100", "500", "1000", "5000")
s1 <- c(0.1, 0.5, 1, 5, 10, 50, 0.1, 0.5, 1, 5, 10, 50, 4.54e-6, 2.27e-5, 4.54e-5, 2.27e-4, 4.53e-4, 0.00227)
s2 <- c(NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 0.99999546, 0, 0, 0, 0, 0.99773)
a <- c(1, 1, 1, 1, 1, 1, 0.1, 0.5, 1, 5, 10, 50, 0, 1, 1, 1, 1, 0)

slopes <- data.frame(m, m_a, s1, s2, a)

# Create an empty list to store the results
c_multiplier_list <- list()

for (j in 1:nrow(movement_combos)) {
  movement <- movement_combos$movement[j]
  movement_ability <- movement_combos$movement_ability[j]
  
  # Matrix Effects ----------------------------------------------------------
  
  productivity <- 0.5
  
  landscape_cover <- seq(0, 45, by = 1)
  
  # Calculate agricultural yield
  yield <- productivity / (1 - (landscape_cover / 100))
  
  # Normalize yield to get relative yield
  relative_yield <- (yield - productivity) / (1 - productivity)
  
  
  
  # Functions for calculating alpha (dispersal distance)
  # Linear
  linear_permeability <- function(y, s, a) {
    disp_factor = (((s * (1 - y)) + a))
    return(disp_factor)
  }
  
  # Concave
  conc_permeability <- function(y, s, a) {
    disp_factor = (((-(y)^2 * s) + 1) + a)
    return(disp_factor)
  }
  
  # Convex
  conv_permeability <- function(y, s, s2, a) {
    disp_factor = (((exp(10 * (1 - y))) * s) + s2) + a
    return(disp_factor)
  }
  
  # Pick correct constants (slopes) for current dispersal scenario
  slope <- slopes %>% filter(m == movement & m_a == movement_ability)
  slope <- as.numeric(slope[3])
  slope_2 <- slopes %>% filter(m == movement & m_a == movement_ability)
  slope_2 <- as.numeric(slope_2[4])
  a <- slopes %>% filter(m == movement & m_a == movement_ability)
  a <- as.numeric(a[5])
  
  # Calculate dispersal multiplier
  if (movement == "linear") {
    dispersal_factor <- linear_permeability(y = relative_yield, s = slope, a = a)
  } else if (movement == "concave") {
    dispersal_factor <- conc_permeability(y = relative_yield, s = slope, a = a)
  } else if (movement == "convex") {
    dispersal_factor <- conv_permeability(y = relative_yield, s = slope, s2 = slope_2, a = a)
  } else if (movement == "none") {
    dispersal_factor <- 1
  } else {
    print("No matching movement")
  }
  
  c_intense <- 1
  
  # Create the dynamic variable name
  var_name <- paste("c_multiplier_", movement, "_", movement_ability, sep = "")
  
  # Calculate the value
  c_multiplier <- c_intense * dispersal_factor
  
  # Store the result in the list with dynamic variable names
  c_multiplier_list[[var_name]] <- c_multiplier  # Store it in the list
  
}



# Create a dataframe to hold the output
output_df <- data.frame(movement = character(0), habitat_cover = numeric(0), c_multiplier = numeric(0))

# Iterate through the list and combine with habitat_cover
for (var_name in names(c_multiplier_list)) {
  
  # Extract movement and movement_ability from the variable name
  split_name <- unlist(strsplit(var_name, "_"))
  movement <- split_name[3]
  movement_ability <- as.numeric(split_name[4])
  
  # Habitat cover values
  habitat_cover <- seq(0, 45, by = 1)  
  
  # Get the value of the c_multiplier for this specific variable
  c_multiplier_value <- c_multiplier_list[[var_name]]
  
  # Create a temporary dataframe for this combination
  temp_df <- data.frame(movement = rep(movement, length(habitat_cover)),
                        movement_ability = rep(movement_ability, length(habitat_cover)),
                        habitat_cover = habitat_cover,
                        c_multiplier = rep(c_multiplier_value, length(habitat_cover)))
  
  # Add to the main dataframe
  output_df <- rbind(output_df, temp_df)
}



delta_df <- output_df

delta_df$c_intense <- 0.1

delta_df$c <- delta_df$c_intense * delta_df$c_multiplier

delta_df$e <- 0.1

delta_df$delta <- delta_df$e/delta_df$c


str(delta_df)




process_delta_dataset <- function(df, dataset_name, habitat_grid) {
  # Get unique combinations of movement and movement_ability
  combos <- unique(df[, c("movement", "movement_ability")])
  
  results <- list()
  
  for (i in 1:nrow(combos)) {
    mov <- combos$movement[i]
    abil <- combos$movement_ability[i]
    
    # Filter data for this combination
    df_subset <- subset(df,
                        movement == mov &
                          movement_ability == abil &
                          !is.na(delta) &
                          is.finite(delta) &
                          !is.na(habitat_cover))
    
    if (nrow(df_subset) < 10) {
      warning(paste(dataset_name, mov, abil, "has too few rows, skipping GAM fit"))
      next
    }
    
    # Fit GAM: delta ~ s(habitat_cover)
    gam_model <- gam(delta ~ s(habitat_cover), data = df_subset)
    
    # Predict on grid
    pred_vals <- predict(gam_model, newdata = habitat_grid)
    pred_df <- data.frame(habitat_cover = habitat_grid$habitat_cover, pred = pred_vals)
    
    # Generate object names
    safe_mov <- gsub("[^a-zA-Z0-9]", "", tolower(mov))
    pred_name <- paste0(dataset_name, "_", safe_mov, "_", abil, "_pred")
    gam_name  <- paste0(dataset_name, "_", safe_mov, "_", abil, "_gam")
    data_name <- paste0(dataset_name, "_", safe_mov, "_", abil)
    
    # Store
    results[[pred_name]] <- pred_df
    results[[gam_name]]  <- gam_model
    results[[data_name]] <- df_subset
  }
  
  return(results)
}

delta_results <- process_delta_dataset(df = delta_df, dataset_name = "delta", habitat_grid = habitat_seq)


# Calculate GAM differences -----------------------------------------------

compare_all_predicted_gams <- function(all_results, delta_preds) {
  all_comparisons <- list()
  
  # Filter only *_pred entries
  preds_main <- all_results[grepl("_pred$", names(all_results))]
  preds_delta <- delta_preds[grepl("_pred$", names(delta_preds))]
  
  for (name_main in names(preds_main)) {
    df1 <- preds_main[[name_main]]
    source1_clean <- gsub("_pred$", "", name_main)
    
    for (name_delta in names(preds_delta)) {
      df2 <- preds_delta[[name_delta]]
      source2_clean <- gsub("_pred$", "", name_delta)
      
      # Ensure matching habitat_cover grid
      if (!all.equal(df1$habitat_cover, df2$habitat_cover)) {
        warning(paste("Skipping mismatched habitat_cover between", name_main, "and", name_delta))
        next
      }
      
      # Compute difference and ratio on the original scale
      comparison_df <- data.frame(
        habitat_cover = df1$habitat_cover,
        source_1 = source1_clean,
        source_2 = source2_clean,
        abs_diff = exp(df1$pred) - exp(df2$pred),
        abs_ratio = exp(df1$pred) / exp(df2$pred),
        stringsAsFactors = FALSE
      )
      
      all_comparisons[[paste0(source1_clean, "_vs_", source2_clean)]] <- comparison_df
    }
  }
  
  final_df <- do.call(rbind, all_comparisons)
  rownames(final_df) <- NULL
  return(final_df)
}


diff_results <- compare_all_predicted_gams(all_results, delta_results)

write.csv(diff_results, file = "Results/Results_Folder/Matrix Permeability and Metapopulation Capacity/Model 1/GAM/gam_differences.csv")


# Plot GAM differences ----------------------------------------------------

plot_diff_vs_habitat <- function(diff_df, source_group, type, mag, delta_prefix = "delta_") {
  df_sub <- diff_df[diff_df$source_1 %in% source_group & grepl(delta_prefix, diff_df$source_2), ]
  
  # Human-readable labels
  type_label <- switch(type,
                       "ha" = "Low Aggregation",
                       "ma" = "Medium Aggregation",
                       "la" = "High Aggregation",
                       type)
  mag_label <- paste0(mag, "% Movement Increase")
  
  ggplot(df_sub, aes(x = habitat_cover, y = abs_diff, color = source_2)) +
    geom_line(alpha = 0.8) +
    labs(
      title = paste("Absolute Difference in Metapopulation Capacity –", type_label, "–", mag_label),
      x = "Habitat Cover",
      y = "Absolute Difference",
      color = "Delta Scenario"
    ) +
    theme_minimal() +
    facet_wrap(~ source_1, ncol = 3, scales = "free_y") +
    theme(legend.position = "bottom")
}


# Extract unique source_1 names
unique_sources <- unique(diff_results$source_1)

# Get combinations of aggregation type and movement ability
types <- c("ha", "ma", "la")
magnitudes <- c("50", "500", "5000")

plot_list <- list()

for (type in types) {
  for (mag in magnitudes) {
    pattern <- paste0("^", type, "_.*_", mag, "_")
    group_sources <- unique_sources[grepl(pattern, unique_sources)]
    
    if (length(group_sources) == 0) next
    
    p <- plot_diff_vs_habitat(diff_results, source_group = group_sources, type = type, mag = mag)
    print(p)
    plot_list[[paste0(type, "_", mag)]] <- p
  }
}


