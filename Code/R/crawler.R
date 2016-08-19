require(XML)
require(magrittr)
require(data.table)
#require(dplyr)

url <- "http://www.c-bike.com.tw/Station1.aspx"

start <- proc.time()  # get beginning time

### crawler code
tbls <- readHTMLTable(url, which = c(34,37), header = FALSE) %>% 
  rbindlist(., use.names = FALSE, fill = FALSE ) %>% 
  data.table(date(), .) %>% 
  set_colnames(c("dateTime", "stopName", "quantity", "vacancy"))

### save as RDS data file
readRDS("C:/Users/will.kuan/Desktop/ProjectX/Data/cityBike_Data.RDS")%>%
  list(.,tbls) %>% 
  rbindlist(., use.names = TRUE, fill = TRUE)%>%
  saveRDS(.,"C:/Users/will.kuan/Desktop/ProjectX/Data/cityBike_Data.RDS")

### get task time
newLog <- data.frame(c(proc.time() - start, time = date())) %>% 
  t() %>% 
  data.frame()

### save task log
read.delim("C:/Users/will.kuan/Desktop/ProjectX/Data/log.txt", header = TRUE, sep = "\t") %>%
  list(., newLog) %>% 
  rbindlist(., use.names = FALSE, fill = FALSE) %>% 
  write.table("C:/Users/will.kuan/Desktop/ProjectX/Data/log.txt", sep = "\t")


### statement below is for first time only
# log <- matrix(c(proc.time() - start, time = date()), nrow = 1, byrow = TRUE) %>%
#   set_colnames(c("user.self", "sys.self", "elapsed", "user.child", "sys.child", "time"))
# 
# write.table(log, "C:/Users/will.kuan/Desktop/ProjectX/Data/log.txt", sep = "\t")

  
  

