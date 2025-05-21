### Example code used within the User Guide document

rm(list = ls())

# General -----------------------------------------------------------------

# install.packages("devtools") # install devtools for packages not on CRAN
library(devtools)
# 
# # install packages
# install.packages(c("tidyverse", "sf", "units", "ggplot2", "gganimate",
#                    "igraph", "raster", "landscapemetrics", "units"))
# 
# install packages not on CRAN
devtools::install_github("ropensci/NLMR")
install.packages('RandomFields', repos =
                   'https://predictiveecology.r-universe.dev', type = 'source')

# load packages
library(tidyverse)
library(parallel)
library(NLMR)
library(RandomFields)
library(landscapemetrics)
library(igraph)
library(raster)
library(sf)
library(units)


# Start timer to measure model run speed
start_timer <- Sys.time()



# Loop for dispersal scenarios --------------------------------------------

# Parameterises model dispersal scenarios

# Define movement scenarios
# movement can be 'linear', 'convex', or 'concave'
movements <- c('linear', 'concave', 'convex')

# Define maximum movement increases (%)
movement_abilities <- c(10, 50, 100, 500, 1000, 5000)

# Create grid of movement scenarios
movement_combos <- expand.grid(movement = movements, movement_ability = movement_abilities)

# Create a new row for null movement
new_row <- data.frame(movement = "none", movement_ability = 0)

# Add the new row to the grid
movement_combos <- rbind(movement_combos, new_row)

# remove unnecessary variables
rm(movement_abilities, movements, new_row)


# set movement as a character
movement_combos$movement <- as.character(movement_combos$movement)

# Create dataframe of slope constants for movement scenarios
m <- c("linear", "linear", "linear", "linear", "linear", "linear", "concave", "concave", "concave", "concave", "concave", "concave", "convex", "convex", "convex", "convex", "convex", "convex")
m_a <- c("10", "50", "100", "500", "1000", "5000", "10", "50", "100", "500", "1000", "5000", "10", "50", "100", "500", "1000", "5000")
s1 <- c(0.1, 0.5, 1, 5, 10, 50, 0.1, 0.5, 1, 5, 10, 50, 4.54e-6, 2.27e-5, 4.54e-5, 2.27e-4, 4.53e-4, 0.00227)
s2 <- c(NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 0.99999546, 0, 0, 0, 0, 0.99773)
a <- c(1, 1, 1, 1, 1, 1, 0.1, 0.5, 1, 5, 10, 50, 0, 1, 1, 1, 1, 0)

slopes <- data.frame(m, m_a, s1, s2, a)

# remove unnecessary variables
rm(m, m_a, s1, s2, a)


# create final dataset list
result_final_complete <- list()

