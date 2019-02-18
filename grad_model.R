require(magrittr)
setwd('/Users/matt/Documents/projects/absenteeism-grad')

y14 = read.csv("joined1314.csv", header = TRUE, as.is = T)
y16 = read.csv("joined1516a.csv", header = TRUE, as.is = T)

select_cols = c(1:6, 13:14, 37:38, 45:46, 53:54, 66:67, 76:77, 106, 115:116, 178:179, 200:206)

enrollment_vars = names(y14)[grepl('ENR', names(y14))]

# combine all the enrollment by sex into total enrollment
# total_enrollment = y14[,which(names(y14) %in% enrollment_vars[grep('_M$', enrollment_vars)])] +  y14[,which(names(y14) %in% enrollment_vars[grep('_F$', enrollment_vars)])]

names(y14)

# wait.... just do all the sex segregated into one
sex_collapsed = y14[,names(y14)[grep('_M$', names(y14))]] + y14[,names(y14)[grep('_F$', names(y14))]]
names(sex_collapsed)
names(sex_collapsed) = lapply(names(sex_collapsed), function(x) {substr(x, 1, nchar(x) - 2)}) %>% unlist

# add back the remaining columns
"%notin%" = function(x, table) match(x, table, nomatch = 0) < 1

othernames = names(y14)[which(names(y14) %notin%  c(names(y14)[grep('_F$', names(y14))],  names(y14)[grep('_M$', names(y14))]))]

s14 = data.frame(y14[,othernames], sex_collapsed, stringsAsFactors = F)
# drop the duplicate column from the merge
s14 = s14[,-grep("LEAID", names(s14))[2]]
names(s14)[grep("LEAID", names(s14))] = "LEAID"

# make all the column names lower case
names(s14) = tolower(names(s14))

# now fix up the grad rate
names(s14)[grep("rate", names(s14))]
table(s14$all_rate_1314, useNA = "ifany") %>% cbind # what a mess

# first, eliminate the NA rows
s14 = s14[which(!is.na(s14$all_rate_1314)),]

# 14-OCT is 10-14
# 19-Nov is 11-19
# 9-Jun is 6-9

# GE50, 80, 90, 95, 99 
# LE1, 10, 20, 5, 50
# PS?

# First, fix up the ones that look like dates
s14[which(s14$all_rate_1314 == "14-Oct"), "all_rate_1314"] = "10-14"
s14[which(s14$all_rate_1314 == "19-Nov"), "all_rate_1314"] = "11-19"
s14[which(s14$all_rate_1314 == "9-Jun"), "all_rate_1314"] = "6-9"

# split all the rates by dashes
ratesplit = strsplit(s14$all_rate_1314, "-")

table(s14$all_rate_1314, useNA = "ifany") %>% cbind

# encode the re-coding rules into a single function
numerifier = function(vec) {
  
  # deal with the GE/LE
  # return the threshold number
  # Helen used midpoint up to 100 / down to zero -- we can do that too
  if(length(vec) == 1 & (grepl("^GE", vec) | grepl("^LE", vec))) {return(as.numeric(substr(vec, 3, nchar(vec))) / 100)}
  
  # and the split ones
  # take the midpoint
  if(length(vec) > 1) {return(mean(as.numeric(vec)) / 100)}
  
  # and last, return numeric for length = 1
  if(length(vec) == 1) {return(as.numeric(vec) / 100)}
}

sapply(ratesplit[1:50], numerifier) # looks like it works

# do 'em all
s14$grad_rate = sapply(ratesplit, numerifier)

head(s14)
names(s14)[grep("enr", names(s14))]
names(s14)[grep("absent", names(s14))]

plot(density(s14[,"tot_mathenr_alg2"]))

absr = s14[,"tot_absent"] / s14[,"tot_enr"]
plot(density(absr, na.rm = T))

gr = s14[,"grad_rate"]
plot(density(gr, na.rm = T))

algr = (s14[,"tot_mathenr_alg2"] / s14[,"tot_enr"])
plot(density(algr))
quantile(algr, 0:10 / 10)

s14[which(algr > 1),]
plot(gr ~  algr)


# first examine the connection between absenteeism and grad rates
plot(gr ~ absr) # hmmmm
plot(density(absr, na.rm = T)) # need to constrain [0,1]

cframe = data.frame(absr, algr, gr)
cframe = cframe[which(
  cframe$absr >= 0 & cframe$absr <= 1 
  & cframe$algr >= 0 & cframe$algr <= 1
  & cframe$gr >= 0 & cframe$gr <= 1)
  ,]

lm(gr ~ absr, data = cframe) %>% summary
sapply(cframe, quantile, 0:10/10, na.rm = T)
sapply(cframe, quantile, (100/400) * (0:4), na.rm = T)
# rmse is greater than the iqr
# probably because linear assumptions don't hold

# how much do we want to beat this model?

mondo = 













