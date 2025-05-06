
rm(list = ls())

library(tidyverse)
library(NLMR)
library(RandomFields)
library(raster)
library(sf)
library(landscapemetrics)
library(parallel)


# Example Landscapes ------------------------------------------------------

set.seed(123)

# set resolution and extent
resolution <- 1 # set resolution

x_extent <- 100 # set width
y_extent <- 100 # set height

# set habitat configuration and covers
landscape_area_vector <- c(0.01, 0.1, 0.2, 0.4) # level of patch aggregation

landscape_config <- 0.2


# get list ready for results
landscape_list <- list()


# Loop through each landscape parameter set and generate a landscape.

for (ai in landscape_area_vector) {
  
  
  # Generate landscape using nlm_randomcluster
  landscape <- nlm_randomcluster(ncol = x_extent, nrow = y_extent, 
                                 resolution = resolution, 
                                 p = landscape_config, 
                                 ai = c((1 - ai), ai))
  
  
  # Coerce to data frame
  landscape_df <- rasterToPoints(landscape, spatial = TRUE)
  landscape_df <- as.data.frame(landscape_df)
  
  
  # Rename columns
  colnames(landscape_df) <- c("layer", "x", "y")
  landscape_df$layer <- as.factor(landscape_df$layer)
  
  
  # Save to list
  name <- paste0("landscape_config_", landscape_config, "_ai_", ai)
  landscape_list[[name]] <- landscape_df
}

# unwrap list to get a data frame
landscape_df <- bind_rows(
  lapply(names(landscape_list), function(name) {
    df <- landscape_list[[name]]
    # Extract config and ai from the name
    config_val <- str_extract(name, "(?<=landscape_config_)[0-9.]+") %>% as.numeric()
    ai_val     <- str_extract(name, "(?<=ai_)[0-9.]+") %>% as.numeric()
    
    df$landscape_config <- config_val
    df$ai <- ai_val
    return(df)
  }),
  .id = "id"
)



# Function to label landscapes with "p = ..."
custom_labeller <- labeller(
  ai = function(x) paste0("cover = ", as.numeric(x) *100, "%")
)

ggplot(landscape_df, aes(x = x, y = y, fill = layer)) +
  geom_raster() +
  facet_wrap(~ ai, labeller = custom_labeller) +
  scale_fill_manual(
    values = c("0" = "orange", "1" = "darkgreen"),
    labels = c("0" = "Non-habitat", "1" = "Habitat"),
    name = "Habitat"
  ) +
  coord_equal() +
  labs(x = NULL, y = NULL) +  # Removes axis titles
  theme_minimal(base_size = 12) +
  theme(
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    strip.placement = "outside",
    strip.background = element_blank(),
    legend.position = "right",
    plot.title = element_blank()
  )



# Effect of landscape configuration on distance ---------------------------

rm(list = ls())


set.seed(123)

# set resolution and extent
resolution <- 1 # set resolution


x_extent <- 80 # set width
y_extent <- 80 # set height

# set habitat configuration and covers
landscape_area_vector <- c(0.01, 0.1, 0.2, 0.4) # level of patch aggregation

landscape_config <- 0.2

n_replicates <- 5 # set the number of replicates


# Set up list to store everything
landscape_list <- list()
distance_matrices <- list()
summary_data <- data.frame()

# Simulation function for a single replicate
simulate_replicate <- function(replicate, landscape_config, resolution, x_extent, y_extent, ai) {
  landscape <- nlm_randomcluster(
    ncol = x_extent, nrow = y_extent, 
    resolution = resolution, 
    p = landscape_config, 
    ai = c((1 - ai), ai)
  )
  
  clumps <- clump(landscape, directions = 8)
  
  edge_density <- as.numeric(
    lsm_l_ed(landscape, count_boundary = FALSE, directions = 8)[6]
  )
  
  landscape_df <- rasterToPoints(landscape, spatial = TRUE) %>%
    as.data.frame()
  colnames(landscape_df) <- c("layer", "x", "y")
  landscape_df$layer <- as.factor(landscape_df$layer)
  
  coordinates(landscape_df) <- ~x + y 
  landscape_df$patch <- terra::extract(clumps, landscape_df)
  landscape_df <- as.data.frame(landscape_df)
  
  num_patches <- length(unique(landscape_df$patch)) - 1
  mean_patch_area <- (sum(landscape_df$layer == 1)) / num_patches
  
  patch_raster <- rasterFromXYZ(landscape_df[, c("x", "y", "patch")])
  res(patch_raster) <- c(1, 1)
  crs(patch_raster) <- CRS("+proj=utm +zone=33 +datum=WGS84")
  
  habitat_polygons <- rasterToPolygons(patch_raster, fun = function(x) {x > 0}, dissolve = TRUE)
  habitat_polygons_sf <- st_as_sf(habitat_polygons)
  dist_matrix <- st_distance(habitat_polygons_sf)
  
  dist_vector <- as.numeric(dist_matrix[lower.tri(dist_matrix)])
  mean_distance <- mean(dist_vector, na.rm = TRUE)
  
  diag(dist_matrix) <- NA
  nearest_neighbors <- apply(dist_matrix, 1, min, na.rm = TRUE)
  mean_nearest_distance <- mean(nearest_neighbors, na.rm = TRUE)
  
  list(
    replicate = replicate,
    landscape_df = landscape_df,
    dist_vector = dist_vector,
    summary = data.frame(
      ai = ai,
      p = landscape_config,
      replicate = replicate,
      edge_density = edge_density,
      mean_distance = mean_distance,
      mean_nearest_distance = mean_nearest_distance,
      num_patches = num_patches,
      mean_patch_area = mean_patch_area
    )
  )
}

# Loop through each config and simulate in parallel
for (ai in landscape_area_vector) {
  name <- paste0("landscape_config_", landscape_config, "_ai_", ai)
  
  results <- mclapply(
    1:n_replicates,
    simulate_replicate,
    landscape_config = landscape_config,
    resolution = resolution,
    x_extent = x_extent,
    y_extent = y_extent,
    ai = ai,
    mc.cores = 1
  )
  
  landscape_list[[name]] <- lapply(results, function(x) x$landscape_df)
  distance_matrices[[name]] <- lapply(results, function(x) x$dist_vector)
  summary_data <- rbind(summary_data, do.call(rbind, lapply(results, function(x) x$summary)))
  
  cat("Finished ai:", ai, "\n")
}

# Combine all landscape data frames
landscape_df_final <- bind_rows(
  lapply(names(landscape_list), function(config_name) {
    df <- bind_rows(landscape_list[[config_name]], .id = "replicate")
    ai_val <- as.numeric(str_remove(config_name, "ai"))
    df$landscape_ai <- ai_val
    return(df)
  }),
  .id = "ai_id"
)


# save results as csv

write.csv(summary_data, "Results/Results_Folder/Exploring Metapopulation Capacity/Cover Distance Relationship/cover_dist_summary.csv")
write.csv(landscape_df_final, "Results/Results_Folder/Exploring Metapopulation Capacity/Cover Distance Relationship/cover_dist_landscapes.csv")
