---
title: "Prep data for grad modeling"
author: "Matthew Townley"
date: "1/15/2019"
output: 
  html_document:
    keep_md: true
---



# Effect of absenteeism on graduation rates

Ecological analysis of school-level data to understand whether high rates of chronic absenteeism predict low graduation rates.

Some links (so I can close these in my browser)


# Load/clean data

These data come from ....

<https://www2.ed.gov/about/inits/ed/edfacts/data-files/index.html#acgr>
<https://ocrdata.ed.gov/DataFileUsersManual>

There's ... lots of problems in the data we must wrangle first

Need Helen to enter text about where 'joined1314' came from



Several things need to be fixed before we can analyze the data.

1. Most of the count columns are broken out by sex. Reaggregate those.
2. The graduation rate field is text with a lot of things like 'GE' (greater than or equal)
3. The data are counts. Lots of approaches to that. See the next top-level section
4. Looks like missing values are coded with negative integers

I've left these sections in for transparency about _how_ we're fixing up the data for analysis.

## Re-aggregate the sex-specific columns 

This is pretty easy since each column name has a trailing "_M" or "_F" respectively. 

*Approach*

I'll `grep` the column names for those that end with a "_M" or "_F" and simply add the two dataframes.


```r
# Use this function to find the non-matching column names
"%notin%" = function(x, table) match(x, table, nomatch = 0) < 1

# create a collapsed dataframe that is the sum of each of the sex-specific columns

# This violates the principle of never do anything twice,
# but each data frame has just enough difference to make such things
# necessary

###############################################################################
# First y13-14 data
colnames_m = names(y14)[grep('_M$', names(y14))]
colnames_f = names(y14)[grep('_F$', names(y14))]
sex_collapsed = y14[,colnames_m] + y14[,colnames_f]

# strip the trailing "_M" from the consolidated column names
names(sex_collapsed) = lapply(names(sex_collapsed), function(x) {substr(x, 1, nchar(x) - 2)}) %>% unlist

# add back the remaining columns
othernames = names(y14)[which(names(y14) %notin% c(colnames_m, colnames_f))]

# Create a new dataframe with the consolidated values
s14 = data.frame(y14[,othernames], sex_collapsed, stringsAsFactors = F)
# drop the duplicate column from the merge
s14 = s14[,-grep("LEAID", names(s14))[2]]
names(s14)[grep("LEAID", names(s14))] = "LEAID"

# make all the column names lower case
names(s14) = tolower(names(s14))

###############################################################################
# Next y15-16 data
colnames_m = names(y16)[grep('_M$', names(y16))]
colnames_f = names(y16)[grep('_F$', names(y16))]
sex_collapsed = y16[,colnames_m] + y16[,colnames_f]

# strip the trailing "_M" from the consolidated column names
names(sex_collapsed) = lapply(names(sex_collapsed), function(x) {substr(x, 1, nchar(x) - 2)}) %>% unlist

# add back the remaining columns
othernames = names(y16)[which(names(y16) %notin% c(colnames_m, colnames_f))]

# Create a new dataframe with the consolidated values
s16 = data.frame(y16[,othernames], sex_collapsed, stringsAsFactors = F)
# drop the duplicate column from the merge
s16 = s16[,-grep("LEAID", names(s16))[2]]
names(s16)[grep("LEAID", names(s16))] = "LEAID"

# make all the column names lower case
names(s16) = tolower(names(s16))

# clean up
# rm(list = c("colnames_m", "colnames_f", "othernames", "y14"))
```


## Turn all the Grad-rate text values into numeric

It is stored as a text field. Let's take a look at the values and see how they distribute by counts of students.


```
## [1] 23942   206
```

