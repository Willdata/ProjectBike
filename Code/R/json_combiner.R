library(data.table)
library(rmongodb)
require(jsonlite)
#library(mongolite)
#library(magrittr)
#library(geojsonio)

### extract data sets
epi1 <- readRDS("cityBike_Data_with7cols.RDS")
epi2 <- readRDS("cityBike_Data2_with5cols.RDS")

### merge data sets 
epi2 <- merge(epi2, geoMap, by = "stopName")
epi2 <- epi2[order(epi2$dateTime),]
epi2 <- setcolorder(epi2, c( "dateTime", "weekday", "stopName", "quantity", "vacancy", "StationLat", "StationLon"))

bike.data <- rbindlist(list(epi1, epi2))

### adjust data type of each columns
bike.data$stopName <- as.character(bike.data$stopName)
bike.data$quantity <- as.numeric(bike.data$quantity)
bike.data$vacancy <- as.numeric(bike.data$vacancy)

### record station names 
stopName.list <- unique(bike.data$stopName)

### create a connection to mongoDB
m <- mongo.create(db = "bike"); mongo.is.connected(m)

for(name in stopName.list)
{
  ### choose one of station names
  tmp <- bike.data[which(bike.data$stopName == name),]  
  tmp <- tmp[,c("stopName"):=NULL]
  
  ### adjust date time data type
  tmp$dateTime <- strftime(tmp$dateTime, "%Y-%m-%dT%H:%M:%S%z")
  
  ### geospatial format
  location <- list(type = "Point", 
                   coordinates = c(geoMap$StationLon[1], geoMap$StationLat[1]))
  
  ### transform list to json format
  myJson <- toJSON(list(station = name, location = location, data = tmp) )
  
  ### json content adjustment
  myJson <- gsub('\\[\"', '\"', myJson)
  (myJson <- gsub('\"\\]', '\"',myJson))
  
  myJson <- gsub('dateTime:', 'dateTime:ISODate\\(', myJson)
  (myJson <- gsub(',week', '\\),week', myJson))
  
  ### output json-format file for back-up
  write(myJson, paste("bike_data_",name,".json"))
  
  ### import data into mongodb
  bson <- mongo.bson.from.JSON(myJson)
  mongo.insert(m, "bike.citybike", bson)
  
  ### response outcome 
  print(paste(name, "is done"))
}
