
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
      
      data_list <- append(data_list, list(c(factor_name, habitat_cover, metapop_cap, alpha)))
    }
  }
  
  # Convert list to data frame
  final_df <- as.data.frame(do.call(rbind, data_list), stringsAsFactors = FALSE)
  colnames(final_df) <- c("movement", "habitat_cover", "metapop_cap", "alpha")
  
  
  # Convert data types
  final_df$habitat_cover <- as.numeric(final_df$habitat_cover)
  final_df$metapop_cap <- as.numeric(final_df$metapop_cap)
  final_df$alpha <- as.numeric(final_df$alpha)
  final_df$movement <- as.factor(final_df$movement)
  
  
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


extract_results_to_df("Results/Results_Folder/Matrix Permeability and Metapopulation Capacity/Model 1/ha/Result_Final_ha_vhd")
extract_results_to_df("Results/Results_Folder/Matrix Permeability and Metapopulation Capacity/Model 1/ha/Result_Final_ha_hd")
extract_results_to_df("Results/Results_Folder/Matrix Permeability and Metapopulation Capacity/Model 1/ha/Result_Final_ha_md")
extract_results_to_df("Results/Results_Folder/Matrix Permeability and Metapopulation Capacity/Model 1/ha/Result_Final_ha_ld")
extract_results_to_df("Results/Results_Folder/Matrix Permeability and Metapopulation Capacity/Model 1/ha/Result_Final_ha_vld")

extract_results_to_df("Results/Results_Folder/Matrix Permeability and Metapopulation Capacity/Model 1/ma/Result_Final_ma_vhd")
extract_results_to_df("Results/Results_Folder/Matrix Permeability and Metapopulation Capacity/Model 1/ma/Result_Final_ma_hd")
extract_results_to_df("Results/Results_Folder/Matrix Permeability and Metapopulation Capacity/Model 1/ma/Result_Final_ma_md")
extract_results_to_df("Results/Results_Folder/Matrix Permeability and Metapopulation Capacity/Model 1/ma/Result_Final_ma_ld")
extract_results_to_df("Results/Results_Folder/Matrix Permeability and Metapopulation Capacity/Model 1/ma/Result_Final_ma_vld")

extract_results_to_df("Results/Results_Folder/Matrix Permeability and Metapopulation Capacity/Model 1/la/Result_Final_la_vhd")
extract_results_to_df("Results/Results_Folder/Matrix Permeability and Metapopulation Capacity/Model 1/la/Result_Final_la_hd")
extract_results_to_df("Results/Results_Folder/Matrix Permeability and Metapopulation Capacity/Model 1/la/Result_Final_la_md")
extract_results_to_df("Results/Results_Folder/Matrix Permeability and Metapopulation Capacity/Model 1/la/Result_Final_la_ld")
extract_results_to_df("Results/Results_Folder/Matrix Permeability and Metapopulation Capacity/Model 1/la/Result_Final_la_vld")





# Write data to CSV -------------------------------------------------------



write.csv(ha_vhd, "Results/Results_Folder/Matrix Permeability and Metapopulation Capacity/Model 1/ha_csv/ha_vhd.csv", row.names = FALSE)
write.csv(ha_hd, "Results/Results_Folder/Matrix Permeability and Metapopulation Capacity/Model 1/ha_csv/ha_hd.csv", row.names = FALSE)
write.csv(ha_md, "Results/Results_Folder/Matrix Permeability and Metapopulation Capacity/Model 1/ha_csv/ha_md.csv", row.names = FALSE)
write.csv(ha_ld, "Results/Results_Folder/Matrix Permeability and Metapopulation Capacity/Model 1/ha_csv/ha_ld.csv", row.names = FALSE)
write.csv(ha_vld, "Results/Results_Folder/Matrix Permeability and Metapopulation Capacity/Model 1/ha_csv/ha_vld.csv", row.names = FALSE)

write.csv(ma_vhd, "Results/Results_Folder/Matrix Permeability and Metapopulation Capacity/Model 1/ma_csv/ma_vhd.csv", row.names = FALSE)
write.csv(ma_hd, "Results/Results_Folder/Matrix Permeability and Metapopulation Capacity/Model 1/ma_csv/ma_hd.csv", row.names = FALSE)
write.csv(ma_md, "Results/Results_Folder/Matrix Permeability and Metapopulation Capacity/Model 1/ma_csv/ma_md.csv", row.names = FALSE)
write.csv(ma_ld, "Results/Results_Folder/Matrix Permeability and Metapopulation Capacity/Model 1/ma_csv/ma_ld.csv", row.names = FALSE)
write.csv(ma_vld, "Results/Results_Folder/Matrix Permeability and Metapopulation Capacity/Model 1/ma_csv/ma_vld.csv", row.names = FALSE)

write.csv(la_vhd, "Results/Results_Folder/Matrix Permeability and Metapopulation Capacity/Model 1/la_csv/la_vhd.csv", row.names = FALSE)
write.csv(la_hd, "Results/Results_Folder/Matrix Permeability and Metapopulation Capacity/Model 1/la_csv/la_hd.csv", row.names = FALSE)
write.csv(la_md, "Results/Results_Folder/Matrix Permeability and Metapopulation Capacity/Model 1/la_csv/la_md.csv", row.names = FALSE)
write.csv(la_ld, "Results/Results_Folder/Matrix Permeability and Metapopulation Capacity/Model 1/la_csv/la_ld.csv", row.names = FALSE)
write.csv(la_vld, "Results/Results_Folder/Matrix Permeability and Metapopulation Capacity/Model 1/la_csv/la_vld.csv", row.names = FALSE)




