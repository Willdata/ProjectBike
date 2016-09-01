require(XML)
require(magrittr)
require(data.table)
#require(dplyr)

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

url <- "http://www.c-bike.com.tw/Station1.aspx"

repeat{
  
  start <- proc.time()  # get beginning time
  
  tryCatch(
    {
      ### try part : crawler code
      tbls <- readHTMLTable(url, which = c(34,37), header = FALSE) %>% 
        rbindlist(., use.names = FALSE, fill = FALSE ) %>% 
        data.table(Sys.time(), weekdays(Sys.time(), abbreviate = TRUE), .) %>% 
        set_colnames(c("dateTime", "weekday", "stopName", "quantity", "vacancy"))
      
      ### save as RDS data file
      readRDS("cityBike_Data2.RDS")%>%
        list(.,tbls) %>% 
        rbindlist(., use.names = TRUE, fill = TRUE)%>%
        saveRDS(.,"cityBike_Data2.RDS")
      
      ### get task time
      newLog <- data.frame(c(proc.time() - start, time = date(), msg = NA)) %>% 
        t() %>% 
        data.frame()
      
      ### save task log
      read.delim("log2.txt", header = TRUE, sep = "\t") %>%
        list(., newLog) %>% 
        rbindlist(., use.names = FALSE, fill = FALSE) %>% 
        write.table("log2.txt", sep = "\t", row.names = FALSE)
    },
    ### warning part
    warning = function(w){
      warn <- paste("warning: ", conditionMessage(w))
      
      newLog <- data.frame(c(proc.time() - start, time = date(), msg = warn)) %>% 
        t() %>% 
        data.frame()
      
      read.delim("log2.txt", header = TRUE, sep = "\t") %>%
        list(., newLog) %>% 
        rbindlist(., use.names = FALSE, fill = FALSE) %>% 
        write.table("log2.txt", sep = "\t", row.names = FALSE)
    },
    ### error peart
    error = function(e){
      error <- paste("error: ", conditionMessage(e))
      newLog <- data.frame(c(proc.time() - start, time = date(), msg = error)) %>% 
        t() %>% 
        data.frame()
      
      read.delim("log2.txt", header = TRUE, sep = "\t") %>%
        list(., newLog) %>% 
        rbindlist(., use.names = FALSE, fill = FALSE) %>% 
        write.table("log2.txt", sep = "\t", row.names = FALSE)
    }
  )
  
  if(Sys.Date() == "2016-09-01"){
    break
  }else{
    print(sprintf("agent works - %s", date()))
    Sys.sleep(50)
  }
  
  
}

### statement below is for first time only
#   
# url <- "http://www.c-bike.com.tw/Station1.aspx"
# start <- proc.time()  # get beginning time  
#   
# tryCatch(
#   {
#     ### try part : crawler code
#     tbls <- readHTMLTable(url, which = c(34,37), header = FALSE) %>% 
#       rbindlist(., use.names = FALSE, fill = FALSE ) %>% 
#       data.table(Sys.time(), weekdays(Sys.time(), abbreviate = TRUE), .) %>% 
#       set_colnames(c("dateTime", "weekday", "stopName", "quantity", "vacancy"))
#     
#     ### save as RDS file
#     saveRDS(tbls,"cityBike_Data2.RDS")
#     
#     ### try part : get first log and save as a log file
#     log <- matrix(c(proc.time() - start, time = date(), msg = NA), nrow = 1, byrow = TRUE) %>%
#       set_colnames(c("user.self", "sys.self", "elapsed", "user.child", "sys.child", "time", "msg"))
#     
#     write.table(log, "log2.txt", sep = "\t", row.names = FALSE)
#   },
#     ### error part : return error message
#     error = function(e){
#       error <- paste("error: ", conditionMessage(e))
#       log <- matrix(c(proc.time() - start, time = date(), msg = error), nrow = 1, byrow = TRUE) %>%
#       set_colnames(c("user.self", "sys.self", "elapsed", "user.child", "sys.child", "time", "msg"))
#     
#       write.table(log, "log2.txt", sep = "\t", row.names = FALSE)
#   },
#     ### warning part : return warning message
#     warning = function(w){
#       warn <- paste("warning: ", conditionMessage(w))
#       log <- matrix(c(proc.time() - start, time = date(), msg = warn), nrow = 1, byrow = TRUE) %>%
#       set_colnames(c("user.self", "sys.self", "elapsed", "user.child", "sys.child", "time", "msg"))
#     
#       write.table(log, "log2.txt", sep = "\t", row.names = FALSE)
#   }
# )
#   
