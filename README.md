# [Apollo](http://www.apollochoicemodelling.com/)  + [modelsummary](https://www.example.com) 


Here you can find a minimalist example of how to export [Apollo](http://www.apollochoicemodelling.com/) objects to LaTeX using [modelsummary](https://www.example.com) and [kableExtra](https://cran.r-project.org/web/packages/kableExtra/vignettes/awesome_table_in_html.html).



The example uses van Cranenburgh (2018) data, and using Apollo fits a Latent Class Model with three classes. As you can imagine, this produces a rather extensive list of parameters; hence parsing them is a tedious task.

Script [Apollo_LCM_3_classes.R](https://github.com/alvarogutyerrez/export_apollo_using_modelsummary/blob/main/code/Apollo_LCM_3_classes.R) fits the model and [table_generator.R](https://github.com/alvarogutyerrez/export_apollo_using_modelsummary/blob/main/code/table_generator.R) creates a LaTeX table using the [Apollo object](https://github.com/alvarogutyerrez/export_apollo_using_modelsummary/blob/main/saved_models/LCM_3_classes.rds). I did a small workaround, explained on the script, to parse the parameters from each class and put them in different columns. 

In the end, you will go from this...

```
--------------------------------------------
Maximum Likelihood estimation
BFGS maximization, 158 iterations
Return code 0: successful convergence 
Log-Likelihood: -707.3 
22  free parameters
Estimates:
                 Estimate Std. error t value Pr(> t)    
B_tt_1          -1.213751   0.335702  -3.616 0.00030 ***
B_tt_2          -0.051257   0.148256  -0.346 0.72954    
B_tt_3          -0.264277   0.028377  -9.313 < 2e-16 ***
B_tc_1          -1.662438   0.757741  -2.194 0.02824 *  
B_tc_2          -2.802245   0.943234  -2.971 0.00297 ** 
B_tc_3          -0.922405   0.104376  -8.837 < 2e-16 ***
delta_1         -0.141284   1.326050  -0.107 0.91515    
delta_2          0.455190   1.222835   0.372 0.70971    
b_female_1      -0.691747   0.661970  -1.045 0.29603    
b_female_2      -0.530474   0.593190  -0.894 0.37118    
b_age_1         -0.007326   0.027336  -0.268 0.78871    
b_age_2         -0.010557   0.026467  -0.399 0.68998    
b_inc_med_1      0.041508   1.434916   0.029 0.97692    
b_inc_med_2      0.676376   0.978921   0.691 0.48960    
b_inc_high_1    -0.290387   0.964584  -0.301 0.76338    
b_inc_high_2    -1.431282   0.890542  -1.607 0.10801    
b_inc_v_high_1   0.245273   1.017092   0.241 0.80944    
b_inc_v_high_2  -0.209718   0.847149  -0.248 0.80448    
b_educ_med_1   -13.290038 306.526460  -0.043 0.96542    
b_educ_med_2    -1.779215   1.032970  -1.722 0.08499 .  
b_educ_high_1   -0.657781   0.695446  -0.946 0.34423    
b_educ_high_2   -0.579183   0.678543  -0.854 0.39334    
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
--------------------------------------------
```

... to this: 

![Example Table](https://github.com/alvarogutyerrez/export_apollo_using_modelsummary/blob/main/LaTeX/latex_table.JPG?raw=true)



- van Cranenburgh, Sander (2018): Small value-of-time experiment, Netherlands. 4TU.ResearchData. Dataset. https://doi.org/10.4121/uuid:1ccca375-68ca-4cb6-8fc0-926712f50404 


