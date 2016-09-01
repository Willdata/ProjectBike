require(XML)
require(magrittr)
require(data.table)
options(digits = 15)

### compare two crawler code 

### method 1
ptm <- proc.time()
url <- "http://www.c-bike.com.tw/Station1.aspx"

tbls <- readHTMLTable(url, which = c(34,37), header = FALSE) %>% 
  rbindlist(., use.names = FALSE, fill = FALSE ) %>% 
  data.table(Sys.time(), weekdays(Sys.time(), abbreviate = TRUE), .) %>% 
  set_colnames(c("dateTime", "weekday", "stopName", "quantity", "vacancy"))

tbls <- merge(tbls, bike.coordinates, by = "stopName")

proc.time() - ptm

### method 2
ptm <- proc.time()
doc <- xmlParse("http://www.c-bike.com.tw/xml/stationlistopendata.aspx", encoding = "UTF-8")
fields <- c('StationName','StationLat','StationLon','StationNums1','StationNums2')

  tmp <- xmlToDataFrame(nodes = getNodeSet(doc, "/BIKEStationData/BIKEStation/Station"))[,c(7,9,10,12,13)] %>%
    data.frame(Sys.time(), weekdays(Sys.time(), abbreviate = TRUE), .) %>% 
    set_colnames((c("dateTime", "weekday", "stationName", "stationLat", "stationLon", "quantity", "vacancy")))
  
proc.time() - ptm
