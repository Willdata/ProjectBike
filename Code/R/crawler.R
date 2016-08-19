require(XML)
require(magrittr)
require(data.table)
#require(dplyr)

url <- "http://www.c-bike.com.tw/Station1.aspx"


system.time(
  tbls <- readHTMLTable(url, which = c(34,37), header = FALSE) %>% 
    rbindlist(., use.names = FALSE, fill = FALSE ) %>% 
    data.table(date(), .) %>% 
    set_colnames(c("dateTime", "stopName", "quantity", "vacancy"))
)

system.time(
  readRDS("C:/Users/will.kuan/Desktop/ProjectX/Data/cityBike_Data.RDS")%>%
    list(.,tbls) %>% 
    rbindlist(., use.names = TRUE, fill = TRUE)%>%
    saveRDS(.,"C:/Users/will.kuan/Desktop/ProjectX/Data/cityBike_Data.RDS")
)


