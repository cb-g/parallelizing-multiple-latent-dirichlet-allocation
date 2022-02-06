# packages:
pkg <- rlang::quos(
  
  # general data handling:
  tidyverse, 
  
  # text data:
  quanteda, 
  quanteda.corpora, # devtools::install_github("quanteda/quanteda.corpora")
  
  # parallel computing: 
  parallel, # package ‘parallel’ is a base package
  doSNOW, 
  foreach,
  
  # latent dirichlet allocation:
  seededlda,
  
); invisible(lapply(lapply(pkg, rlang::quo_name), library, character.only = T))

# function abbreviations:
s <- dplyr::select; f <- filter

# info:
print(sessionInfo()) # R version 4.1.2 (2021-11-01)
                     # Platform: aarch64-apple-darwin20 (64-bit)
                     # Running under: macOS Monterey 12.2

# parallel computing:
Base_Integer_CPUCores <- detectCores()

# package version requirements: 
stopifnot(packageVersion('rlang') == '0.4.12')
stopifnot(packageVersion('tidyverse') == '1.3.1')
stopifnot(packageVersion('quanteda') == '3.2.0')
stopifnot(packageVersion('quanteda.corpora') == '0.9.2')
stopifnot(packageVersion('doSNOW') == '1.0.20')
stopifnot(packageVersion('foreach') == '1.5.2')
stopifnot(packageVersion('seededlda') == '0.8.0')

# reproducibility:
Base_Integer_Seed <- 27
set.seed(Base_Integer_Seed)

# foreach needs packages in vector:
Base_Vector_Packages <- vector()
for(i in 1:length(pkg)){
  Base_Vector_Packages[i] <- 
    rlang::quo_get_expr(pkg[[i]]) %>% 
    as.character()
}; rm(pkg)