```
##           .
## 10        2
## 11        3
## 12        4
## 13        4
## 14        3
## 14-Oct   45
## 15        4
## 15-19    54
## 16        4
## 18        1
## 19-Nov   69
## 2         2
## 20        2
## 20-24    52
## 20-29    91
## 21        3
## 21-39   117
## 22        1
## 23        1
## 24        2
## 25-29    49
## 26        3
## 27        3
## 28        3
## 29        3
## 3         2
## 30        1
## 30-34    78
## 30-39    77
## 31        2
## 32        1
## 33        4
## 34        3
## 35        3
## 35-39    39
## 36        2
## 38        1
## 39        3
## 4         3
## 40        3
## 40-44    47
## 40-49    88
## 40-59   150
## 41        2
## 42        2
## 43        6
## 44        5
## 45        3
## 45-49    42
## 46        4
## 47        5
## 48        3
## 49        4
## 5         5
## 50        6
## 50-54    63
## 50-59    80
## 51        6
## 52        8
## 53        4
## 54        6
## 55       14
## 55-59    75
## 56        9
## 57       11
## 58        7
## 59       13
## 6         3
## 60       23
## 60-64    97
## 60-69   130
## 60-79   239
## 61       11
## 62       17
## 63       15
## 64       21
## 65       24
## 65-69   149
## 66       27
## 67       45
## 68       35
## 69       27
## 7         4
## 70      106
## 70-74   230
## 70-79   269
## 71       53
## 72       58
## 73       63
## 74       58
## 75       68
## 75-79   390
## 76       90
## 77      103
## 78       92
## 79      115
## 8         2
## 80      141
## 80-84   641
## 80-89   629
## 81      170
## 82      179
## 83      229
## 84      206
## 85      210
## 85-89  1052
## 86      240
## 87      268
## 88      285
## 89      295
## 9         7
## 9-Jun    31
## 90      337
## 90-94  1553
## 91      344
## 92      349
## 93      368
## 94      389
## 95      383
## 96      331
## 97      317
## 98      277
## GE50    948
## GE80   1266
## GE90   1493
## GE95   1591
## GE99    181
## LE1       4
## LE10     93
## LE20    209
## LE5      56
## LT50    493
## PS      771
```

```
##     ALL_RATE_1314 TOT_ENR_F TOT_ENR_M
## 1              10       491       581
## 2              11       568       670
## 3              12      2111      2003
## 4              13       738       902
## 5              14      1429      1336
## 6          14-Oct      6252      6656
## 7              15       882      1350
## 8           15-19      5631      5668
## 9              16      2914      2863
## 10             18       372       297
## 11         19-Nov      4978      5434
## 12              2       302       668
## 13             20       724       778
## 14          20-24      7349      8424
## 15          20-29      5670      7359
## 16             21       596       684
## 17          21-39      4967      5725
## 18             22      1019       908
## 19             23       192       221
## 20             24      1911      1728
## 21          25-29      5524      6285
## 22             26      2312      2144
## 23             27      8851      8632
## 24             28      4027      3442
## 25             29       644       633
## 26              3       349       437
## 27             30       550       595
## 28          30-34     14695     15204
## 29          30-39      4811      5863
## 30             31      2168      1668
## 31             32       224       224
## 32             33       726       959
## 33             34      2132      2308
## 34             35       790       752
## 35          35-39      5966      6562
## 36             36      1454      1413
## 37             38        81       135
## 38             39      8921      7834
## 39              4       574       729
## 40             40      2998      2557
## 41          40-44      7336      8261
## 42          40-49      5914      6339
## 43          40-59      8146      9333
## 44             41       974      1136
## 45             42       712       778
## 46             43      2037      2103
## 47             44      2947      3163
## 48             45      7106      6861
## 49          45-49      9953     10452
## 50             46      3700      3692
## 51             47      2991      2951
## 52             48      3437      3607
## 53             49      1603      1660
## 54              5      1061      1219
## 55             50      2765      2999
## 56          50-54     11933     12255
## 57          50-59      7386      7937
## 58             51      3229      3325
## 59             52      5015      5300
## 60             53      1531      1819
## 61             54      4092      3956
## 62             55     11938     11715
## 63          55-59     15357     15908
## 64             56      5036      5538
## 65             57      8576      9020
## 66             58      6530      7099
## 67             59      8716      9361
## 68              6       628       742
## 69             60     10964     12326
## 70          60-64     20392     22149
## 71          60-69     14403     15736
## 72          60-79     19414     19777
## 73             61     12351     11940
## 74             62     10309     11249
## 75             63     11764     12417
## 76             64     13013     14337
## 77             65     19112     19079
## 78          65-69     36115     38454
## 79             66     19836     21301
## 80             67     29405     30411
## 81             68     21555     23014
## 82             69     17394     18659
## 83              7       852       952
## 84             70     45666     48547
## 85          70-74     58086     61146
## 86          70-79     37166     39510
## 87             71     35770     38159
## 88             72     39120     41796
## 89             73     47716     49140
## 90             74     37907     39897
## 91             75     49630     51602
## 92          75-79     98384    103596
## 93             76     67159     71044
## 94             77     73554     77708
## 95             78     60119     63744
## 96             79     85166     89659
## 97              8       321       356
## 98             80     97474    102585
## 99          80-84    172916    179235
## 100         80-89     85598     90239
## 101            81    119552    125647
## 102            82    131563    138118
## 103            83    163223    170920
## 104            84    146527    154348
## 105            85    147229    153899
## 106         85-89    273136    284097
## 107            86    175525    183302
## 108            87    187059    197570
## 109            88    204066    214327
## 110            89    220219    227944
## 111             9      2044      2460
## 112         9-Jun      3176      3934
## 113            90    252871    264514
## 114         90-94    401131    417226
## 115            91    260475    271413
## 116            92    270275    279192
## 117            93    272588    283875
## 118            94    299355    308985
## 119            95    304395    312440
## 120            96    266618    275346
## 121            97    249260    254524
## 122            98    231671    237070
## 123          GE50     51558     54019
## 124          GE80    108848    112984
## 125          GE90    207049    207585
## 126          GE95    430906    426971
## 127          GE99    140183    138263
## 128           LE1       989      1065
## 129          LE10      5745      8780
## 130          LE20      8957     13895
## 131           LE5      4639      7003
## 132          LT50     17789     27505
## 133            PS     21186     28983
```

