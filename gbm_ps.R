setwd('~/Documents/projects/absenteeism-grad')

a_frame = read.csv(file = "y1314_clean.csv", as.is = T)

libs = c("xgboost", "caret", "rsample", "pdp", "lime")
# lapply(libs, install.packages, character.only = T)
lapply(libs, library, character.only = T)

a_frame = a_frame[which(!is.na(a_frame$grad_r)),]
a_frame = a_frame[which(a_frame$abs_r <= 1),]
a_frame$abs_r = round(a_frame$abs_r, 2)
summary(a_frame$abs_r)


# find empirical split using partitioning
require(rpart)
d.mod = rpart(grad_r ~ abs_r, data = a_frame, method = 'anova')
summary(d.mod)
plot(d.mod)
text(d.mod)

a_frame[which(a_frame$abs_r <= 0.005),"grad_r"] %>% quantile(probs = 0:10 / 10)
# split/apply/combine
quantile(a_frame$abs_r, probs = 0:10 / 10)
f_absr = cut(a_frame$abs_r, breaks = quantile(a_frame$abs_r, probs = 0:10 / 10))
data.frame(a_frame$abs_r, f_absr) %>% head(100)

s_gradr = split(a_frame$grad_r, f_absr)
lapply(s_gradr, mean)
#unsplit(lapply(s_gradr, mean), f_absr)

with(a_frame, plot(grad_r ~ abs_r))
lm(grad_r ~ abs_r, data = a_frame) %>% summary

# for fun, divide treat/control at median
a_frame$treat = 0
a_frame[which(a_frame$abs_r > median(a_frame$abs_r)), "treat"] = 1

# set.seed(1274)
# g_split <- initial_split(a_frame, prop = (3/4))
# g_train <- training(g_split)
# g_test <- testing(g_split)
# 
# 
# features_train = g_train[,-1]
# response_train = g_train[,"grad_r"]
# 
# features_test = g_test[,-1]
# response_test = g_test[,"grad_r"]

features_train = a_frame[,-c(1,2)]
response_train = a_frame[,'treat']

set.seed(1274)

params = list(
  eta = .1,
  max_depth = 5,
  min_child_weight = 2,
  subsample = .8,
  colsample_bytree = .9
)

start.time = proc.time()

xgb.fit1 = xgboost(
  data = features_train %>% as.matrix,
  label = response_train,
  params = params,
  missing = NA,
  nrounds = 1000,
  nfold = 5,
  objective = "reg:logistic",  # for regression models
  verbose = 0,               # silent,
  early_stopping_rounds = 10 # stop if no improvement for 10 consecutive trees

  )
proc.time() - start.time

quantile(response_train, probs = 0:4 / 4) %>% round(3)
xgb.fit1$evaluation_log[which.min(xgb.fit1$evaluation_log$train_rmse),]

logit = predict(xgb.fit1, features_train %>% as.matrix)

odds = exp(logit)
prob = odds / (1 + odds)
# summary(xgb.fit1)

source('~/Documents/rfuns/mMisc/R/mMisc.R')

roc_ps = roclines(features_train, logit)
plot(roc_ps, type = "l")
abline(a = 0, 1)
points(x = (0:100 / 100), y = (0:100 / 100), lty = 2, col = "grey40", type = 'l')
# plot(x = (0:100 / 100), y = (0:100 / 100), lty = 2, col = "grey40", type = 'l', add = T)
