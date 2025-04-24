

rm(list = ls())

library(tidyverse)
library(patchwork)


# Generate and Plot Habitat Patches ---------------------------------------


# Define 10 equally spaced habitat patches
points_10 <- data.frame(
  x = seq(0, 100, length.out = 10),
  y = seq(0, 100, length.out = 10)
)

# Define 5 equally spaced habitat patches
points_5 <- data.frame(
  x = seq(0, 100, length.out = 5),
  y = seq(0, 100, length.out = 5)
)

# Define 2 equally spaced habitat patches
points_2 <- data.frame(
  x = seq(0, 100, length.out = 2),
  y = seq(0, 100, length.out = 2)
)

# Plot the grid and points
p1 <- ggplot() +
  geom_point(data = points_10, aes(x = x, y = y), color = "darkgreen", size = 5) +
  coord_fixed() +
  theme_minimal() +
  labs(title = "10 Habitat Patches") +
  theme(
    panel.grid.minor = element_blank()
  )

p2 <- ggplot() +
  geom_point(data = points_5, aes(x = x, y = y), color = "darkgreen", size = 5) +
  coord_fixed() +
  theme_minimal() +
  labs(title = "5 Habitat Patches") +
  theme(
    panel.grid.minor = element_blank()
  )

p3 <- ggplot() +
  geom_point(data = points_2, aes(x = x, y = y), color = "darkgreen", size = 5) +
  coord_fixed() +
  theme_minimal() +
  labs(title = "2 Habitat Patches") +
  theme(
    panel.grid.minor = element_blank()
  )

p3 + p2 + p1



# Calculate Metapopulation Capacity ---------------------------------------

# Set alpha
alpha <- 0.05  

# Number of patches
n_patches_2 <- nrow(points_2)
n_patches_5 <- nrow(points_5)
n_patches_10 <- nrow(points_10)

distance_matrix_2 <- as.matrix(dist(points_2))
distance_matrix_5 <- as.matrix(dist(points_5))
distance_matrix_10 <- as.matrix(dist(points_10))

# Create results dataframe
results_2 <- data.frame(
  mean_distance = numeric(),
  metapop_cap = numeric()
)
results_5 <- data.frame(
  mean_distance = numeric(),
  metapop_cap = numeric()
)
results_10 <- data.frame(
  mean_distance = numeric(),
  metapop_cap = numeric()
)

# set area to 100 units
a <- 100

# Loop from distance multiplier of 1 to 500
for (d in seq(1, 5, by = 0.01)) {
  
  # generate area matrix
  area_matrix <- matrix(a^2, nrow = n_patches_2, ncol = n_patches_2)
  
  scaled_distance_matrix <- distance_matrix_2 *d
  
  dispersal_matrix <- exp(-alpha * scaled_distance_matrix)
  
  diag(dispersal_matrix) <- 0 # set diagonal back to 0
  
  # multiply dispersal matrix by area matrix
  connectivity_matrix <- area_matrix * dispersal_matrix
  
  # extract eigenvalues
  eig <- eigen(connectivity_matrix)
  
  # find the leading eigenvalue
  leading_eig <- eig$values[1]
  
  # calculate mean distance
  dist_vector <- scaled_distance_matrix[lower.tri(scaled_distance_matrix)]
  mean_distance <- mean(dist_vector)
  
  # update results
  results_2 <- rbind(results_2, data.frame(mean_distance = mean_distance, metapop_cap = leading_eig))
}


# Loop from distance multiplier of 1 to 500
for (d in seq(1, 5, by = 0.01)) {
  
  # generate area matrix
  area_matrix <- matrix(a^2, nrow = n_patches_5, ncol = n_patches_5)
  
  distance_matrix <- distance_matrix_5 *d
  
  dispersal_matrix <- exp(-alpha * distance_matrix)
  
  diag(dispersal_matrix) <- 0 # set diagonal back to 0
  
  # multiply dispersal matrix by area matrix
  connectivity_matrix <- area_matrix * dispersal_matrix
  
  # extract eigenvalues
  eig <- eigen(connectivity_matrix)
  
  # find the leading eigenvalue
  leading_eig <- eig$values[1]
  
  # calculate mean distance
  dist_vector <- distance_matrix[lower.tri(distance_matrix)]
  mean_distance <- mean(dist_vector)
  
  # update results
  results_5 <- rbind(results_5, data.frame(mean_distance = mean_distance, metapop_cap = leading_eig))
}




# Loop from distance multiplier of 1 to 500
for (d in seq(1, 5, by = 0.01)) {
  
  # generate area matrix
  area_matrix <- matrix(a^2, nrow = n_patches_10, ncol = n_patches_10)
  
  distance_matrix <- distance_matrix_10 *d
  
  dispersal_matrix <- exp(-alpha * distance_matrix)
  
  # multiply dispersal matrix by area matrix
  connectivity_matrix <- area_matrix * dispersal_matrix
  
  # extract eigenvalues
  eig <- eigen(connectivity_matrix)
  
  # find the leading eigenvalue
  leading_eig <- eig$values[1]
  
  # calculate mean distance
  dist_vector <- distance_matrix[lower.tri(distance_matrix)]
  mean_distance <- mean(dist_vector)
  
  # update results
  results_10 <- rbind(results_10, data.frame(mean_distance = mean_distance, metapop_cap = leading_eig))
}







# Plot Graphs -------------------------------------------------------------


# Plot Metapopulation Capacity

mp_1 <- ggplot(results_2, aes(x = mean_distance, y = metapop_cap)) +
  geom_line() +
  labs(
    title = "2 Habitat Patches",
    x = "Mean Distance between Patches",
    y = "Metapopulation Capacity"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 10, face = "plain")
  )

mp_2 <- ggplot(results_5, aes(x = mean_distance, y = metapop_cap)) +
  geom_line() +
  labs(
    title = "5 Habitat Patches",
    x = "Mean Distance between Patches",
    y = "Metapopulation Capacity"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 10, face = "plain")
  )

mp_3 <- ggplot(results_10, aes(x = mean_distance, y = metapop_cap)) +
  geom_line() +
  labs(
    title = "10 Habitat Patches",
    x = "Mean Distance between Patches",
    y = "Metapopulation Capacity"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 10, face = "plain")
  )


mp_1 / mp_2 / mp_3


# Plot log metapopulation capacity

log_mp_1 <- ggplot(results_2, aes(x = mean_distance, y = log(metapop_cap))) +
  geom_line() +
  labs(
    title = "2 Habitat Patches",
    x = "Mean Distance between Patches",
    y = "Log Metapopulation Capacity"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 10, face = "plain")
  )

log_mp_2 <- ggplot(results_5, aes(x = mean_distance, y = log(metapop_cap))) +
  geom_line() +
  labs(
    title = "5 Habitat Patches",
    x = "Mean Distance between Patches",
    y = "Log Metapopulation Capacity"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 10, face = "plain")
  )

log_mp_3 <- ggplot(results_10, aes(x = mean_distance, y = log(metapop_cap))) +
  geom_line() +
  labs(
    title = "10 Habitat Patches",
    x = "Mean Distance between Patches",
    y = "Log Metapopulation Capacity"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 10, face = "plain")
  )


log_mp_1 / log_mp_2 / log_mp_3


