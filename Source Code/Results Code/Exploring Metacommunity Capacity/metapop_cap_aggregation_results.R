
rm(list=ls())


extract_results_to_df <- function(file_path) {
  # Load the RDS file
  results <- readRDS(file_path)
  
  # Initialize an empty list to store the results
  data_list <- list()
  
  # Iterate over each factor in the results
  for (factor_name in names(results)) {
    factor_data <- results[[factor_name]]
    
    for (i in seq_along(factor_data)) {
      replicate_data <- factor_data[[i]]
      
      # Extract required values
      habitat_cover <- replicate_data$results$landscape_cover
      metapop_cap <- replicate_data$results$metapop_cap
      alpha <- replicate_data$results$alpha
      mean_distance <- replicate_data$results$mean_distance
      
      data_list <- append(data_list, list(c(factor_name, habitat_cover, metapop_cap, alpha, mean_distance)))
    }
  }
  
  # Convert list to data frame
  final_df <- as.data.frame(do.call(rbind, data_list), stringsAsFactors = FALSE)
  colnames(final_df) <- c("movement", "habitat_cover", "metapop_cap", "alpha", "mean_distance")
  
  
  # Convert data types
  final_df$habitat_cover <- as.numeric(final_df$habitat_cover)
  final_df$metapop_cap <- as.numeric(final_df$metapop_cap)
  final_df$alpha <- as.numeric(final_df$alpha)
  final_df$movement <- as.factor(final_df$movement)
  final_df$mean_distance <- as.numeric(final_df$mean_distance)
  
  
  # Create column for mean dispersal distance
  final_df$mean_dispersal <- 1/final_df$alpha
  
  
  # Generate data frame name from file name
  file_parts <- unlist(strsplit(tools::file_path_sans_ext(basename(file_path)), "_"))
  
  # Take everything from the 3rd part onward
  if (length(file_parts) >= 3) {
    df_name <- paste(file_parts[3:length(file_parts)], collapse = "_")
  } else {
    df_name <- file_parts[length(file_parts)]  # fallback to last part
  }
  
  # Assign to global environment
  assign(df_name, final_df, envir = .GlobalEnv)
  
  return(final_df)
}



# Extract data ------------------------------------------------------------


extract_results_to_df("Results/Results_Folder/Exploring Metapopulation Capacity/Metapopulation Capacity Aggregation/result_ha")
extract_results_to_df("Results/Results_Folder/Exploring Metapopulation Capacity/Metapopulation Capacity Aggregation/result_ma")
extract_results_to_df("Results/Results_Folder/Exploring Metapopulation Capacity/Metapopulation Capacity Aggregation/result_la")

ha$agg <- "ha"
la$agg <- "la"
ma$agg <- "ma"

mean(ha$metapop_cap)
mean(ma$metapop_cap)
mean(la$metapop_cap)

df <- bind_rows(ha, la, ma)

ggplot(df, aes(x = (habitat_cover), y = (metapop_cap), shape = (agg), colour = agg)) +
  geom_point(alpha = 0.8) +
  labs( x = "Habitat Cover", y = "Difference", color = "Aggregation") +
  theme_minimal()


