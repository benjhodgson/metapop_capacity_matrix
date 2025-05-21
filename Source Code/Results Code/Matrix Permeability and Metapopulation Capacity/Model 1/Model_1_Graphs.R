
rm(list=ls())


# Import Data -------------------------------------------------------------

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






# Plot Metapopulation Capacities ------------------------------------------

library(ggplot2)
library(grid)
library(patchwork)

# Function for plotting graphs

plot_metapop_vs_cover <- function(df, df_name) {
  p <- ggplot(df, aes(x = habitat_cover, y = log(metapop_cap), colour = movement)) +
    geom_point() +
    geom_smooth(method = "gam", se = FALSE) +
    labs(
      x = "Habitat Cover",
      y = "log Metapopulation Capacity",
      color = "Movement Factor"
    ) +
    theme_minimal()
  
  # Create name like ha_vhd_plot and assign plot object to it in global environment
  plot_name <- paste0(df_name, "_plot")
  assign(plot_name, p, envir = .GlobalEnv)
}


# Function for dispersal labels

dispersal_label <- function(df_name) {
  level_code <- strsplit(df_name, "_")[[1]][2]
  switch(
    level_code,
    "vhd" = "Very High Dispersal",
    "hd" = "High Dispersal",
    "md" = "Medium Dispersal",
    "ld" = "Low Dispersal",
    "vld" = "Very Low Dispersal",
    level_code  # fallback
  )
}




# High Aggregation Plots --------------------------------------------------


# Plot for 50% increase ---------------------------------------------------

# Filter for 50% increases
ha_vhd_50 <- ha_vhd[grepl("50$", as.character(ha_hd$movement)), ]
ha_hd_50 <- ha_hd[grepl("50$", as.character(ha_hd$movement)), ]
ha_md_50 <- ha_md[grepl("50$", as.character(ha_hd$movement)), ]
ha_ld_50 <- ha_ld[grepl("50$", as.character(ha_hd$movement)), ]
ha_vld_50 <- ha_vld[grepl("50$", as.character(ha_hd$movement)), ]


plot_metapop_vs_cover(ha_vhd_50, "ha_vhd_50")
plot_metapop_vs_cover(ha_hd_50, "ha_hd_50")
plot_metapop_vs_cover(ha_md_50, "ha_md_50")
plot_metapop_vs_cover(ha_ld_50, "ha_ld_50")
plot_metapop_vs_cover(ha_vld_50, "ha_vld_50")



# Create labeled plots
ha_vhd_labeled_50 <- ha_vhd_50_plot + ggtitle(dispersal_label("ha_vhd"))
ha_hd_labeled_50 <- ha_hd_50_plot + ggtitle(dispersal_label("ha_hd"))
ha_md_labeled_50 <- ha_md_50_plot + ggtitle(dispersal_label("ha_md"))
ha_ld_labeled_50 <- ha_ld_50_plot + ggtitle(dispersal_label("ha_ld"))
ha_vld_labeled_50 <- ha_vld_50_plot + ggtitle(dispersal_label("ha_vld"))


# Combine them with shared legend
combined_plot <- (
  ha_vhd_labeled_50 + ha_hd_labeled_50 + ha_md_labeled_50
) / (
  ha_ld_labeled_50 + ha_vld_labeled_50 + plot_spacer()
) +
  plot_layout(guides = "collect") &
  theme(legend.position = "bottom")

# Display
combined_plot




# Plot for 500% increase ---------------------------------------------------

# Filter for 500% increases
ha_vhd_500 <- ha_vhd[grepl("500$", as.character(ha_hd$movement)), ]
ha_hd_500 <- ha_hd[grepl("500$", as.character(ha_hd$movement)), ]
ha_md_500 <- ha_md[grepl("500$", as.character(ha_hd$movement)), ]
ha_ld_500 <- ha_ld[grepl("500$", as.character(ha_hd$movement)), ]
ha_vld_500 <- ha_vld[grepl("500$", as.character(ha_hd$movement)), ]


plot_metapop_vs_cover(ha_vhd_500, "ha_vhd_500")
plot_metapop_vs_cover(ha_hd_500, "ha_hd_500")
plot_metapop_vs_cover(ha_md_500, "ha_md_500")
plot_metapop_vs_cover(ha_ld_500, "ha_ld_500")
plot_metapop_vs_cover(ha_vld_500, "ha_vld_500")



# Create labeled plots
ha_vhd_labeled_500 <- ha_vhd_500_plot + ggtitle(dispersal_label("ha_vhd"))
ha_hd_labeled_500 <- ha_hd_500_plot + ggtitle(dispersal_label("ha_hd"))
ha_md_labeled_500 <- ha_md_500_plot + ggtitle(dispersal_label("ha_md"))
ha_ld_labeled_500 <- ha_ld_500_plot + ggtitle(dispersal_label("ha_ld"))
ha_vld_labeled_500 <- ha_vld_500_plot + ggtitle(dispersal_label("ha_vld"))


