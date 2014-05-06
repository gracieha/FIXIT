# -----------------------------------------------------------------------------
# top matter
# -----------------------------------------------------------------------------
library(sas7bdat)
library(knitr)
library(tools)
library(plyr)
library(ggplot2)
library(xtable)

# set the PATH environment variable to include the location of pdflatex
Sys.setenv(PATH=paste(Sys.getenv("PATH"),"/usr/texbin",sep=":"))

# set the date of the data cut
cutDate   <- '2014.05.01'
thisYear  <- '2014'
thisMonth <- '05'
prevMonth <- '04'   # the previous report month
prevYear  <- '2014' # the previous report year

# set file locations 
dataLoc <- paste('/Volumes/hpm/Shares/METRC\ Data/fixit/data/monthly/',
                 substr(cutDate, 1, 7), sep='')
progLoc <- '/Volumes/hpm/Shares/METRC\ Data/fixit/programs/monthly/'                 
outLoc  <- '~/Documents/Temp/tempMonthly'
dropbox <- '~/Dropbox/METRC/Reports/FIXIT/Monthly\ Reports/2014/2014_05' 


# set working directory to the output location
setwd(outLoc)

# copy the metrc logo to the working directory
file.copy(from=paste(progLoc, 'METRClogo.pdf', sep=''), 
          to  =outLoc)


# get the data needed to make the report
facilityData   <- read.sas7bdat(paste(dataLoc, '/facilityData.sas7bdat',   sep=''))
enrollmentData <- read.sas7bdat(paste(dataLoc, '/enrollmentData.sas7bdat', sep=''))
visitData      <- read.sas7bdat(paste(dataLoc, '/visitData.sas7bdat', sep=''))
report1_q1     <- read.sas7bdat(paste(dataLoc, '/report1_q1.sas7bdat', sep=''))
report1_q2     <- read.sas7bdat(paste(dataLoc, '/report1_q2.sas7bdat', sep=''))
report1_q3     <- read.sas7bdat(paste(dataLoc, '/report1_q3.sas7bdat', sep=''))
report1_q4     <- read.sas7bdat(paste(dataLoc, '/report1_q4.sas7bdat', sep=''))
report2_q1     <- read.sas7bdat(paste(dataLoc, '/report2_q1.sas7bdat', sep=''))
report2_q2     <- read.sas7bdat(paste(dataLoc, '/report2_q2.sas7bdat', sep=''))
report2_q3     <- read.sas7bdat(paste(dataLoc, '/report2_q3.sas7bdat', sep=''))
report2_q4     <- read.sas7bdat(paste(dataLoc, '/report2_q4.sas7bdat', sep=''))
report2_q5     <- read.sas7bdat(paste(dataLoc, '/report2_q5.sas7bdat', sep=''))
report2_q6     <- read.sas7bdat(paste(dataLoc, '/report2_q6.sas7bdat', sep=''))
report2_q7     <- read.sas7bdat(paste(dataLoc, '/report2_q7.sas7bdat', sep=''))



# -----------------------------------------------------------------------------
# combine facility and enrollment data
# -----------------------------------------------------------------------------
# update dates
facilityData$dateCert              <- format(as.Date('1960-01-01') + facilityData$dateCert,              '%Y-%m')
enrollmentData$screenAndEnrollDate <- format(as.Date('1960-01-01') + enrollmentData$screenAndEnrollDate, '%Y-%m')
enrollmentData$screenAndEnrollYear <- substr(enrollmentData$screenAndEnrollDate, 1, 4)
enrollmentData$screenAndEnrollMonth<- substr(enrollmentData$screenAndEnrollDate, 6, 7)
report1_q1$visitDate               <- format(as.Date('1960-01-01') + report1_q1$visitDate,   '%Y-%m-%d')
report1_q1$windowStart             <- format(as.Date('1960-01-01') + report1_q1$windowStart, '%Y-%m-%d')
report1_q1$windowEnd               <- format(as.Date('1960-01-01') + report1_q1$windowEnd,   '%Y-%m-%d')
report1_q2$windowStart             <- format(as.Date('1960-01-01') + report1_q2$windowStart, '%Y-%m-%d')
report1_q2$windowEnd               <- format(as.Date('1960-01-01') + report1_q2$windowEnd,   '%Y-%m-%d')
report2_q1$orTripDate              <- format(as.Date('1960-01-01') + report2_q1$orTripDate,  '%Y-%m-%d')
report2_q3$eventDate               <- format(as.Date('1960-01-01') + report2_q3$eventDate,   '%Y-%m-%d')
report2_q4$eventDate               <- format(as.Date('1960-01-01') + report2_q4$eventDate,   '%Y-%m-%d')
report2_q5$eventDate               <- format(as.Date('1960-01-01') + report2_q5$eventDate,   '%Y-%m-%d')
report2_q6$eventDate               <- format(as.Date('1960-01-01') + report2_q6$eventDate,   '%Y-%m-%d')
report2_q7$eventDate               <- format(as.Date('1960-01-01') + report2_q7$eventDate,   '%Y-%m-%d')


# merge
d <- merge(facilityData, enrollmentData, by='facility', all.x=TRUE)

# convert factor to char
d$facility <- as.character(d$facility)
d$id       <- as.character(d$id)

# manage NAs
d$screened            <- ifelse(is.na(d$screened),           0, d$screened)
d$eligible            <- ifelse(is.na(d$eligible),           0, d$eligible)
d$refused             <- ifelse(is.na(d$refused),            0, d$refused)
d$enrolled            <- ifelse(is.na(d$enrolled),           0, d$enrolled)
d$group               <- ifelse(is.na(d$group),              0, d$group)
d$completedStudy      <- ifelse(is.na(d$completedStudy),     0, d$completedStudy)

# finally, note that TGH and SJH belong to FOI and HCM and UMN belong to MIN
FOI <- c('TGH', 'SJH')
MIN <- c('HCM', 'UMN')



# -----------------------------------------------------------------------------
# run the reports
# -----------------------------------------------------------------------------
# create a facilities vector including 'ALL' as though a facility
facilities <- c('ALL', unique(d$facility))


# remove files in the directory
removeReports <- function(facility) {
  baseName <- paste('./fixitMonthly_', cutDate, '_', facility, sep='')
  if (file.exists(paste(baseName, '.tex', sep=''))) file.remove(paste(baseName, '.tex', sep=''))
  if (file.exists(paste(baseName, '.log', sep=''))) file.remove(paste(baseName, '.log', sep=''))
  if (file.exists(paste(baseName, '.aux', sep=''))) file.remove(paste(baseName, '.aux', sep=''))
  if (file.exists(paste(baseName, '.pdf', sep=''))) file.remove(paste(baseName, '.pdf', sep=''))
  if (file.exists('./figure/figure1.pdf'))          file.remove('./figure/figure1.pdf')
  if (file.exists('./figure'))                      file.remove('./figure')    
}
for (facility in facilities) {
  removeReports(facility)
}

# make the report, iterating over facilities
for (facility in facilities) {
  knit2pdf(paste(progLoc, 'monthlyReport.rnw', sep=''), 
           paste('fixitMonthly_', cutDate, '_', facility, '.tex', sep=''),
  compiler='pdflatex')

}


# -----------------------------------------------------------------------------
# copy the PDFs to dropbox
# -----------------------------------------------------------------------------
for (facility in facilities) {
  file.copy(from=paste('./fixitMonthly_', cutDate, '_', facility, '.pdf', sep=''), 
            to  =dropbox)
}














