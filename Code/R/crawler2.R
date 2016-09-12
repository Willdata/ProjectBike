require(XML)
require(magrittr)
require(data.table)
#require(openxlsx)
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

### get url
url <- "http://www.c-bike.com.tw/Station1.aspx"

### create a log saver 
logSaver <- function(log_path, new_log)
{
  read.delim(log_path, header = TRUE, sep = "\t") %>%
    list(., new_log) %>% 
    rbindlist(., use.names = FALSE, fill = FALSE) %>% 
    write.table(log_path, sep = "\t", row.names = FALSE)
}

### create a file generator
log_Builder <- function(path)
{
  ### create an empty matrix with col title, and output an empty text log file
  matrix(data = numeric(0), ncol = 7) %>% 
    set_colnames(., c("user.self", "sys.self", "elapsed", "user.child", "sys.child", "time", "msg")) %>% 
    write.table(., path, sep = "\t")
}

RDS_Builder <- function(path)
{
  ### create an empty data.frame with column names only for initial empty table 
  emptyMat <- data.frame(matrix(data = numeric(0), ncol = 5)) %>% 
    set_colnames(., c("dateTime", "weekday", "stopName", "quantity", "vacancy")) 
  
  ### for correct combination with tbls
  emptyMat$dateTime <- as.POSIXct(emptyMat$dateTime, origin = "1970-01-01")
  emptyMat$weekday <- as.character(emptyMat$weekday)
  emptyMat$stopName <- as.factor(emptyMat$stopName)
  emptyMat$quantity <- as.factor(emptyMat$quantity)
  emptyMat$vacancy <- as.factor(emptyMat$vacancy)
  
  ### save RDS of empty conetent
  saveRDS(emptyMat, path)
}


### initial path for code activation
logPath <- paste("daily_log/log_",Sys.Date(),".txt", sep = "")
RDSPath <- paste("daily_data/cityBike_Data_",Sys.Date(),".RDS", sep = "")

if(!file.exists(logPath)){
  log_Builder(logPath)
}
if(!file.exists(RDSPath)){
  RDS_Builder(RDSPath)
}


repeat{
  
  start <- proc.time()  # get beginning time
  
  ##################################################################################################################################
  ### if end of the day is coming, make an empty log text file for next day
  if( hour(Sys.time()) == 00 & substr(Sys.time(),15,16) == "00" )
  {
    logPath <- paste("daily_log/log_",Sys.Date(),".txt", sep = "")
    RDSPath <- paste("daily_data/cityBike_Data_",Sys.Date(),".RDS", sep = "")
    
    log_Builder(logPath) ; RDS_Builder(RDSPath)
    
  }
  ##################################################################################################################################
  
  ### main job -- extracting
  tryCatch(
    {
      ### try part : crawler code
      tbls <- readHTMLTable(url, which = c(34,37), header = FALSE) %>% 
        rbindlist(., use.names = FALSE, fill = FALSE ) %>% 
        data.table(Sys.time(), weekdays(Sys.time(), abbreviate = TRUE), .) %>% 
        set_colnames(c("dateTime", "weekday", "stopName", "quantity", "vacancy"))
      
      ### save as RDS file
      readRDS(RDSPath)%>%
        list(.,tbls) %>% 
        rbindlist(., use.names = TRUE, fill = FALSE)%>%
        saveRDS(.,RDSPath)
      
      ### get task time
      newLog <- data.frame(c(proc.time() - start, time = date(), msg = NA)) %>% 
        t() %>% 
        data.frame()
      
      ### save task log
      logSaver(logPath, newLog)
    },
      ### error part : return error message
      error = function(e){
        error <- paste("error: ", conditionMessage(e))
        newLog <- data.frame(c(proc.time() - start, time = date(), msg = error)) %>% 
          t() %>% 
          data.frame()
        
        logSaver(logPath, newLog)
    },
      ### warning part : return warning message
      warning = function(w){
        warn <- paste("warning: ", conditionMessage(w))
        newLog <- data.frame(c(proc.time() - start, time = date(), msg = warn)) %>% 
          t() %>% 
          data.frame()
        
        logSaver(logPath, newLog)
    }
  )
  
  ### end point
  if(Sys.Date() == "2016-09-30"){
    break
  }else{
    print(sprintf("agent works - %s", date()))
    Sys.sleep(50)
  }
}