# Combine them with shared legend
combined_plot <- (
  ha_vhd_labeled_500 + ha_hd_labeled_500 + ha_md_labeled_500
) / (
  ha_ld_labeled_500 + ha_vld_labeled_500 + plot_spacer()
) +
  plot_layout(guides = "collect") &
  theme(legend.position = "bottom")

# Display
combined_plot




# Plot for 5000% increase ---------------------------------------------------

# Filter for 5000% increases
ha_vhd_5000 <- ha_vhd[grepl("5000$", as.character(ha_hd$movement)), ]
ha_hd_5000 <- ha_hd[grepl("5000$", as.character(ha_hd$movement)), ]
ha_md_5000 <- ha_md[grepl("5000$", as.character(ha_hd$movement)), ]
ha_ld_5000 <- ha_ld[grepl("5000$", as.character(ha_hd$movement)), ]
ha_vld_5000 <- ha_vld[grepl("5000$", as.character(ha_hd$movement)), ]


plot_metapop_vs_cover(ha_vhd_5000, "ha_vhd_5000")
plot_metapop_vs_cover(ha_hd_5000, "ha_hd_5000")
plot_metapop_vs_cover(ha_md_5000, "ha_md_5000")
plot_metapop_vs_cover(ha_ld_5000, "ha_ld_5000")
plot_metapop_vs_cover(ha_vld_5000, "ha_vld_5000")



# Create labeled plots
ha_vhd_labeled_5000 <- ha_vhd_5000_plot + ggtitle(dispersal_label("ha_vhd"))
ha_hd_labeled_5000 <- ha_hd_5000_plot + ggtitle(dispersal_label("ha_hd"))
ha_md_labeled_5000 <- ha_md_5000_plot + ggtitle(dispersal_label("ha_md"))
ha_ld_labeled_5000 <- ha_ld_5000_plot + ggtitle(dispersal_label("ha_ld"))
ha_vld_labeled_5000 <- ha_vld_5000_plot + ggtitle(dispersal_label("ha_vld"))


# Combine them with shared legend
combined_plot <- (
  ha_vhd_labeled_5000 + ha_hd_labeled_5000 + ha_md_labeled_5000
) / (
  ha_ld_labeled_5000 + ha_vld_labeled_5000 + plot_spacer()
) +
  plot_layout(guides = "collect") &
  theme(legend.position = "bottom")

# Display
combined_plot









# Medium Aggregation Plots --------------------------------------------------


# Plot for 50% increase ---------------------------------------------------

# Filter for 50% increases
ma_vhd_50 <- ma_vhd[grepl("50$", as.character(ma_hd$movement)), ]
ma_hd_50 <- ma_hd[grepl("50$", as.character(ma_hd$movement)), ]
ma_md_50 <- ma_md[grepl("50$", as.character(ma_hd$movement)), ]
ma_ld_50 <- ma_ld[grepl("50$", as.character(ma_hd$movement)), ]
ma_vld_50 <- ma_vld[grepl("50$", as.character(ma_hd$movement)), ]


plot_metapop_vs_cover(ma_vhd_50, "ma_vhd_50")
plot_metapop_vs_cover(ma_hd_50, "ma_hd_50")
plot_metapop_vs_cover(ma_md_50, "ma_md_50")
plot_metapop_vs_cover(ma_ld_50, "ma_ld_50")
plot_metapop_vs_cover(ma_vld_50, "ma_vld_50")



# Create labeled plots
ma_vhd_labeled_50 <- ma_vhd_50_plot + ggtitle(dispersal_label("ma_vhd"))
ma_hd_labeled_50 <- ma_hd_50_plot + ggtitle(dispersal_label("ma_hd"))
ma_md_labeled_50 <- ma_md_50_plot + ggtitle(dispersal_label("ma_md"))
ma_ld_labeled_50 <- ma_ld_50_plot + ggtitle(dispersal_label("ma_ld"))
ma_vld_labeled_50 <- ma_vld_50_plot + ggtitle(dispersal_label("ma_vld"))


# Combine them with smared legend
combined_plot <- (
  ma_vhd_labeled_50 + ma_hd_labeled_50 + ma_md_labeled_50
) / (
  ma_ld_labeled_50 + ma_vld_labeled_50 + plot_spacer()
) +
  plot_layout(guides = "collect") &
  theme(legend.position = "bottom")

# Display
combined_plot




# Plot for 500% increase ---------------------------------------------------