```
## [1] 21220   216
```

```
##          .
## 10       1
## 10-14   49
## 11       7
## 11-19   75
## 12       2
## 13       4
## 14       5
## 15       3
## 15-19   49
## 17       1
## 18       3
## 19       7
## 20       3
## 20-24   62
## 20-29  106
## 21       5
## 21-39  143
## 22       1
## 23       2
## 24       3
## 25       4
## 25-29   62
## 27       4
## 28       4
## 29       3
## 3        4
## 30       5
## 30-34   68
## 30-39   99
## 32       2
## 33       3
## 34       3
## 35       3
## 35-39   64
## 36       5
## 37       4
## 38       3
## 39       3
## 4        2
## 40       7
## 40-44   64
## 40-49  111
## 40-59  179
## 41       3
## 42       5
## 45       3
## 45-49   61
## 46       6
## 47       4
## 48       5
## 49       7
## 5        1
## 50       3
## 50-54   81
## 50-59  116
## 51       7
## 52       5
## 53       3
## 54       4
## 55       4
## 55-59   93
## 56       8
## 57       6
## 58       8
## 59      10
## 6        4
## 6-9     49
## 60       9
## 60-64  102
## 60-69  133
## 60-79  279
## 61       8
## 62      14
## 63      11
## 64      16
## 65      16
## 65-69  137
## 66      15
## 67      24
## 68      21
## 69      26
## 70      24
## 70-74  234
## 70-79  265
## 71      36
## 72      42
## 73      45
## 74      48
## 75      75
## 75-79  359
## 76      68
## 77      69
## 78      82
## 79     105
## 8        2
## 80     109
## 80-84  592
## 80-89  727
## 81     107
## 82     134
## 83     154
## 84     171
## 85     196
## 85-89 1016
## 86     218
## 87     254
## 88     264
## 89     300
## 9        5
## 90     306
## 90-94 1596
## 91     309
## 92     356
## 93     397
## 94     408
## 95     404
## 96     439
## 97     381
## 98     316
## GE50  1094
## GE80  1355
## GE90  1618
## GE95  1931
## GE99   228
## LE1      7
## LE10    86
## LE20   204
## LE5     64
## LT50   568
## PS     908
```

