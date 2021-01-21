library(apollo)
library(mlogit)

# extracting all the functions that are included on modelparty.R file

link <- "https://data.4tu.nl/ndownloader/files/24015353"
df   <- read.table(link,
                   header=TRUE, 
                   skip=0)
#lowercase headers
names(df) <- tolower(names(df))


for (i in 1:3) {
  names(df)[names(df) == paste0('tt',i)] <- paste0('tt_',i)
  names(df)[names(df) == paste0('tc',i)] <- paste0('tc_',i)
  
}


## Drop missing obs 
df<-df[!(df$age==88888),]

# Female
df$female = 1L*(df$sex==2)
# Female

# Education level.
# 2 == No education, 
# 3 == Elementary school, 
# 4 == Lower education, 
# 5 == Middle education, 
# 6 == Higher education, 
# 7 == University 

df <- within(df, { educ_low <- ifelse(edu %in% c(2,3,4),1,0)})
df <- within(df, { educ_med <- ifelse(edu %in% c(5),1,0)})
df <- within(df, { educ_high <- ifelse(edu %in% c(6,7),1,0)})


# IncHH	HouseHold Income. 
df <- within(df, { inc_low <- ifelse(inchh %in% seq(2,12),1,0)})
df <- within(df, { inc_med <- ifelse(inchh %in% c(13,14),1,0)})
df <- within(df, { inc_high <- ifelse(inchh %in% seq(15,16),1,0)})
df <- within(df, { inc_v_high <- ifelse(inchh %in% seq(17,20),1,0)})




### Initialise code
apollo_initialise()


#data set to --> apollo
database <- df 

### Set core controls
apollo_control = list(
  modelName  ="LC_base ",
  modelDescr ="LCM with 3 classes include covariates in the allocation model",
  indivID    ="id",
  panelData  = TRUE,
  nCores     = 1
)

### Vector of parameters, including any that are kept fixed in estimation
apollo_beta = c(B_tt_1         = -0.1, B_tt_2         = 0, B_tt_3       = 0.1,
                B_tc_1         = -0.1, B_tc_2         = 0, B_tc_3       = 0.1,
                delta_1        = 0   , delta_2        = 0,
                b_female_1     = 0   , b_female_2     = 0, 
                b_age_1        = 0   , b_age_2        = 0, 
                b_inc_med_1    = 0   , b_inc_med_2    = 0,
                b_inc_high_1   = 0   , b_inc_high_2   = 0,
                b_inc_v_high_1 = 0   , b_inc_v_high_2 = 0,
                b_educ_med_1   = 0   , b_educ_med_2   = 0,
                b_educ_high_1  = 0   , b_educ_high_2  = 0) 


#Fixed
apollo_fixed =c()

apollo_lcPars=function(apollo_beta, apollo_inputs){
  lcpars = list()
  
  lcpars[["beta_tt"]] = list(B_tt_1, B_tt_2, B_tt_3)
  lcpars[["beta_tc"]] = list(B_tc_1, B_tc_2, B_tc_3)
  
  V=list()
  V[["class_1"]] = delta_1 +          b_age_1   * age +
    b_female_1        * female       +
    b_inc_med_1       * inc_med      +
    b_inc_high_1      * inc_high     + 
    b_inc_v_high_1    * inc_v_high   + 
    b_educ_med_1      * educ_med     + 
    b_educ_high_1     * educ_high
  
  V[["class_2"]] = delta_2           +  b_age_2   * age +
    b_female_2       * female        +
    b_inc_med_2      * inc_med       +
    b_inc_high_2     * inc_high      + 
    b_inc_v_high_2   * inc_v_high    + 
    b_educ_med_2     * educ_med      + 
    b_educ_high_2    * educ_high
  
  
  V[["class_3"]] = 0
  
  mnl_settings = list(
    alternatives = c(class_1=1, class_2=2, class_3=3), 
    avail        = 1, 
    choiceVar    = NA, 
    V            = V
  )
  lcpars[["pi_values"]] = apollo_mnl(mnl_settings, functionality="raw")
  
  lcpars[["pi_values"]] = apollo_firstRow(lcpars[["pi_values"]], apollo_inputs)
  
  return(lcpars)
}

apollo_inputs = apollo_validateInputs()

# ################################################################# #
#### DEFINE MODEL AND LIKELIHOOD FUNCTION                        ####
# ################################################################# #

apollo_probabilities=function(apollo_beta, apollo_inputs, functionality="estimate"){
  
  ### Attach inputs and detach after function exit
  apollo_attach(apollo_beta, apollo_inputs)
  on.exit(apollo_detach(apollo_beta, apollo_inputs))
  
  ### Create list of probabilities P
  P = list()
  
  ### Define settings for MNL model component that are generic across classes
  mnl_settings = list(
    alternatives = c(alt1   = 1, alt2 = 2, alt3 = 3),
    avail        = list(alt1= 1, alt2 = 1, alt3 = 1),
    choiceVar    = choice
  )
  
  ### Loop over classes
  s=1
  while(s<=length(pi_values)){
    
    ### Compute class-specific utilities
    V=list()
    V[['alt1']]  =  beta_tt[[s]]*tt_1 + beta_tc[[s]]*tc_1  
    V[['alt2']]  =  beta_tt[[s]]*tt_2 + beta_tc[[s]]*tc_2 
    V[['alt3']]  =  beta_tt[[s]]*tt_3 + beta_tc[[s]]*tc_3 
    mnl_settings$V = V
    mnl_settings$componentName=paste0("class_",s)
    
    ### Compute within-class choice probabilities using MNL model
    P[[s]] = apollo_mnl(mnl_settings, functionality)
    
    ### Take product across observation for same individual
    P[[s]] = apollo_panelProd(P[[s]], apollo_inputs ,functionality)
    
    s=s+1
  }
  
  ### Compute latent class model probabilities
  lc_settings   = list(inClassProb = P, classProb=pi_values)
  P[["model"]] = apollo_lc(lc_settings, apollo_inputs, functionality)
  
  ### Prepare and return outputs of function
  P = apollo_prepareProb(P, apollo_inputs, functionality)
  return(P)
}

LCM_3 <-  apollo_estimate(apollo_beta, 
                                      apollo_fixed, 
                                      apollo_probabilities, 
                                      apollo_inputs,
                                      estimate_settings=list(maxIterations=1000))


saveRDS(LCM_3, 
        file = "saved_models/LCM_3_classes.rds")