# Filter for 500% increases
ma_vhd_500 <- ma_vhd[grepl("500$", as.character(ma_hd$movement)), ]
ma_hd_500 <- ma_hd[grepl("500$", as.character(ma_hd$movement)), ]
ma_md_500 <- ma_md[grepl("500$", as.character(ma_hd$movement)), ]
ma_ld_500 <- ma_ld[grepl("500$", as.character(ma_hd$movement)), ]
ma_vld_500 <- ma_vld[grepl("500$", as.character(ma_hd$movement)), ]


plot_metapop_vs_cover(ma_vhd_500, "ma_vhd_500")
plot_metapop_vs_cover(ma_hd_500, "ma_hd_500")
plot_metapop_vs_cover(ma_md_500, "ma_md_500")
plot_metapop_vs_cover(ma_ld_500, "ma_ld_500")
plot_metapop_vs_cover(ma_vld_500, "ma_vld_500")



# Create labeled plots
ma_vhd_labeled_500 <- ma_vhd_500_plot + ggtitle(dispersal_label("ma_vhd"))
ma_hd_labeled_500 <- ma_hd_500_plot + ggtitle(dispersal_label("ma_hd"))
ma_md_labeled_500 <- ma_md_500_plot + ggtitle(dispersal_label("ma_md"))
ma_ld_labeled_500 <- ma_ld_500_plot + ggtitle(dispersal_label("ma_ld"))
ma_vld_labeled_500 <- ma_vld_500_plot + ggtitle(dispersal_label("ma_vld"))


# Combine them with smared legend
combined_plot <- (
  ma_vhd_labeled_500 + ma_hd_labeled_500 + ma_md_labeled_500
) / (
  ma_ld_labeled_500 + ma_vld_labeled_500 + plot_spacer()
) +
  plot_layout(guides = "collect") &
  theme(legend.position = "bottom")

# Display
combined_plot




# Plot for 5000% increase ---------------------------------------------------

# Filter for 5000% increases
ma_vhd_5000 <- ma_vhd[grepl("5000$", as.character(ma_hd$movement)), ]
ma_hd_5000 <- ma_hd[grepl("5000$", as.character(ma_hd$movement)), ]
ma_md_5000 <- ma_md[grepl("5000$", as.character(ma_hd$movement)), ]
ma_ld_5000 <- ma_ld[grepl("5000$", as.character(ma_hd$movement)), ]
ma_vld_5000 <- ma_vld[grepl("5000$", as.character(ma_hd$movement)), ]


plot_metapop_vs_cover(ma_vhd_5000, "ma_vhd_5000")
plot_metapop_vs_cover(ma_hd_5000, "ma_hd_5000")
plot_metapop_vs_cover(ma_md_5000, "ma_md_5000")
plot_metapop_vs_cover(ma_ld_5000, "ma_ld_5000")
plot_metapop_vs_cover(ma_vld_5000, "ma_vld_5000")



# Create labeled plots
ma_vhd_labeled_5000 <- ma_vhd_5000_plot + ggtitle(dispersal_label("ma_vhd"))
ma_hd_labeled_5000 <- ma_hd_5000_plot + ggtitle(dispersal_label("ma_hd"))
ma_md_labeled_5000 <- ma_md_5000_plot + ggtitle(dispersal_label("ma_md"))
ma_ld_labeled_5000 <- ma_ld_5000_plot + ggtitle(dispersal_label("ma_ld"))
ma_vld_labeled_5000 <- ma_vld_5000_plot + ggtitle(dispersal_label("ma_vld"))


# Combine them with smared legend
combined_plot <- (
  ma_vhd_labeled_5000 + ma_hd_labeled_5000 + ma_md_labeled_5000
) / (
  ma_ld_labeled_5000 + ma_vld_labeled_5000 + plot_spacer()
) +
  plot_layout(guides = "collect") &
  theme(legend.position = "bottom")

# Display
combined_plot







# Low Aggregation Plots --------------------------------------------------


# Plot for 50% increase ---------------------------------------------------

# Filter for 50% increases
la_vhd_50 <- la_vhd[grepl("50$", as.character(la_hd$movement)), ]
la_hd_50 <- la_hd[grepl("50$", as.character(la_hd$movement)), ]
la_md_50 <- la_md[grepl("50$", as.character(la_hd$movement)), ]
la_ld_50 <- la_ld[grepl("50$", as.character(la_hd$movement)), ]
la_vld_50 <- la_vld[grepl("50$", as.character(la_hd$movement)), ]


plot_metapop_vs_cover(la_vhd_50, "la_vhd_50")
plot_metapop_vs_cover(la_hd_50, "la_hd_50")
plot_metapop_vs_cover(la_md_50, "la_md_50")
plot_metapop_vs_cover(la_ld_50, "la_ld_50")
plot_metapop_vs_cover(la_vld_50, "la_vld_50")



