# -----------------------------------------------------------------------------
# top matter
# -----------------------------------------------------------------------------
library(sas7bdat)
library(plyr)

# set the date of the data cut
cutDate   <- '2014.04.01'
thisYear  <- '2014'
thisMonth <- '04'
prevMonth <- '03'   # the previous report month
prevYear  <- '2014' # the previous report year

# set file locations 
dataLoc <- paste('/Volumes/hpm/Shares/METRC\ Data/fixit/data/monthly/',
                 substr(cutDate, 1, 7), sep='')
progLoc <- '/Volumes/hpm/Shares/METRC\ Data/fixit/programs/monthly/'                 
outLoc  <- '~/Documents/Temp'

# set working directory to the output location
setwd(outLoc)


# get the data needed to make the report
facilityData   <- read.sas7bdat(paste(dataLoc, '/facilityData.sas7bdat',   sep=''))
enrollmentData <- read.sas7bdat(paste(dataLoc, '/enrollmentData.sas7bdat', sep=''))
visitData      <- read.sas7bdat(paste(dataLoc, '/visitData.sas7bdat', sep=''))

# convert factors to strings
facilityData$facility   <- as.character(facilityData$facility)
enrollmentData$facility <- as.character(enrollmentData$facility)
                                       
# create a variable for month of enrollment
enrollmentData$screenAndEnrollDate <- format(as.Date('1960-01-01') + enrollmentData$screenAndEnrollDate, 
                                             '%Y-%m')
                                             
                                             
# -----------------------------------------------------------------------------
# get enrollments by facility
# -----------------------------------------------------------------------------
# merge facility to enrollment
enrollments  <- merge(facilityData[ , c('facility', 'facilityType')],
                      ddply(enrollmentData, .(facility), summarise, enrolled=sum(enrolled)),
                      by='facility',
                      all.x=TRUE)

# save as .csv
write.csv(enrollments, './enrollments.csv', row.names=FALSE)


# -----------------------------------------------------------------------------
# similarly, get enrollments by facility and month
# -----------------------------------------------------------------------------
# overwrite the dual-sites with a common facility
enrollmentData$facility <- ifelse(enrollmentData$facility %in% c('HCM','UMN'), 'MIN',
                                  ifelse(enrollmentData$facility %in% c('TGH','SGH'), 'FOI',
                                         enrollmentData$facility))

# create all facility-month combinations over the last 24 months
dates        <- seq.Date(from=as.Date(cutDate,      '%Y.%m.%d'), 
                         to  =as.Date('2011.01.01', '%Y.%m.%d'), 
                         by  ='-1 month')[2:25]
dates        <- format(dates, '%Y-%m')
facilities2  <- c('ALL', unique(enrollmentData$facility)) 
dateUniverse <- NULL
for (facility2 in facilities2) {
  dateUniverse <- rbind(dateUniverse,
                        data.frame(`facility`           =rep(facility2, length(dates)),
                                   `screenAndEnrollDate`=dates))
  }
dateUniverse$facility            <- as.character(dateUniverse$facility)
dateUniverse$screenAndEnrollDate <- as.character(dateUniverse$screenAndEnrollDate)                           

# create table 2 
enrollments2 <- rbind(ddply(enrollmentData, .(screenAndEnrollDate), summarise,
                        facility='ALL', 
                        screened=sum(screened),
                        enrolled=sum(enrolled)),
                      ddply(enrollmentData, .(screenAndEnrollDate, facility), summarise, 
                        screened=sum(screened),
                        enrolled=sum(enrolled)))

# merge to the universe of dates - not all sites have screen and enroll in every 
# month
enrollments2 <- merge(dateUniverse, 
                      enrollments2, 
                      by=c('facility', 'screenAndEnrollDate'),
                      all.x=TRUE)

enrollments2$screened <- ifelse(is.na(enrollments2$screened), 0, enrollments2$screened)
enrollments2$enrolled <- ifelse(is.na(enrollments2$enrolled), 0, enrollments2$enrolled)

# apply an order to the facilities
facilityOrder <- c('ALL','UMD','CMC','HOU','WFU','MIN','MET','ORL','RYD','FOI',
                   'PSU','MTH','UMS','USF','BAM','DHA','ELP','VMC','WRD','STL',
                   'UIA','BMC','STV','NPM')
facilityOrder <- c(facilityOrder, facilities2[!(facilities2 %in% facilityOrder)])                  
enrollments2$facility <- factor(enrollments2$facility, levels=facilityOrder)
enrollments2 <- enrollments2[order(enrollments2$facility), ]


# reshape to fit spreadsheet
screensByMonth <- reshape(enrollments2, v.names='screened', timevar='facility', 
                  idvar='screenAndEnrollDate', direction='wide', sep='', 
                  drop=c('enrolled'))  

enrollsByMonth <- reshape(enrollments2, v.names='enrolled', timevar='facility', 
                  idvar='screenAndEnrollDate', direction='wide', sep='', 
                  drop=c('screened')) 

# write to csv
write.csv(screensByMonth, './screensByMonth.csv', row.names=FALSE)
write.csv(enrollsByMonth, './enrollsByMonth.csv', row.names=FALSE)


                   
                   
