```
##     ALL_RATE_1516 TOT_ENR_F TOT_ENR_M
## 1              10       178       188
## 2           10-14      5506      6624
## 3              11      1379      2029
## 4           11-19      4513      5412
## 5              12       301       441
## 6              13       825      1448
## 7              14      1111      1036
## 8              15      2730      2296
## 9           15-19      5778      6839
## 10             17       747       852
## 11             18       880       944
## 12             19      2454      2611
## 13             20       986      1006
## 14          20-24      7458      8326
## 15          20-29      5499      7425
## 16             21      3620      3856
## 17          21-39      6014      7565
## 18             22       776       785
## 19             23       421       525
## 20             24      2696      2010
## 21             25      1470      1605
## 22          25-29      9818     10485
## 23             27      2075      1780
## 24             28      2345      2101
## 25             29      1366      1224
## 26              3       557       780
## 27             30      4517      4657
## 28          30-34      8466      9381
## 29          30-39      5845      7529
## 30             32      2063      2186
## 31             33       945      1101
## 32             34      3444      2700
## 33             35       561       679
## 34          35-39      7808      8380
## 35             36      1928      1853
## 36             37      2712      2499
## 37             38      2044      1793
## 38             39      3118      2850
## 39              4       509       987
## 40             40     12139     10351
## 41          40-44      9717     10478
## 42          40-49      7008      8906
## 43          40-59      8136      9240
## 44             41      4814      4358
## 45             42      2293      2227
## 46             45      2199      2382
## 47          45-49      8055      9739
## 48             46      2999      3387
## 49             47      4446      3595
## 50             48      1996      2518
## 51             49      3623      3782
## 52              5       465       525
## 53             50       504       458
## 54          50-54     15305     16327
## 55          50-59      8802      9877
## 56             51      2986      3039
## 57             52      2417      2585
## 58             53      1297      1435
## 59             54      2141      2096
## 60             55      7021      6283
## 61          55-59     15710     18265
## 62             56      4490      5361
## 63             57      7033      6982
## 64             58      3999      4438
## 65             59      5871      6775
## 66              6      1497      1822
## 67            6-9      6572      8944
## 68             60     12179     11875
## 69          60-64     18448     19635
## 70          60-69     11125     11839
## 71          60-79     21328     22319
## 72             61      3803      4287
## 73             62      8603      9502
## 74             63      7174      7743
## 75             64     11916     12824
## 76             65      9787     10771
## 77          65-69     32658     35703
## 78             66     13589     13576
## 79             67     16774     16787
## 80             68     12106     13336
## 81             69     14838     16074
## 82             70     16627     17888
## 83          70-74     54652     58121
## 84          70-79     30997     33379
## 85             71     25507     26978
## 86             72     31191     32732
## 87             73     34279     36559
## 88             74     33965     37466
## 89             75     57644     62069
## 90          75-79     88485     95960
## 91             76     50841     54142
## 92             77     54188     58041
## 93             78     65454     70145
## 94             79     71207     76026
## 95              8       309       446
## 96             80     85130     89997
## 97          80-84    152654    161493
## 98          80-89     95694    100461
## 99             81     77315     82135
## 100            82    101284    107521
## 101            83    117828    124627
## 102            84    126988    133045
## 103            85    143140    151595
## 104         85-89    268286    281511
## 105            86    165790    174617
## 106            87    202509    211495
## 107            88    212098    221477
## 108            89    250100    261148
## 109             9       830      1822
## 110            90    258470    268542
## 111         90-94    426037    443668
## 112            91    244581    255576
## 113            92    308054    321459
## 114            93    327633    341672
## 115            94    317434    327599
## 116            95    327342    337492
## 117            96    368747    379740
## 118            97    321631    331683
## 119            98    270523    273981
## 120          GE50     53904     57273
## 121          GE80    119553    122582
## 122          GE90    234354    237624
## 123          GE95    540142    531106
## 124          GE99    188062    186599
## 125           LE1      1893      2822
## 126          LE10      6591     10399
## 127          LE20     10417     15879
## 128           LE5     11434     13625
## 129          LT50     18606     30734
## 130            PS     20079     30482
```


