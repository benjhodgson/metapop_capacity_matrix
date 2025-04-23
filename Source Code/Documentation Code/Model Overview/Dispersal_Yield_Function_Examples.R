library(tidyverse)

# Define parameters
movements <- c('linear', 'concave', 'convex')
movement_abilities <- c(1.5, 6, 11)

# Slope constants
slopes <- data.frame(
  m = c("linear", "linear", "linear", 
        "concave", "concave", "concave", 
        "convex", "convex", "convex"),
  m_a = c(1.5, 6, 11, 
          1.5, 6, 11, 
          1.5, 6, 11),
  s1 = c(0.5, 5, 10, 
         0.5, 5, 10, 
         2.27e-5, 2.27e-4, 4.53e-4),
  s2 = c(NA, NA, NA, 
         NA, NA, NA, 
         0, 0, 0),
  a = c(1, 1, 1, 
        0.5, 5, 10, 
        1, 1, 1)
)

# Define permeability functions
linear_permeability <- function(y, s, a) {
  (s * (1 - y)) + a
}

conc_permeability <- function(y, s, a) {
  (-(y^2) * s + 1) + a
}

conv_permeability <- function(y, s, s2, a) {
  ((exp(10 * (1 - y)) * s) + s2) + a
}

# Create grid
grid <- expand.grid(
  y = seq(0, 1, length.out = 100),
  movement = movements,
  movement_ability = movement_abilities,
  KEEP.OUT.ATTRS = FALSE
)

# Merge with slope constants
df <- left_join(grid, slopes, by = c("movement" = "m", "movement_ability" = "m_a"))

# Evaluate functions
df <- df %>%
  rowwise() %>%
  mutate(
    disp_factor = case_when(
      movement == "linear"  ~ linear_permeability(y, s1, a),
      movement == "concave" ~ conc_permeability(y, s1, a),
      movement == "convex"  ~ conv_permeability(y, s1, s2, a),
      TRUE ~ NA_real_
    )
  ) %>%
  ungroup()

# Custom labeller for facet titles
label_movement_ability <- function(variable, value) {
  paste("Movement Ability:", value)
}

# Movement colors
movement_colors <- c('linear' = 'blue', 'concave' = 'red', 'convex' = 'green')

# Plot
ggplot(df, aes(x = y, y = disp_factor, color = movement)) +
  geom_line(linewidth = 1) +
  facet_wrap(~ movement_ability,
             nrow = 1,
             scales = "free_y",
             labeller = labeller(movement_ability = function(x) paste0(x, "x"))) +
  scale_color_manual(values = movement_colors, name = "Movement Type") +
  scale_x_continuous(breaks = seq(0, 1, 0.2),
                     labels = scales::label_number(accuracy = 0.1)) +
  expand_limits(y = c(0, 12)) + 
  labs(
    x = " Relative Yield",
    y = "Mean Dispersal Distance"
  ) +
 theme_minimal(base_size = 13) +
theme(
  panel.grid = element_blank(),
  axis.line = element_line(),
  panel.border = element_blank(),
  strip.text = element_text(face = "plain", size = 10),
  axis.title.y = element_text(margin = margin(r = 10))
)
