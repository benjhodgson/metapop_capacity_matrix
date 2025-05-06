
rm(list = ls())

library(tidyverse)
library(NLMR)
library(RandomFields)
library(raster)
library(sf)
library(landscapemetrics)


# Example Landscapes ------------------------------------------------------

set.seed(123)

# set resolution and extent
resolution <- 1 # set resolution

x_extent <- 100 # set width
y_extent <- 100 # set height

# set habitat configuration and covers
landscape_config_vector <- c(0.01, 0.1, 0.2, 0.4) # level of patch aggregation

ai <- 0.15 #  random proportion of landscape that is habitat between species bounds


# get list ready for results
landscape_list <- list()


# Loop through each landscape parameter set and generate a landscape.

for (i in landscape_config_vector) {
  
  landscape_config <- landscape_config_vector[i]
  
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
  name <- paste0("landscape_config_", landscape_config)
  landscape_list[[name]] <- landscape_df
}

# unwrap list to get a data frame
landscape_df <- bind_rows(
  lapply(names(landscape_list), function(name) {
    df <- landscape_list[[name]]
    # Extract config and ai from the name
    config_val <- str_extract(name, "(?<=landscape_config_)[0-9.]+") %>% as.numeric()

    df$landscape_config <- config_val
    return(df)
  }),
  .id = "id"
)



# Function to label landscapes with "p = ..."
custom_labeller <- labeller(
  landscape_config = function(x) paste0("p = ", x)
)

ggplot(landscape_df, aes(x = x, y = y, fill = layer)) +
  geom_raster() +
  facet_wrap(~ landscape_config, labeller = custom_labeller) +
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

# set habitat configuration and covers
landscape_config_vector <- c(0.01, 0.1, 0.2, 0.4) # level of patch aggregation

x_extent <- 100 # set width
y_extent <- 100 # set height

# set habitat configuration and covers
landscape_config_vector <- c(0.01, 0.1, 0.2, 0.4) # level of patch aggregation

ai <- 0.15 #  random proportion of landscape that is habitat between species bounds


# Set up list to store everything
landscape_list <- list()
distance_matrices <- list()
summary_data <- data.frame()

# Loop through each config
for (config in landscape_config_vector) {
  
  config_name <- paste0("config_", config)
  landscape_list[[config_name]] <- list()
  distance_matrices[[config_name]] <- list()
  
  for (replicate in 1:2) {  # Change to 100 when you're ready
    
    # Generate landscape
    landscape <- nlm_randomcluster(
      ncol = x_extent, nrow = y_extent, 
      resolution = resolution, 
      p = config, 
      ai = c((1 - ai), ai)
    )
    
    # Identify connected patches
    clumps <- clump(landscape, directions = 8)
    
    # Calculate edge density
    edge_density <- as.numeric(
      lsm_l_ed(landscape, count_boundary = FALSE, directions = 8)[6]
    )
    
    # Convert raster to data frame
    landscape_df <- rasterToPoints(landscape, spatial = TRUE) %>%
      as.data.frame()
    colnames(landscape_df) <- c("layer", "x", "y")
    landscape_df$layer <- as.factor(landscape_df$layer)
    
    # Add clump IDs (patches)
    coordinates(landscape_df) <- ~x + y 
    landscape_df$patch <- terra::extract(clumps, landscape_df)
    landscape_df <- as.data.frame(landscape_df)
    
    # Create patch raster
    patch_raster <- rasterFromXYZ(landscape_df[, c("x", "y", "patch")])
    res(patch_raster) <- c(1, 1)
    crs(patch_raster) <- CRS("+proj=utm +zone=33 +datum=WGS84")
    
    # Convert raster to polygons and compute distance matrix
    habitat_polygons <- rasterToPolygons(patch_raster, fun = function(x) {x > 0}, dissolve = TRUE)
    habitat_polygons_sf <- st_as_sf(habitat_polygons)
    dist_matrix <- st_distance(habitat_polygons_sf)
    
    # Inter-patch distances
    dist_vector <- as.numeric(dist_matrix[lower.tri(dist_matrix)])
    mean_distance <- mean(dist_vector)
    
    # Store results
    landscape_list[[config_name]][[replicate]] <- landscape_df
    distance_matrices[[config_name]][[replicate]] <- dist_vector
    
    # Add to summary data frame
    summary_data <- rbind(summary_data, data.frame(
      p = config,
      replicate = replicate,
      edge_density = edge_density,
      mean_distance = mean_distance
    ))
    
    # Progress message
    cat("Finished config:", config, "replicate:", replicate, "\n")
  }
}





# unwrap list to get a data frame
landscape_df <- bind_rows(
  lapply(names(landscape_list), function(name) {
    df <- landscape_list[[name]]
    # Extract config and ai from the name
    config_val <- str_extract(name, "(?<=landscape_config_)[0-9.]+") %>% as.numeric()
    
    df$landscape_config <- config_val
    return(df)
  }),
  .id = "id"
)