library(data.table)
# Texas Health Care Information Collection (THCIC)
# Texas Inpatient Public Use Data File (pudf)
# Hospital Discharge Data Public Use Data File ()
# https://www.dshs.texas.gov/texas-health-care-information-collection/health-data-researcher-information/texas-inpatient-public-use
# bad link https://www.dshs.texas.gov/THCIC/Hospitals/Download.shtm


d = fread(file = 'data.table/data/PUDF_base1_1q2016_tab.txt'
          , sep = '\t'
          #, header = FALSE
          #, nrows = 1000
          , fill = TRUE # because header is one filed longer than the data
          , stringsAsFactors = TRUE
          , na.strings = ""
          )
# remove bad header-column
d$V167 = NULL

# set factors -------------------------------------------------------------
d$RACE = factor(d$RACE
                , levels = c(1:5, '`')
                , labels = c('American Indian/Eskimo/Aleut'
                             , 'Asian or Pacific Islander'
                             , 'Black'
                             , 'White'
                             , 'Other'
                             , 'Invalid')
                )

sapply(d, class)
object.size(d) # 1.514.832 (char), 1.236.600 (factors). 553.362.600
summary(d)
