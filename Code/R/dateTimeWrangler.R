require(magrittr)
require(data.table)

##################################################################################
### get current locale setting                                                   # 
current <- Sys.getlocale()                                                       #
### save original locale setting as a text file                                  #
write(current, file = sprintf("RStudio_locale_original_%s.txt", Sys.Date()))     #  
                                                                                 #
### set new locale time                                                          #
Sys.setlocale("LC_TIME", "English")   # time will be displayed in English        #
                                                                                 #
##################################################################################

data.bike2 <- readRDS("C:/Users/will.kuan/Desktop/ProjectX/Data/cityBike_Data2.RDS")

### fix cityBike_Data2.RDS data format
### add extra <field> "weekday"

### this code below is about insert new column to the tail of field row
# data.bike2[,weekday:=weekdays(tmp2$dateTime, abbreviate = TRUE)]

### this code bewlow is about insert new column between current columns
data.bike2 <- cbind(data.bike2[,list(dateTime)], 
                    weekday = weekdays(data.bike2$dateTime, abbreviate = TRUE), 
                    data.bike2[,list(stopName,quantity,vacancy)])

### Save data.bike2 as a RDS file
saveRDS(data.bike2, "C:/Users/will.kuan/Desktop/ProjectX/Data/cityBike_Data2.RDS")

####################################################################################
###            fix citybike_data2 as above, fix citybike_data as below           ###     
####################################################################################

data.bike <- readRDS("C:/Users/will.kuan/Desktop/ProjectX/Data/cityBike_Data.RDS")

### cut off weekdays
weekday <- substr(data.bike$dateTime, 1, 3)  # keep it first
data.bike$dateTime <- substr(data.bike$dateTime, 5, 24) ### trim dateTime, keep %Y %b %d %H %M %S

### create a function to get month value from month text 
transforMonth <- function(month.textVec)
{
  month.numberVec <- sapply(month.textVec, switch,
                            "Aug" = "08",           ### for quick searching  
                            "Jan" = "01",
                            "Feb" = "02",
                            "Mar" = "03",
                            "Apr" = "04",
                            "May" = "05",
                            "Jun" = "06",
                            "Jul" = "07",
                            "Sep" = "09",
                            "Oct" = "10",
                            "Nov" = "11", "12")
  return(month.numberVec)
}

### replace all value in dateTime field by correct date time data type
dateTime <- transforMonth(  unlist(lapply(strsplit(data.bike$dateTime, " "), `[[`, 1))  ) %>%
  paste(., substr(data.bike$dateTime, 5, nchar(data.bike$dateTime[1]))) %>%
  as.POSIXct(., format = "%m %d %H:%M:%S %Y")

data.bike <- cbind(dateTime = dateTime, weekday = weekday, data.bike[,list(stopName,quantity,vacancy)])

### save as a RDS file
saveRDS(data.bike, file = "C:/Users/will.kuan/Desktop/ProjectX/Data/cityBike_Data.RDS")



########################################################################
### After task, return to the original locale setting if necessary     #                   
# Sys.setlocale("LC_TIME", "cht")  # get info by current               #                   
########################################################################
 
 
 