# creates a for loop for each of the movement combinations
for (j in 1:nrow(movement_combos)) {
  movement <- movement_combos$movement[j]
  movement_ability <- movement_combos$movement_ability[j]
  
  
  # wrap parameters into list for simulation function
  param_movement <- list(
    movement = movement,
    movement_ability = movement_ability
  )
  
  
  # Simulation Function -----------------------------------------------------
  
  
  # create a function for replicates of movement scenarios
  rep_function <- function(movement, movement_ability) {
    
    
    
    # Set Landscape Parameters ------------------------------------------------
    
    
    resolution <- 0.5 # set resolution
    
    x_extent <- 100 # set width
    y_extent <- 100 # set height
    
    landscape_config <- 0.4 # level of patch aggregation
    
    ai <- runif(1, min = 0.01, max = 0.45) #  random proportion of landscape that is habitat between species bounds
    
    # Set landscape productivity target
    productivity <- 0.5
    
    
    # Generate Landscape ------------------------------------------------------
    
    
    ## Habitat Patches ========================================================
    
    
    # create neutral landscape with >1 patch
    
    repeat {
      # generate landscape using NLMR package
      landscape <- nlm_randomcluster(ncol = x_extent, nrow = y_extent, 
                                     resolution = resolution, 
                                     p = landscape_config, 
                                     ai = c((1-ai),ai))
      
      # identify connected patches
      clumps <- clump(landscape, directions = 8)
      
      # calculate edge_density
      edge_density <- as.numeric(lsm_l_ed(landscape, count_boundary = FALSE, directions = 8)[6])
      
      # coerce to data frame
      landscape_df <- rasterToPoints(landscape, spatial = TRUE)
      landscape_df <- as.data.frame(landscape_df)
      colnames(landscape_df) <- c("layer", "x", "y")
      landscape_df$layer <- as.factor(landscape_df$layer)
      
      # add patch numbers to landscape df
      coordinates(landscape_df) <- ~x + y 
      landscape_df$patch <- extract(clumps, landscape_df)
      landscape_df <- as.data.frame(landscape_df)
      
      # Check the maximum patch number
      max_patch_number <- max(landscape_df$patch, na.rm = TRUE)
      
      # If there is more than one patch, exit the loop
      if (max_patch_number > 1) {
        break
      }
    }
    
    
    # calculate exact landscape cover
    landscape_cover <- (sum(landscape_df$layer == 1)/nrow(landscape_df))*100
    
    # remove unnecessary variables
    rm(clumps, landscape, max_patch_number)
    
    
    
    ## Calculate Distances and Areas ==========================================
    
    
    # Calculate distances
    
    # convert dataframe back to raster
    landscape_df_patches <- landscape_df %>%
      dplyr::select(x, y, patch)
    patch_raster <- rasterFromXYZ(landscape_df_patches)
    
    # remove unnecessary variables
    rm(landscape_df_patches) 
    
    # set resolution of raster in m
    res(patch_raster) <- c(0.5, 0.5)
    
    # set crs of raster
    crs(patch_raster) <- CRS("+proj=utm +zone=33 +datum=WGS84")
    
    # Convert raster to polygons
    habitat_polygons <- rasterToPolygons(patch_raster, fun = function(x) {x > 0}, dissolve = TRUE)
    habitat_polygons_sf <- st_as_sf(habitat_polygons)
    
    # remove unnecessary variables
    rm(habitat_polygons, patch_raster) 
    
    # Calculate the distance matrix between the edges of polygons
    dist_matrix <- st_distance(habitat_polygons_sf)
    
    # Check if dist_matrix has units and remove if necessary
    if (inherits(dist_matrix, "units")) {
      dist_matrix <- drop_units(dist_matrix)
    } else {
      dist_matrix <- dist_matrix
    }
    
    
    # find new patch numbers based on polygon data
    new_patch_numbers <- habitat_polygons_sf %>%
      st_drop_geometry()
    new_patch_numbers$index <- 1:nrow(new_patch_numbers)
    
    
    # update patch numbers to new numbers
    landscape_df <- landscape_df %>%
      left_join(new_patch_numbers, by = c("patch" = "patch"))
    
    
    # remove unnecessary variables
    rm(new_patch_numbers, habitat_polygons_sf) 
    
    # clean up landscape dataframe
    landscape_df <- landscape_df %>%
      dplyr::select(-patch) %>%    # Remove the 'patch' column
      rename(patch = index) 
    
    # patch number as a factor
    landscape_df$patch <- as.factor(landscape_df$patch)
    
    # Calculate habitat patch sizes
    patch_area_df <- landscape_df %>%
      filter(layer == 1) %>%  # Only consider habitat cells
      group_by(patch) %>%
      summarise(area = n())
    
    # view landscape
    ggplot(landscape_df, aes(x = x, y = y, fill = factor(layer))) +
      geom_tile() +
      scale_fill_manual(
        values = c("0" = "orange", "1" = "darkgreen"),
        name = "Layer"
      ) +
      theme_minimal() +
      theme(
        axis.text = element_blank(),   # Hide axis text
        axis.ticks = element_blank(),  # Hide axis ticks
        panel.grid = element_blank()   # Hide grid lines
      )
    
    # calculate mean habitat patch size and number of habitat patches
    mean_patch_size <- mean(patch_area_df$area)
    num_patches <- length(unique(landscape_df$patch)) - 1
    
    # calculate average distance between patches
    dist_vector <- dist_matrix[lower.tri(dist_matrix)]
    mean_distance <- mean(dist_vector)
    
    
    
    
    # Matrix Effects ----------------------------------------------------------
    
    # calculate agricultural yield
    
    yield <- productivity/(1-(landscape_cover/100))
    
    # normalise yield to get relative yield
    
    relative_yield <- (yield-productivity)/(1-productivity)
    
    
    # functions for calculating alpha (dispersal distance)
    
    
    # Linear
    linear_permeability <- function(y, s, a){ # y = yield, s = slope
      disp_factor = (((s*(1-y)) + a)) 
      return(disp_factor)
    }
    
    # Concave 
    conc_permeability <- function(y, s, a){
      disp_factor = (((-(y)^2*s) + 1)+a) 
      return(disp_factor)
    }
    
    # Convex
    conv_permeability <- function(y, s, s2, a){
      disp_factor = (((exp(10*(1-y)))*s)+s2) + a
      return(disp_factor)
    }
    
    
    
    # pick correct constants (slopes) for current movement scenario
    
    slope <- slopes %>% 
      filter(m == movement & m_a == movement_ability)
    slope <- as.numeric(slope[3])
    slope_2 <- slopes %>% 
      filter(m == movement & m_a == movement_ability)
    slope_2 <- as.numeric(slope_2[4])
    a <- slopes %>% 
      filter(m == movement & m_a == movement_ability)
    a <- as.numeric(a[5])
    
    
    # calculate dispersal multiplier
    
    if (movement == "linear") {
      dispersal_factor <- linear_permeability(y = relative_yield, s = slope, a = a)
    } else if (movement == "concave") {
      dispersal_factor <- conc_permeability(y = relative_yield, s = slope, a = a)
    } else if (movement == "convex") {
      dispersal_factor <- conv_permeability(y  = relative_yield, s = slope, s2 = slope_2, a = a)
    } else if (movement == "none") {
      dispersal_factor <- 1  # movement does not change with yield in null scenarios
    } else {
      print("No matching movement")
    }
    
    
    
    # Set model parameters ====================================================
    
    dispersal_intense <- 5
    dispersal <- dispersal_intense * dispersal_factor # set actual mean dispersal distance based on yield
    alpha <- 1/dispersal # sets alpha
    
    
    
    # Metapopulation Capacity Model -------------------------------------------
    
    metapop <- exp(-alpha * dist_matrix) # exponent of -alpha * distances
    diag(metapop) <- 0 # set diagonal back to 0
    
    area_matrix <- outer(patch_area_df$area, patch_area_df$area, FUN = "*")
    # create a matrix of area products
    
    metapop2 <- metapop * area_matrix # multiply metapop by areas of both habitat patches
    
    eig <- eigen(metapop2) # extract eigenvalues
    
    metapop_cap <- eig$values[1] # isolate leading eigenvalue
    
    # populates results
    results <- data.frame(
      metapop_cap = metapop_cap,
      alpha = alpha,
      dispersal_intense = dispersal_intense,
      resolution = resolution,
      x_extent = x_extent,
      y_extent = y_extent,
      landscape_config = landscape_config,
      landscape_cover = landscape_cover,
      edge_density = edge_density,
      mean_distance = mean_distance,
      num_patches = num_patches,
      mean_patch_size = mean_patch_size)
    
    # wraps results and landscape data into a list
    results_list <- list(
      results = results,
      landscape = landscape_df
    )
    
    # returns list of results
    return(results_list)
    
  }
  
  
  
  
  
  # Run Model ---------------------------------------------------------------
  
  
  set.seed(123) # sets the overall model seed so that landscapes are consistent between model runs
  
  num_reps <- 200 # specify the number of repeats
  
  seeds <- sample.int(1e6, num_reps) # choose seeds for landscapes
  
  # Set the number of cores for parallel processing
  num_cores <- 60
  
  # Use mclapply to apply the function 100 times in parallel
  result_final <- mclapply(1:num_reps, function(i) {
    
    set.seed(seeds[i]) # set the rep-specific seed
    
    # Apply the function with the parameters passed from the list
    do.call(rep_function, param_movement)
  }, mc.cores = num_cores)
  
  
  result_final_name <- paste("result_final", movement, movement_ability, sep = "_")
  
  assign(result_final_name, result_final)
  
  result_final_complete[[result_final_name]] <- result_final
  
  cat(movement, movement_ability, " ")
  
}


# print duration of program run
print( Sys.time() - start_timer)

# Save outputs ------------------------------------------------------------

saveRDS(result_final_complete, file = "Result_Final_ha_hd")
