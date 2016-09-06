require(XML)
require(RCurl)
require(magrittr)
require(data.table)

##################################################################################
### get current locale setting                                                   # 
current <- Sys.getlocale()                                                       #
### save original locale setting as a text file                                  #
write(current, file = sprintf("R_locale_original_%s.txt", Sys.Date()))           #  
                                                                                 #
### set new locale time                                                          #
Sys.setlocale("LC_TIME", "English")   # time will be displayed in English        #
                                                                                 #
##################################################################################

### url parsing
part <- "http://e-service.cwb.gov.tw/HistoryDataQuery/DayDataController.do?command=viewMain&"

token <- c("station=467440&stname=%25E9%25AB%2598%25E9%259B%2584&datepicker=",
           "station=C0V250&stname=%25E7%2594%25B2%25E4%25BB%2599&datepicker=",
           "station=C0V310&stname=%25E7%25BE%258E%25E6%25BF%2583&datepicker=",
           "station=C0V440&stname=%25E9%25B3%25B3%25E5%25B1%25B1&datepicker=",
           "station=C0V670&stname=%25E6%25A5%25A0%25E6%25A2%2593&datepicker=",
           "station=C0V710&stname=%25E8%258B%2593%25E9%259B%2585&datepicker=",
           "station=C0V740&stname=%25E6%2597%2597%25E5%25B1%25B1&datepicker=",
           "station=C0V800&stname=%25E5%2585%25AD%25E9%25BE%259C&datepicker=")

### get 8/19 - 9/5
date.list <- as.Date(substr(Sys.time(),1,10)) - 18:1

myLink <- paste(part,token, sep = "")

### name title 
title <- c("觀測時間(LST)ObsTime", "測站氣壓(hPa)StnPres", "海平面氣壓(hPa)SeaPres", 
           "氣溫(℃)Temperature", "露點溫度(℃)Td dew point","相對溼度(%)RH", 
           "風速(m/s)WS", "風向(最多風向)(360degree)WD", "最大陣風(m/s)WSGust", 
           "最大陣風風向(360degree)WDGust", "降水量(mm)Precp", "降水時數(hr)PrecpHour", 
           "日照時數(hr)SunShine", "全天空日射量(MJ/㎡)GloblRad", "能見度(km)Visb")

### define columns' data type 
col.type <- rep("numeric", 15) 

### create an empty data.frame with column names only for initial table
myTable <- data.frame(matrix(data = numeric(0), ncol = 19)) %>% 
  set_colnames(., c("city", "area", "time", "weekday", title))

for(i in c(1,2,4)){
  myTable[,i] <- as.factor(myTable[,i])
}

myTable[,3] <- as.POSIXct(myTable[,3], origin = "1970-01-01")


### start for-loop to complete a big weather table
system.time(
for(x in 1:length(myLink))
{
  url <- paste(myLink[x], date.list, sep = "")

  for(y in 1:length(url))
  {
    doc <- readHTMLTable(url[y], which = 2, skip.rows = c(1,2), 
                         colClasses = col.type, encoding = "utf-8") %>% 
      set_colnames(., title)
    
    doc.tag <- readHTMLTable(url[y], which = 1, header = c(""), encoding = "UTF-8")
    doc.tag <- c(unlist(strsplit(x = as.character(doc.tag[1,1]), split = ":")), 
                 unlist(strsplit(x = as.character(doc.tag[1,3]), split = ":")))
    
    time <- sprintf("%s:00", c(0:23)) %>% 
      paste(doc.tag[4], .) %>% 
      as.POSIXct(.)
    
    myDoc <- cbind(city = "高雄市", area = doc.tag[2], time, weekday = weekdays(time), doc)
    
    myTable <- rbindlist(list(myTable, myDoc))
    
    ### optional
    print(sprintf("%s %s Done!", doc.tag[2], doc.tag[4]))
  }
}
)