*Approach*: three things we have to do:

1. Deal with the GE/LE columns
2. Deal with the ranges (e.g. 40-44)
3. Convert the single numbers to numeric format

For each case (respectively) we will: 

1. Take the threshold number. I.e. GE80 = 80%
2. AND split the threshold and 100%
3. Split the ranges
4. Simply convert the numbers


```r
# names(s14)[grep("rate", names(s14))]

# first, eliminate the NA rows
s14 = s14[which(!is.na(s14$all_rate_1314)),]
s16 = s16[which(!is.na(s16$all_rate_1516)),]

# uncomment to see all possible values
# table(s14$all_rate_1314, useNA = "ifany") %>% names
# table(s16$all_rate_1516, useNA = "ifany") %>% names

# in the 2014 data
# 14-OCT is 10-14
# 19-Nov is 11-19
# 9-Jun is 6-9

# GE50, 80, 90, 95, 99 
# LE1, 10, 20, 5, 50
# PS?

# fix up the ones that look like dates
# I'm guessing this is an excel artifact where:
s14[which(s14$all_rate_1314 == "14-Oct"), "all_rate_1314"] = "10-14"
s14[which(s14$all_rate_1314 == "19-Nov"), "all_rate_1314"] = "11-19"
s14[which(s14$all_rate_1314 == "9-Jun"), "all_rate_1314"] = "6-9"

# encode the re-coding rules into a single function
# the function works on a single vector (of any length) 
# we can *apply* this function to the list created above
numerifier = function(vec, th = T) {

# this is an ugly function full of conditional tests
# the number of braces == stack overflow
if(length(vec) == 1) {
 
  if(th) {
  # Case 1: the GE/LE/LT values 
  if( (grepl("^G", vec) | grepl("^L", vec)) ) {
     tnum = as.numeric(substr(vec, 3, nchar(vec)))
     return(tnum / 100) # return just the threshold
   } else if(grepl("^PS", vec)) {
     return(NA) # no idea what 'PS' means
   } else { # Case 3: the single values
     return(as.numeric(vec) / 100) # if a single number, return the number
   } # end section that returns only threshold values
  } else { # begin section that splits threshold and min/max
  if(grepl("^G", vec)) {
     tnum = as.numeric(substr(vec, 3, nchar(vec)))
     return(mean(c(tnum, 100)) / 100) # split the threshold and 100
   } else if(grepl("^L", vec)) {
     tnum = as.numeric(substr(vec, 3, nchar(vec)))
     return(mean(c(tnum, 0)) / 100) # split the threshold and 0
   } else if(grepl("^PS", vec)) {
     return(NA) # no idea what 'PS' means
   } else { # Case 3: the single values
     return(as.numeric(vec) / 100) # if a single number, return the number
   }
 } # end section that splits threshold and min/max
} # end single element vectors 
  # Case 2: the ranges (return midpoint)
  if(length(vec) > 1) {return(mean(as.numeric(vec))/100)}
} # end numerifier

# 2014
# Create a list of all the rate values, split by dashes
ratesplit = strsplit(s14$all_rate_1314, "-")
# try it
# sapply(ratesplit[1:50], numerifier) # looks like it works
# do 'em all
s14$grad_rate = sapply(ratesplit, numerifier)
s14$grad_rateb = sapply(ratesplit, numerifier, th = F) # grad rate that splits thresholds

ratesplit = strsplit(s16$all_rate_1516, "-")
s16$grad_rate = sapply(ratesplit, numerifier)
s16$grad_rateb = sapply(ratesplit, numerifier, th = F)
```

## missing values

What are the values for missingness?


```r
num_cols = sapply(s14, is.numeric) %>% which
num_cols = num_cols[-1:-4]
# as.vector(s14[,num_cols])[which(s14[,num_cols] < 1),] %>% unique
ta = c(as.matrix(s14[,num_cols]))
ta[which(ta < 0)] %>% unique
```

```
## [1]  -9  -5 -18  -4 -10
```

```r
# every row has a column with negative values
# which means a row-wise deletion of NA will give us a 
# zero-length dataset. This might wind up being the killer
negs = which(apply(s14[,num_cols], 1, function(x) any(x < 1)))
dim(s14[negs,]) # every row has a neg 
```