# Create labeled plots
la_vhd_labeled_50 <- la_vhd_50_plot + ggtitle(dispersal_label("la_vhd"))
la_hd_labeled_50 <- la_hd_50_plot + ggtitle(dispersal_label("la_hd"))
la_md_labeled_50 <- la_md_50_plot + ggtitle(dispersal_label("la_md"))
la_ld_labeled_50 <- la_ld_50_plot + ggtitle(dispersal_label("la_ld"))
la_vld_labeled_50 <- la_vld_50_plot + ggtitle(dispersal_label("la_vld"))


# Combine them with slared legend
combined_plot <- (
  la_vhd_labeled_50 + la_hd_labeled_50 + la_md_labeled_50
) / (
  la_ld_labeled_50 + la_vld_labeled_50 + plot_spacer()
) +
  plot_layout(guides = "collect") &
  theme(legend.position = "bottom")

# Display
combined_plot




# Plot for 500% increase ---------------------------------------------------

# Filter for 500% increases
la_vhd_500 <- la_vhd[grepl("500$", as.character(la_hd$movement)), ]
la_hd_500 <- la_hd[grepl("500$", as.character(la_hd$movement)), ]
la_md_500 <- la_md[grepl("500$", as.character(la_hd$movement)), ]
la_ld_500 <- la_ld[grepl("500$", as.character(la_hd$movement)), ]
la_vld_500 <- la_vld[grepl("500$", as.character(la_hd$movement)), ]


plot_metapop_vs_cover(la_vhd_500, "la_vhd_500")
plot_metapop_vs_cover(la_hd_500, "la_hd_500")
plot_metapop_vs_cover(la_md_500, "la_md_500")
plot_metapop_vs_cover(la_ld_500, "la_ld_500")
plot_metapop_vs_cover(la_vld_500, "la_vld_500")



# Create labeled plots
la_vhd_labeled_500 <- la_vhd_500_plot + ggtitle(dispersal_label("la_vhd"))
la_hd_labeled_500 <- la_hd_500_plot + ggtitle(dispersal_label("la_hd"))
la_md_labeled_500 <- la_md_500_plot + ggtitle(dispersal_label("la_md"))
la_ld_labeled_500 <- la_ld_500_plot + ggtitle(dispersal_label("la_ld"))
la_vld_labeled_500 <- la_vld_500_plot + ggtitle(dispersal_label("la_vld"))


# Combine them with slared legend
combined_plot <- (
  la_vhd_labeled_500 + la_hd_labeled_500 + la_md_labeled_500
) / (
  la_ld_labeled_500 + la_vld_labeled_500 + plot_spacer()
) +
  plot_layout(guides = "collect") &
  theme(legend.position = "bottom")

# Display
combined_plot




# Plot for 5000% increase ---------------------------------------------------

# Filter for 5000% increases
la_vhd_5000 <- la_vhd[grepl("5000$", as.character(la_hd$movement)), ]
la_hd_5000 <- la_hd[grepl("5000$", as.character(la_hd$movement)), ]
la_md_5000 <- la_md[grepl("5000$", as.character(la_hd$movement)), ]
la_ld_5000 <- la_ld[grepl("5000$", as.character(la_hd$movement)), ]
la_vld_5000 <- la_vld[grepl("5000$", as.character(la_hd$movement)), ]


plot_metapop_vs_cover(la_vhd_5000, "la_vhd_5000")
plot_metapop_vs_cover(la_hd_5000, "la_hd_5000")
plot_metapop_vs_cover(la_md_5000, "la_md_5000")
plot_metapop_vs_cover(la_ld_5000, "la_ld_5000")
plot_metapop_vs_cover(la_vld_5000, "la_vld_5000")



# Create labeled plots
la_vhd_labeled_5000 <- la_vhd_5000_plot + ggtitle(dispersal_label("la_vhd"))
la_hd_labeled_5000 <- la_hd_5000_plot + ggtitle(dispersal_label("la_hd"))
la_md_labeled_5000 <- la_md_5000_plot + ggtitle(dispersal_label("la_md"))
la_ld_labeled_5000 <- la_ld_5000_plot + ggtitle(dispersal_label("la_ld"))
la_vld_labeled_5000 <- la_vld_5000_plot + ggtitle(dispersal_label("la_vld"))


# Combine them with slared legend
combined_plot <- (
  la_vhd_labeled_5000 + la_hd_labeled_5000 + la_md_labeled_5000
) / (
  la_ld_labeled_5000 + la_vld_labeled_5000 + plot_spacer()
) +
  plot_layout(guides = "collect") &
  theme(legend.position = "bottom")

# Display
combined_plot
