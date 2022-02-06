
# alternating amount of topics: -------------------------------------------


# clean slate:
rm(list = ls())

# requirements:
source('setup.R')

# create document feature matrix:
Quanteda_DocumentFeatureMatrix_TextData <- 
  quanteda.corpora::data_corpus_ungd2017 %>% # UN General Debate speeches, 2017
  quanteda::tokens(
    remove_punct = T,
    remove_symbols = T,
    remove_numbers = T
  ) %>% 
  dfm() %>% 
  dfm_keep(min_nchar = 2) %>% 
  dfm_remove(stopwords('en')) %>% 
  dfm_trim(
    min_termfreq = 0.90,
    termfreq_type = "quantile"
  ) %>%
  dfm_tfidf(scheme_tf = "prop")

# how many different amounts of topics to try out:
Base_Integer_K_N <- 12

# telling the progress bar how many iterations constitute 100%: 
Base_Integer_Max <- Base_Integer_K_N

# amount of topics range:
Base_Integer_Range <- 5:30
Base_Vector_K <- sample(x = Base_Integer_Range, size = Base_Integer_K_N)

# parallel computing: 
start <- Sys.time(); cl <- makeCluster(Base_Integer_CPUCores); registerDoSNOW(cl);
invisible(capture.output(pb <- txtProgressBar(max = Base_Integer_Max, style = 3)));
progress <- function(n) setTxtProgressBar(pb, n); opts <- list(progress = progress);
results <- 
  
  foreach(
    k = Base_Vector_K,
    .combine = data.frame,
    .packages = Base_Vector_Packages,
    .options.snow = opts
  ) %dopar% {
    
    set.seed(Base_Integer_Seed)
    
    Base_List_UnseededLatentDirichletAllocation <- 
      textmodel_lda(
        x = Quanteda_DocumentFeatureMatrix_TextData %>% 
          head(0.5*ndoc(Quanteda_DocumentFeatureMatrix_TextData)),
        k = k,
        max_iter = 2000, # for Gibbs sampling
        alpha = runif(1), # random alpha
        beta = runif(1) # random beta
      )
    
    Base_Factor_PredictedTopics <- 
      predict(
        Base_List_UnseededLatentDirichletAllocation,
        newdata = Quanteda_DocumentFeatureMatrix_TextData %>% 
          tail(0.5*ndoc(Quanteda_DocumentFeatureMatrix_TextData)),
      )
    
  }; stopCluster(cl); close(pb); end <- Sys.time(); print(end-start)

# topics:
head(results, 10)



# alternating hyperparameters: --------------------------------------------


# clean slate:
rm(list = ls())

# requirements:
source('setup.R')

# create document feature matrix:
Quanteda_DocumentFeatureMatrix_TextData <- 
  quanteda.corpora::data_corpus_ungd2017 %>% # UN General Debate speeches, 2017
  quanteda::tokens(
    remove_punct = T,
    remove_symbols = T,
    remove_numbers = T
  ) %>% 
  dfm() %>% 
  dfm_keep(min_nchar = 2) %>% 
  dfm_remove(stopwords('en')) %>% 
  dfm_trim(
    min_termfreq = 0.90,
    termfreq_type = "quantile"
  ) %>%
  dfm_tfidf(scheme_tf = "prop")

# amount of topics:
Base_Integer_K <- 20

# amount of alpha values to try out:
Base_Integer_Alpha_N <- 7

# amount of beta values to try out:
Base_Integer_Beta_N <- 5

# telling the progress bar how many iterations constitute 100%: 
Base_Integer_Max <- Base_Integer_Alpha_N * Base_Integer_Beta_N

# alternating hyperparameters
Base_Vector_Alpha <- runif(Base_Integer_Alpha_N)
Base_Vector_Beta <- runif(Base_Integer_Beta_N)

# parallel computing: 
start <- Sys.time(); cl <- makeCluster(Base_Integer_CPUCores); registerDoSNOW(cl);
invisible(capture.output(pb <- txtProgressBar(max = Base_Integer_Max, style = 3)));
progress <- function(n){setTxtProgressBar(pb, n)}; opts <- list(progress = progress);
results <- 
  
  foreach(
    alpha = Base_Vector_Alpha, 
    .combine = data.frame,
    .packages = Base_Vector_Packages,
    .options.snow = opts
    ) %:% 
  foreach(
    beta = Base_Vector_Beta,
    .combine = data.frame,
    .packages = Base_Vector_Packages,
    .options.snow = opts
    ) %dopar% {
      
      set.seed(Base_Integer_Seed)
      
      Base_List_UnseededLatentDirichletAllocation <- 
        textmodel_lda(
          x = Quanteda_DocumentFeatureMatrix_TextData %>% 
            head(0.5*ndoc(Quanteda_DocumentFeatureMatrix_TextData)),
          k = Base_Integer_K,
          max_iter = 2000, # for Gibbs sampling
          alpha = alpha, 
          beta = beta
        )
      
      Base_Factor_PredictedTopics <- 
        predict(
          Base_List_UnseededLatentDirichletAllocation,
          newdata = Quanteda_DocumentFeatureMatrix_TextData %>% 
            tail(0.5*ndoc(Quanteda_DocumentFeatureMatrix_TextData)),
        )
      
      }; stopCluster(cl); close(pb); end <- Sys.time(); print(end-start)

# topics: 
head(results, 10)
