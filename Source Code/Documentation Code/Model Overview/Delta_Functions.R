rm(list = ls())


library(tidyverse)

# Define movement responses
# movement can be 'linear', 'concave', or 'convex'
movements <- c('linear', 'concave', 'convex')

# Define maximum movement increases (%)
movement_abilities <- c(10, 50, 100, 500, 1000, 5000)

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







# Plot delta curves -------------------------------------------------------


# Split the data by 'movement'
split_data <- split(delta_df, delta_df$movement)


# Extract the subset for the current movement type
linear <- split_data["linear"]
linear <- as.data.frame(linear)

# Plot delta vs habitat_cover for each movement_ability
ggplot(linear, aes(x = linear.habitat_cover, y = log(linear.delta), color = factor(linear.movement_ability))) +
  geom_point() +  # Plot data points
  geom_smooth(method = "loess", se = FALSE) +  # Add smooth line
  labs(title = paste("Delta vs Habitat Cover for linear"), 
       x = "Habitat Cover", 
       y = "log Delta", 
       color = "Movement Ability") + 
  theme_minimal()



# Extract the subset for the current movement type
convex <- split_data["convex"]
convex <- as.data.frame(convex)

# Plot delta vs habitat_cover for each movement_ability
ggplot(convex, aes(x = convex.habitat_cover, y = log(convex.delta), color = factor(convex.movement_ability))) +
  geom_point() +  # Plot data points
  geom_smooth(method = "loess", se = FALSE) +  # Add smooth line
  labs(title = paste("Delta vs Habitat Cover for convex"), 
       x = "Habitat Cover", 
       y = "log Delta", 
       color = "Movement Ability") + 
  theme_minimal()



# Extract the subset for the current movement type
concave <- split_data["concave"]
concave <- as.data.frame(concave)

# Plot delta vs habitat_cover for each movement_ability
ggplot(concave, aes(x = concave.habitat_cover, y = log(concave.delta), color = factor(concave.movement_ability))) +
  geom_point() +  # Plot data points
  geom_smooth(method = "loess", se = FALSE) +  # Add smooth line
  labs(title = paste("Delta vs Habitat Cover for concave"), 
       x = "Habitat Cover", 
       y = "log Delta", 
       color = "Movement Ability") + 
  theme_minimal()

