library(dplyr)
library(rvest)
library(magrittr)
library(data.table)

for(i in 1:100000){
url <- "http://www.c-bike.com.tw/Station1.aspx"
system.time(
  db_output <- url %>% 
    read_html() %>% 
    html_nodes('#ctl00_ContentPlaceContent_GridView1')%>%
    html_nodes('tr')%>%
    html_nodes('td')%>%
    html_text()%>%iconv("UTF-8","UTF-8")%>%
    matrix(.,ncol=3,byrow=TRUE)%>%
    cbind.data.frame(date(),.) %>%
    set_colnames(c("dateTime","stopName","quantity","vacancy"))
)

system.time(
  
  readRDS("C:/Users/G/Desktop/db_output.RDS")%>%
    rbind.data.frame(.,db_output)%>%
    saveRDS(.,"C:/Users/G/Desktop/db_output.RDS")
)
 print(i)
 Sys.sleep(50)
}