```
## [1] 20315   130
```

```r
# replace with NA
s14[,num_cols] = replace(s14[,num_cols], s14[,num_cols] < 0, NA)
```

```r
num_cols = sapply(s16, is.numeric) %>% which
num_cols = num_cols[-1:-4]
# as.vector(s16[,num_cols])[which(s16[,num_cols] < 1),] %>% unique
ta = c(as.matrix(s16[,num_cols]))
ta[which(ta < 0)] %>% unique
```

```
## [1]  -9  -5 -18  -4 -10 -12
```

```r
negs = which(apply(s16[,num_cols], 1, function(x) any(x < 1)))
dim(s16[negs,]) # every row has a neg 
```

```
## [1] 21220   135
```

```r
s16[,num_cols] = replace(s16[,num_cols], s16[,num_cols] < 0, NA)
```

## Counts

These can be converted to rates at a later time, but for now gather up the fields that seem to have relevant data (e.g. ignore a lot of the identifying fields) and write those into a separate dataframe.

### For the 2014 School year


```r
# absenteeism rate
# abs_r = s14[,"tot_absent"] / s14[,"tot_enr"]
# plot(density(abs_r, na.rm = T))

# graduation rate
# grad_r = s14[,"grad_rate"]
# plot(density(grad_r, na.rm = T))

# structural conditions
names_sports = c("tot_sssports", "tot_ssteams", "tot_sspart")
names_teach = names(s14)[grep("_fteteach", names(s14))] 

# administrative care
names_civr = names(s14)[grep("_hb", names(s14))]

# student engagement/achievement
names_enr = names(s14)[grep("enr_", names(s14))]
names_pass = names(s14)[grep("algpass_", names(s14))] # only have for algebra
names_ap = names(s14)[grep("_ap", names(s14))]
names_gt = names(s14)[grep("_gt", names(s14))]
names_other = c("tot_enr", "grad_rate", "grad_rateb", "tot_satact", "tot_absent", "all_cohort_1314")
names_id = c("lea_state", "lea_name", "sch_name", "leaid", "schid", "ccd_latcod", "ccd_loncod")

# grab all the values in the name vectors above
allcolnames = sapply(ls(pattern = '^names'), get) %>% unlist %>% unname

# last check for type
sapply(s14[,allcolnames], class) %>% cbind
```

```
##                       .          
## tot_apenr             "integer"  
## tot_apmathenr         "integer"  
## tot_apscienr          "integer"  
## tot_apothenr          "integer"  
## tot_apexam_oneormore  "integer"  
## tot_apexam_none       "integer"  
## tot_appass_oneormore  "integer"  
## tot_appass_none       "integer"  
## sch_hballegations_sex "integer"  
## sch_hballegations_rac "integer"  
## sch_hballegations_dis "integer"  
## tot_hbreported_sex    "integer"  
## tot_hbreported_rac    "integer"  
## tot_hbreported_dis    "integer"  
## tot_hbdisciplined_sex "integer"  
## tot_hbdisciplined_rac "integer"  
## tot_hbdisciplined_dis "integer"  
## tot_algenr_gs0708     "integer"  
## tot_algenr_gs0910     "integer"  
## tot_algenr_gs1112     "integer"  
## tot_geomenr_gs0712    "integer"  
## tot_mathenr_alg2      "integer"  
## tot_mathenr_advm      "integer"  
## tot_mathenr_calc      "integer"  
## tot_scienr_biol       "integer"  
## tot_scienr_chem       "integer"  
## tot_scienr_phys       "integer"  
## tot_gtenr             "integer"  
## lea_state             "character"
## lea_name              "character"
## sch_name              "character"
## leaid                 "character"
## schid                 "integer"  
## ccd_latcod            "numeric"  
## ccd_loncod            "numeric"  
## tot_enr               "integer"  
## grad_rate             "numeric"  
## grad_rateb            "numeric"  
## tot_satact            "integer"  
## tot_absent            "integer"  
## all_cohort_1314       "character"
## tot_algpass_gs0708    "integer"  
## tot_algpass_gs0910    "integer"  
## tot_algpass_gs1112    "integer"  
## tot_sssports          "integer"  
## tot_ssteams           "integer"  
## tot_sspart            "integer"  
## sch_fteteach_tot      "numeric"  
## sch_fteteach_absent   "numeric"  
## sch_fteteach_notcert  "numeric"
```

