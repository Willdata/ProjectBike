require(XML)
require(magrittr)
require(data.table)
#require(dplyr)


repeat{
    
  url <- "http://www.c-bike.com.tw/Station1.aspx"
  start <- proc.time()  # get beginning time
  
  tryCatch(
  {
    ### try part : crawler code
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
    newLog <- data.frame(c(proc.time() - start, time = date(), msg = NA)) %>% 
      t() %>% 
      data.frame()
    
    ### save task log
    read.delim("C:/Users/will.kuan/Desktop/ProjectX/Data/log.txt", header = TRUE, sep = "\t") %>%
      list(., newLog) %>% 
      rbindlist(., use.names = FALSE, fill = FALSE) %>% 
      write.table("C:/Users/will.kuan/Desktop/ProjectX/Data/log.txt", sep = "\t", row.names = FALSE)
  },
    ### warning part
    warning = function(w){
      warn <- paste("warning: ", conditionMessage(w))
      
      newLog <- data.frame(c(proc.time() - start, time = date(), msg = warn)) %>% 
        t() %>% 
        data.frame()
      
      read.delim("C:/Users/will.kuan/Desktop/ProjectX/Data/log.txt", header = TRUE, sep = "\t") %>%
        list(., newLog) %>% 
        rbindlist(., use.names = FALSE, fill = FALSE) %>% 
        write.table("C:/Users/will.kuan/Desktop/ProjectX/Data/log.txt", sep = "\t", row.names = FALSE)
  },
    ### error peart
    error = function(e){
      error <- paste("error: ", conditionMessage(e))
      newLog <- data.frame(c(proc.time() - start, time = date(), msg = error)) %>% 
        t() %>% 
        data.frame()
      
      read.delim("C:/Users/will.kuan/Desktop/ProjectX/Data/log.txt", header = TRUE, sep = "\t") %>%
        list(., newLog) %>% 
        rbindlist(., use.names = FALSE, fill = FALSE) %>% 
        write.table("C:/Users/will.kuan/Desktop/ProjectX/Data/log.txt", sep = "\t", row.names = FALSE)
  }
  )
  
  if(Sys.Date() == "2016-08-22"){
    break
  }else{
    print(sprintf("agent works - %s", date()))
    Sys.sleep(50)
  }
  

}
### statement below is for first time only
# tryCatch(
#   {
#     ### try part : get first log and save as a log file
#     log <- matrix(c(proc.time() - start, time = date(), msg = NA), nrow = 1, byrow = TRUE) %>%
#       set_colnames(c("user.self", "sys.self", "elapsed", "user.child", "sys.child", "time", "msg"))
#     
#     write.table(log, "C:/Users/will.kuan/Desktop/ProjectX/Data/log.txt", sep = "\t", row.names = FALSE)
#   },
#     ### error part : return error message
#     error = function(e){
#       error <- paste("error: ", conditionMessage(e))
#       log <- matrix(c(proc.time() - start, time = date(), msg = error), nrow = 1, byrow = TRUE) %>%
#       set_colnames(c("user.self", "sys.self", "elapsed", "user.child", "sys.child", "time", "msg"))
#     
#       write.table(log, "C:/Users/will.kuan/Desktop/ProjectX/Data/log.txt", sep = "\t", row.names = FALSE)
#   },
#     ### warning part : return warning message
#     warning = function(w){
#       warn <- paste("warning: ", conditionMessage(w))
#       log <- matrix(c(proc.time() - start, time = date(), msg = warn), nrow = 1, byrow = TRUE) %>%
#       set_colnames(c("user.self", "sys.self", "elapsed", "user.child", "sys.child", "time", "msg"))
#     
#       write.table(log, "C:/Users/will.kuan/Desktop/ProjectX/Data/log.txt", sep = "\t", row.names = FALSE)
#   }
# )
#   
  

