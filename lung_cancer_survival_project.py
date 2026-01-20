

## Lung Cancer Survival Analysis Project

## Install and load packages
"""

# 1. Install the pacman package
install.packages("pacman")

# 2. Use pacman to load project libraries
pacman::p_load(
  survival,   # For survival math
  survminer,  # For Kaplan-Meier plots
  flextable,  # For professional tables
  tidyverse,  # For data cleaning (dplyr, ggplot2, etc.)
  ggthemes    # For making graphs look better
)

"""##Analysis Kaplan - Meier

##Load database
"""

data("lung")
head(lung)
str(lung)
glimpse(lung)

# --- VARIABLE REFERENCE: 'lung' Dataset (North Central Cancer Treatment Group (NCCTG) Lung Cancer Data) ---
# This dataset tracks survival in patients with advanced lung cancer.

# inst:       Institution code (where the patient was treated).
# time:       Survival time in DAYS.
# status:     Censoring status: 1 = Censored (alive or left study),
#                               2 = Dead.
# age:        Age in years.
# sex:        Gender: Male = 1, Female = 2.
# ph.ecog:    ECOG performance score (physician-rated. 0 = asymptomatic,
#             5 = dead).
# ph.karno:   Karnofsky performance score (physician-rated. 0-100:
#             bad to good).
# pat.karno:  Karnofsky performance score (patient-rated. 0-100).
# meal.cal:   Calories consumed at meals.
# wt.loss:    Weight loss in the last six months (pounds).

"""# 1. Basic KM Model generation

#Question: What is the median survival time for men versus women with lung cancer at 6 months?

"""

# Change 'sex' from a numeric variable to a categorical factor (1=Men, 2=Women)
lung$sex <- factor(lung$sex, levels = c(1, 2), labels = c("Men", "Women"))

## Validation: Display frequency counts and percentages to verify the change
table(lung$sex); round(prop.table(table(lung$sex))*100, 2)

#Fit the survival model using survfit
mod1 <- survfit(Surv(time, status)~ sex, data = lung)
print(mod1 ) # mediana de supervivenvia
summary(mod1) # Mediana de supervivencia por tiempo al evento
summary(mod1)$table #Media de supervivencia

# Fit the survival model stratified by sex using the Kaplan-Meier estimator
mod1 <- survfit(Surv(time, status) ~ sex, data = lung)

# Summary (Median Survival and Confidence Intervals)
print(mod1)

#Median survival by time to event (hows survival probability at each time point)
summary(mod1)

# Summary table (Median Survival, Number of Events, and Sample Size)
summary(mod1)$table

# 1. Group the days into 30-day "bins" ([0-30), [30-60))
summary(lung$time)
lung$time_months<- (lung$time/30) %>% floor() +1
table(lung$time_months)



# Fit the survival model using months instead of days
mod2 <- survfit(Surv(time_months, status)~ sex, data = lung)

# Display median survival time (in months) for each group
print(mod2)

# Show the full life table (survival probability for every month)
summary(mod2)

# Show the summary table with sample size and total events
summary(mod2)$table

# Show survival probability specifically at the 6-month mark
summary(mod2, times = 6)

"""## Survival at 6 Months

At exactly 6 months, the data shows a clear difference in the probability of survival between the two groups:

Men: The survival probability is 0.6496 (approximately 65%).

Women: The survival probability is 0.8428 (approximately 84%).

## Summary of Findings

Women in this dataset have a significantly longer median survival time (15 months vs. 10 months for men).

At the 6-month milestone, women also show a higher survival rate (84%) compared to men (65%).

The number of events (deaths) recorded by the 6-month mark was 48 for men (out of 137) and 14 for women (out of 90).
"""

table_1 <- data.frame(
  "Time" = mod2$time,
    "Patients at risk" = mod2$n.risk,
    "Number of events" = mod2$n.event,
    "Censored patients" = mod2$n.censor,
    "Survival" = mod2$surv,
    "IC Upper" = mod2$upper,
    "IC Lower" = mod2$lower
)

head(table_1)
flextable::flextable(table_1)

"""# Generate Kaplan-Meier survival plots"""

ggsurvplot(mod2,fun = "pct", data = lung)
ggsurvplot(mod2, fun = "event", data = lung) # Cumulative Events
ggsurvplot(mod2, fun = "cumhaz", data=lung) # Cumulative Hazard (expected number of events)

"""## Survival Plot (Kaplan-Meier)

It can be observed that in both the male and female groups, all participants start alive; consequently, the curves begin to drop in steps as deaths occur. The line for men falls faster and remains consistently below the line for women, showing that women have a higher probability of survival throughout the entire study.

## Cumulative Hazard Plot

The curve starts at 0, indicating that at the beginning, no one has accumulated a risk of death.

Over time, both lines rise, but the line for men has a steeper slope than the one for women. By the end of the follow-up period, the cumulative hazard for men is close to 3, while for women it is lower (close to 2.5).
"""

# Can be combined with ggplot
# Figure 1: Specify the model

