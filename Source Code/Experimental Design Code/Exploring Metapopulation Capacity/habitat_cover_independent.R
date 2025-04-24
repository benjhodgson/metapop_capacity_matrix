

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
alpha <- 0.05  # change as needed

distance_matrix_2 <- as.matrix(dist(points_2))
distance_matrix_5 <- as.matrix(dist(points_5))
distance_matrix_10 <- as.matrix(dist(points_10))

# Number of patches
n_patches_2 <- nrow(points_2)
n_patches_5 <- nrow(points_5)
n_patches_10 <- nrow(points_10)

# Create results dataframe
results_2 <- data.frame(
  habitat_area = numeric(),
  metapop_cap = numeric()
)
results_5 <- data.frame(
  habitat_area = numeric(),
  metapop_cap = numeric()
)
results_10 <- data.frame(
  habitat_area = numeric(),
  metapop_cap = numeric()
)


# Loop from habitat area 1 to 500 for 2 patches
for (a in 1:500) {
  
  # generate area matrix
  area_matrix <- matrix(a^2, nrow = n_patches_2, ncol = n_patches_2)
  
  dispersal_matrix <- exp(-alpha * distance_matrix_2)
  
  # multiply dispersal matrix by area matrix
  connectivity_matrix <- area_matrix * dispersal_matrix
  
  # extract eigenvalues
  eig <- eigen(connectivity_matrix)
  
  # find the leading eigenvalue
  leading_eig <- eig$values[1]
  
  # update results
  results_2 <- rbind(results_2, data.frame(habitat_area = a, metapop_cap = leading_eig))
}


# Loop from habitat area 1 to 500 for 5 patches
for (a in 1:500) {
  
  # generate area matrix
  area_matrix <- matrix(a^2, nrow = n_patches_5, ncol = n_patches_5)
  
  dispersal_matrix <- exp(-alpha * distance_matrix_5)
  
  # multiply dispersal matrix by area matrix
  connectivity_matrix <- area_matrix * dispersal_matrix
  
  # extract eigenvalues
  eig <- eigen(connectivity_matrix)
  
  # find the leading eigenvalue
  leading_eig <- eig$values[1]
  
  # update results
  results_5 <- rbind(results_5, data.frame(habitat_area = a, metapop_cap = leading_eig))
}



# Loop from habitat area 1 to 500 for 10 patches
for (a in 1:500) {
  
  # generate area matrix
  area_matrix <- matrix(a^2, nrow = n_patches_10, ncol = n_patches_10)
  
  
  dispersal_matrix <- exp(-alpha * distance_matrix_10)
  
  # multiply dispersal matrix by area matrix# Step 3: Connectivity matrix = area * dispersal
  connectivity_matrix <- area_matrix * dispersal_matrix
  
  # extract eigenvalues
  eig <- eigen(connectivity_matrix)
  
  # find the leading eigenvalue
  leading_eig <- eig$values[1]
  
  # update results
  results_10 <- rbind(results_10, data.frame(habitat_area = a, metapop_cap = leading_eig))
}







# Plot Graphs -------------------------------------------------------------

results_2$habitat_cover <- ((results_2$habitat_area * 2)/(100*100)) *100
results_5$habitat_cover <- ((results_5$habitat_area * 5)/(100*100)) *100
results_10$habitat_cover <- ((results_10$habitat_area * 10)/(100*100)) *100


# Plot Metapopulation Capacity

mp_1 <- ggplot(results_2, aes(x = habitat_cover, y = metapop_cap)) +
  geom_line() +
  labs(
    title = "2 Habitat Patches",
    x = "Habitat Cover (%)",
    y = "Metapopulation Capacity"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 10, face = "plain")
  )

mp_2 <- ggplot(results_5, aes(x = habitat_cover, y = metapop_cap)) +
  geom_line() +
  labs(
    title = "5 Habitat Patches",
    x = "Habitat Cover (%)",
    y = "Metapopulation Capacity"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 10, face = "plain")
  )

mp_3 <- ggplot(results_10, aes(x = habitat_cover, y = metapop_cap)) +
  geom_line() +
  labs(
    title = "10 Habitat Patches",
    x = "Habitat Cover (%)",
    y = "Metapopulation Capacity"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 10, face = "plain")
  )
  

mp_1 / mp_2 / mp_3


# Plot log metapopulation capacity

log_mp_1 <- ggplot(results_2, aes(x = habitat_cover, y = log(metapop_cap))) +
  geom_line() +
  labs(
    title = "2 Habitat Patches",
    x = "Habitat Cover (%)",
    y = "Log Metapopulation Capacity"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 10, face = "plain")
  )

log_mp_2 <- ggplot(results_5, aes(x = habitat_cover, y = log(metapop_cap))) +
  geom_line() +
  labs(
    title = "5 Habitat Patches",
    x = "Habitat Cover (%)",
    y = "Log Metapopulation Capacity"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 10, face = "plain")
  )

log_mp_3 <- ggplot(results_10, aes(x = habitat_cover, y = log(metapop_cap))) +
  geom_line() +
  labs(
    title = "10 Habitat Patches",
    x = "Habitat Cover (%)",
    y = "Log Metapopulation Capacity"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 10, face = "plain")
  )


log_mp_1 / log_mp_2 / log_mp_3


