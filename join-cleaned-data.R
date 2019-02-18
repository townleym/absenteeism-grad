# This script should run if the four files are in the 'data' file 


gradrate1314 <- read_csv(file.path("data",  "acgr-sch-sy2013-14.csv"), 
                         guess_max = 10000)

gradrate1516<- read_csv(file.path("data","acgr-sch-sy2015-16.csv"),
                         guess_max = 10000)



# Absenteeism data with only "TOT" columns included along with some ID columns

absent1314_HS <- read_csv(file.path("data", "absent1314_HS_TOT.csv"), guess_max = 20000)
absent1516_HS <- read_csv(file.path("data", "absent1516_HS_TOT.csv"), guess_max = 20000)

# Join datasets 
data1314 <- left_join(absent1314_HS, gradrate1314, by = c("COMBOKEY" = "NCESSCH"))
data1516 <- left_join(absent1516_HS, gradrate1516, by = c("COMBOKEY" = "NCESSCH"))

# Check dimensions 
dim(data1314) 
dim(data1516)


# Which column names are shared? 
shared <- names(data1314) %in% names(data1516)
shared 


# Look at data columns in 1314 that are also in 1516 data
names(data1314[ ,shared])