ggsurvplot(mod2,
           data = lung,
           # Add horizontal and vertical lines for median survival
           surv.median.line = "hv",
           # Show Confidence Interval
           conf.int = T,
           # Set Confidence Interval style to "step"
           conf.int.style = "ribbon",
           # Set p-value coordinates
           pval.coord = c(0, 0.20),
           # Add risk table showing events/censored
           risk.table = TRUE,
           # Add p-value for the comparison method (Log-Rank by default)
           pval = TRUE,
           size = 1,
           palette = "lancet",
           ggtheme = theme_hc(),
           xlab = "Time (Months)",
           ylab = "Survival Probability",
           #Comparison groups
           legend.labs = c("Men",
                         "Women"),
           #Scale X Axis
           xlim = c(0,24),
           #Scale Y Axis (always 1.0)
           ylim = c(0,1.0),
           # Y Axis Tick Marks
           break.y.by = (0.25),
           # X Axis Tick Marks
           break.x.by = (5))


# Similar to ggplot theme
  theme_survminer(base_size = 10, base_family= "Arial")

"""### Summary of Results

- Cohorts: Men (n=138) vs. Women (n=90).

- Time Scale: Months.

The KM analysis shows that women have a better prognosis, with a median survival of 15 months compared to 10 months for men. At the 6-month mark, female survival is 84%, notably higher than the 65% observed in men. The plots confirm that men accumulate death risk faster, reaching a value of **3 compared to 2.5** in women. Finally, the p-value of 0.00087 ensures that this female survival advantage is statistically real and not due to chance.

# 2. **Assessing differences between survival curves**
### "**The log-rank test**" (or Mantel-Cox test) is the most widely used method for comparison.
### H0: There is no difference in survival between the two groups
"""

dif_1 <-survdiff(Surv(time_months,status)~ sex, rho = 0 , data = lung)
dif_1

"""## Interpretation
H0 = rejected. The log-rank test showed a statistically significant difference in survival between sexes (Chisq(χ2)= 12.4, df=1, p<0.001). Male patients experienced a higher number of events than expected (112 observed vs. 90.3 expected), while female patients showed a survival advantage with fewer events than expected (53 observed vs. 74.7 expected). Without sex difference

#Assessing the interaction with an additional variable
"""

# Data preparation
lung$age_65<-NULL; lung$age_65[lung$age<65]<-0; lung$age_65[lung$age>=65]<-1
lung$age_65<-factor(lung$age_65,labels = c("<65 years old", "≥65 years old"))

#the model
mod3 <- survfit(Surv(time_months, status) ~ sex+age_65, data = lung)
print(mod3) # survival median
summary(mod3) # Median survival time to event
summary(mod3)$table # Survival mean


#Full Graphic
ggsurvplot(mod3,
           data = lung,
           ggtheme = theme_survminer(base_size = 10, base_family = "Arial"), # Theme requested
           legend.title = "Groups",
           legend.labs = c("Men <65", "Men ≥65", "Women <65", "Women ≥65"), # Short names to fit legend
           risk.table = TRUE,  # Adds the risk table at the bottom
           pval = TRUE,        # Displays p-value to evaluate differences
           palette = "jco"     # Clear and professional color palette
)

"""## Interpretation
- A stratified survival analysis was performed based on sex and age (≥ 65 years). The results indicate that female patients have a superior survival profile compared to males, with a median survival of 15 months versus 9–10 months for men. Age served as a secondary risk factor, most notably among male patients, where those ≥ 65 years exhibited the poorest prognosis. The survival curves maintained a consistent separation, suggesting that the proportional hazards assumption is met.

# 3. COX REGRESSION
This model allows for the study of time-to-event data. Unlike the Kaplan-Meier (KM) method, it enables the quantification of the effect that a predictor has on survival time.

- **Parametric**: You assume a shape (Exponential, Weibull). You estimate both the shape and the effect of predictors.

- **Non-parametric (KM)**: You only describe what happened; you cannot easily adjust for multiple predictors.


# **SEMI PARAMETRIC (COX)**:
- You don't assume a shape for survival time, but you can precisely measure the effect of multiple predictors. Assumes that harzards are cinstant over the time.
## Proportional Hazards (Requirement):
- This model assumes that the hazard ratio between the individuals or groups under study remains constant over time (the cumulative survival curves should not cross).
"""

hist(lung$time)

table(lung$status) # statust (censured or dead)
lung$status <- ifelse(lung$status==2,1,0) #C=0 , D=1

summary(lung$age) #age
table(lung$sex) #sex
lung$sex <- ifelse(lung$sex==2,1,0) #M=0, W=1
table(lung$ph.ecog) #ECOG scale
summary(lung$ph.karno) #Karnofsky Performance Status (KPS) Scale
summary(lung$meal.cal) #Calories consumed in each meal
summary(lung$wt.loss) #weight loss the las 6 months

apply(apply(lung, 2, is.na),2,sum)

# a) Delete missing data
lung2 <-lung %>% na.omit()
apply(apply(lung2, 2, is.na),2,sum)
nrow(lung2); nrow(lung)

# b) Missing Data Imputation.
# An educated guess.

"""## 3.1 Cox Models (interpretation and comparison)"""

survival::coxph(formula = Surv(time, status) ~ sex, data = lung2)
Surv(lung2$time, lung2$status)


m1 <- survival::coxph(formula = Surv(time, status) ~ sex, data = lung2)
summary(m1)
#HR =1 No hay diferencia
#HR <1 Menor riesgo
#HR >1 Mayor riesgo
1-0.588
concordance(m1)
summary(m1)$concordance