```r
# well look who sneaked in there
s14$all_cohort_1314 = as.numeric(s14$all_cohort_1314)
```

```
## Warning: NAs introduced by coercion
```

```r
write.csv(s14[,allcolnames], file = "data/y1314_clean.csv", row.names = F)

# clean up
rm(list = ls(pattern = '^names'))
```

### For the 2016 School year


```r
# absenteeism rate
# abs_r = s16[,"tot_absent"] / s16[,"tot_enr"]
# plot(density(abs_r, na.rm = T))

# graduation rate
# grad_r = s16[,"grad_rate"]
# plot(density(grad_r, na.rm = T))

# structural conditions
names_sports = c("tot_sssports", "tot_ssteams", "tot_sspart")
names_teach = names(s16)[grep("_fteteach", names(s16))] 

# administrative care
names_civr = names(s16)[grep("_hb", names(s16))]

# student engagement/achievement
names_enr = names(s16)[grep("enr_", names(s16))]
names_pass = names(s16)[grep("algpass_", names(s16))] # only have for algebra
names_ap = names(s16)[grep("_ap", names(s16))]
names_gt = names(s16)[grep("_gt", names(s16))]
names_other = c("tot_enr", "grad_rate", "grad_rateb", "tot_satact", "tot_absent", "all_cohort_1516")
names_id = c("lea_state", "lea_name", "sch_name", "leaid", "schid")

# grab all the values in the name vectors above
allcolnames = sapply(ls(pattern = '^names'), get) %>% unlist %>% unname
length(which(allcolnames %notin% names(s16)))
```

```
## [1] 0
```

```r
# final type check
sapply(s16[,allcolnames], class) %>% cbind
```

```
##                       .          
## tot_apenr             "integer"  
## tot_apmathenr         "integer"  
## tot_apscienr          "integer"  
## tot_apothenr          "integer"  
## tot_apexam_oneormore  "integer"  
## tot_apexam_none       "integer"  
## tot_appass_oneormore  "integer"  
## tot_appass_none       "integer"  
## sch_hballegations_sex "integer"  
## sch_hballegations_rac "integer"  
## sch_hballegations_dis "integer"  
## tot_hbreported_sex    "integer"  
## tot_hbreported_rac    "integer"  
## tot_hbreported_dis    "integer"  
## tot_hbdisciplined_sex "integer"  
## tot_hbdisciplined_rac "integer"  
## tot_hbdisciplined_dis "integer"  
## tot_algenr_g08        "integer"  
## tot_algenr_gs0910     "integer"  
## tot_algenr_gs1112     "integer"  
## tot_mathenr_alg2      "integer"  
## tot_mathenr_calc      "integer"  
## tot_mathenr_advm      "integer"  
## tot_scienr_biol       "integer"  
## tot_scienr_chem       "integer"  
## tot_scienr_phys       "integer"  
## tot_gtenr             "integer"  
## lea_state             "character"
## lea_name              "character"
## sch_name              "character"
## leaid                 "integer"  
## schid                 "integer"  
## tot_enr               "integer"  
## grad_rate             "numeric"  
## grad_rateb            "numeric"  
## tot_satact            "integer"  
## tot_absent            "integer"  
## all_cohort_1516       "integer"  
## tot_algpass_g08       "integer"  
## tot_algpass_gs0910    "integer"  
## tot_algpass_gs1112    "integer"  
## tot_sssports          "integer"  
## tot_ssteams           "integer"  
## tot_sspart            "integer"  
## sch_fteteach_tot      "numeric"  
## sch_fteteach_absent   "numeric"  
## sch_fteteach_notcert  "numeric"
```

```r
write.csv(s16[,allcolnames], file = "data/y1516_clean.csv", row.names = F)
```

