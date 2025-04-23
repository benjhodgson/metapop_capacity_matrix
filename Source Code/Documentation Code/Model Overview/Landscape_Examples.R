
# Code to generate example landscapes -------------------------------------


# Prepare environment

install.packages("devtools")
library(devtools)

devtools::install_github("ropensci/NLMR")
install.packages("tidyverse", "raster")

library(NLMR)
library(tidyverse)
library(raster)


set.seed(123)

# set resolution and extent
resolution <- 1 # set resolution

x_extent <- 50 # set width
y_extent <- 50 # set height

# set habitat configuration and covers
landscape_config <- c(0.01, 0.2, 0.4) # level of patch aggregation

ai <- c(0.05, 0.2, 0.4) #  random proportion of landscape that is habitat between species bounds

landscape_params <- expand.grid(landscape_config = landscape_config, ai = ai)

# get list ready for results
landscape_list <- list()


# Loop through each landscape parameter set and generate a landscape.

for (i in seq_len(nrow(landscape_params))) {
  
  landscape_config <- landscape_params$landscape_config[i]
  ai <- landscape_params$ai[i]
  
  landscape <- nlm_randomcluster(ncol = x_extent, nrow = y_extent, 
                               resolution = resolution, 
                               p = landscape_config, 
                               ai = c((1-ai),ai))


  # # calculate edge_density
  # edge_density <- as.numeric(lsm_l_ed(landscape, count_boundary = FALSE, directions = 8)[6])

  # coerce to data frame
  landscape_df <- rasterToPoints(landscape, spatial = TRUE)
  landscape_df <- as.data.frame(landscape_df)
  colnames(landscape_df) <- c("layer", "x", "y")
  landscape_df$layer <- as.factor(landscape_df$layer)
  
  name <- paste0("landscape_config_", landscape_config, "_ai_", ai)
  landscape_list[[name]] <- landscape_df

}

# unwrap list to get a data frame
landscape_df <- bind_rows(
  lapply(names(landscape_list), function(name) {
    df <- landscape_list[[name]]
    # Extract config and ai from the name
    config_val <- str_extract(name, "(?<=landscape_config_)[0-9.]+") %>% as.numeric()
    ai_val <- str_extract(name, "(?<=ai_)[0-9.]+") %>% as.numeric()
    df$landscape_config <- config_val
    df$ai <- ai_val
    return(df)
  }),
  .id = "id"
)




# function to label landscapes
custom_labeller <- labeller(
  ai = function(x) paste0(as.numeric(x) * 100, "%"),
  landscape_config = function(x) paste0("p = ", x)
)

# plot graphs
ggplot(landscape_df, aes(x = x, y = y, fill = factor(layer))) +
  geom_raster() +
  scale_fill_manual(
    values = c("0" = "orange", "1" = "darkgreen"),
    labels = c("0" = "Non-habitat", "1" = "Habitat"),
    name = "Habitat"
  ) +
  coord_equal() +
  facet_grid(
    ai ~ landscape_config,
    labeller = custom_labeller,
    switch = "both"
  ) +
  labs(x = "Habitat Configuration", y = "Habitat Cover") +
  theme_minimal(base_size = 12) +
  theme(
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    axis.title = element_text(size = 12),
    strip.placement = "outside",
    strip.background = element_blank(),
    legend.position = "right",
    plot.title = element_blank()
  )