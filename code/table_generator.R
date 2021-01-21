library(modelsummary)
library(broom)
library(tibble)
library(kableExtra)


LCM_3<-readRDS(
   file = "saved_models/LCM_3_classes.rds")



#### Declare tidy.apollo ####

# Usually, here we should create a tidy.maxLik because
# this is the resulting object from Apollo. However, here
# I am doing a workaround to parse the model into the 
# different latent classes; hence I include the `summary()`
# of the model, as we will see later. 

tidy.apollo <- function(obj, ...) {
  ret <- tibble::tibble(term = row.names(obj),
                        estimate = as.numeric(obj[,1]),
                        std.error  =  as.numeric(obj[,2]),
                        p.value = as.numeric(obj[,4]))
  ret
}


#### Declate glance.apollo ####
# Here I generate only a line that breaks down the model fit
# and the coefficients.

glance.apollo <- function(obj, ...) {
  ret <- tibble::tibble(" " = " ")
  ret
}



#### Parsing the Apollo Object ####

### Select coefs of equation of each Class

# Class 1
params_class_1 <-c("B_tt_1",
                   "B_tc_1",
                   "delta_1",
                   "b_female_1",
                   "b_age_1"         ,
                   "b_inc_med_1"      ,
                   "b_inc_high_1"    ,
                   "b_inc_v_high_1"   ,
                   "b_educ_med_1"   ,
                   "b_educ_high_1"   )

# Class 2
params_class_2 <-c("B_tt_2",
                   "B_tc_2",
                   "delta_2",
                   "b_female_2",
                   "b_age_2"         ,
                   "b_inc_med_2"      ,
                   "b_inc_high_2"    ,
                   "b_inc_v_high_2"   ,
                   "b_educ_med_2"   ,
                   "b_educ_high_2"   )

# Class 3
params_class_3 <-c("B_tt_3",
                   "B_tc_3")

## Generate a model summary to extract coefficients
sum_model<- summary(LCM_3)
coef_model<- coef(sum_model)

## Here I extract each of the parameters from the model summary 
class_1<- coef_model[params_class_1, ]
class_2<- coef_model[params_class_2, ]
class_3<- coef_model[params_class_3, ]

# Here I force the objects to have class apollo, to be recognized by 
# tidy.apollo() and glance.apollo() used by `modelsummary()`.
class(class_1) <- "apollo"
class(class_2) <- "apollo"
class(class_3) <- "apollo"

### Declare a list with the coefficients to provide modelsummary with.
all_coef <-list("Class 1" = class_1, 
                "Class 2" = class_2,
                "Class 3" = class_3)


## Here I generate name of the parameters on the table. 
cm <- c('B_tt_1'    = 'Total Time',
        'B_tt_2'    = 'Total Time',
        'B_tt_3'    = 'Total Time',
        
        'B_tc_1'    = 'Total Cost',
        'B_tc_2'    = 'Total Cost',
        'B_tc_3'    = 'Total Cost',
        
        "delta_1"   = "Allocation Model Constant"  ,
        "delta_2"   = "Allocation Model Constant"  ,
        
        "b_female_1"  =  "Female"      ,
        "b_female_2"  =  "Female"      ,
        
        "b_age_1"   =   "Age"        ,
        "b_age_2"   =   "Age"        ,
        
        "b_inc_med_1" = "Income Medium" ,
        "b_inc_med_2" = "Income Medium" ,
        
        "b_inc_high_1"  = "Income High" ,
        "b_inc_high_2"  = "Income High" ,
        
        "b_inc_v_high_1" =  "Income Very High" ,
        "b_inc_v_high_2" =  "Income Very High" ,
        
        "b_educ_med_1"  = "Educ Medium"        ,
        "b_educ_med_2"  = "Educ Medium"  , 
        
        "b_educ_high_1"  = "Educ High"        , 
        "b_educ_high_2"  = "Educ High"      )




## This is added to complete the general description of the model
rows <- tribble(~term, ~"Class 1",  ~"Class 2", ~"Class 3",
                'LL'      , ' ' , paste0(round(LCM_3$maximum,digits = 2)), ' ',
                'Num.Obs.', ' ' , paste0(LCM_3$nObs), ' ',
                'Num.Ind.', ' ' , paste0(LCM_3$nIndivs), ' ')



## Define position of the added rows (LL, Num.Obs, Num.Ind, etc... )
## Position 21 on the table (after all the coefficients)
attr(rows, 'position') <- rep(21,4)


## Table creation
tab <- msummary(models = all_coef ,
              stars = TRUE,     ## display stars  
              coef_map = cm,    ## Change the of the coefficients
              output = 'latex', ## Declate LaTeX Output
              add_rows = rows ) #,  ## Add the rows with (LL, Num.Obs, Num.Ind,)  

kableExtra::save_kable(tab,
                       file = "LaTeX/VoT_LCM_3_classes.tex") 



#An additional example  of a further modified table.
tab_fit_with_page <- msummary(models = all_coef ,
                stars = TRUE,     ## display stars  
                coef_map = cm,    ## Change the of the coefficients
                output = 'latex', ## Declate LaTeX Output
                add_rows = rows  #,  ## Add the rows with (LL, Num.Obs, Num.Ind,)  
             )%>%
 kable_styling(latex_options = c( "scale_down")) ## LaTeX display with page

kableExtra::save_kable(tab_fit_with_page,
                       file = "LaTeX/VoT_LCM_3_classes_tab_fit_with_page.tex") 



