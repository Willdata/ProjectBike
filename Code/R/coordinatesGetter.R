library(package = "XML")

### crawl xml document
doc <- xmlParse("http://www.c-bike.com.tw/xml/stationlistopendata.aspx", encoding = "UTF-8")

### parse xml document
bikeInfo.df <- xmlToDataFrame(nodes = getNodeSet(doc, "/BIKEStationData/BIKEStation/Station"))

### load data
data.bike <- readRDS("cityBike_Data_with5cols.RDS")

### get all station names
bike.order <- head(data.bike, 184)
bike.order <- data.frame(stopNo = 1:184, stopName = bike.order$stopName)

### merge two data frame to combine station name and (lat,lon)
### most importantly, check if stopNames in db data is equivent to StationNames in xml document
### otherwise, we need to match stopName with lat and lon one by one manually
bike.coordinates <- merge(bike.order, 
                          bikeInfo.df[,c("StationName", "StationLat", "StationLon")],
                          by.x = "stopName", by.y = "StationName")

### sort according to db order
bike.coordinates <- bike.coordinates[order(bike.coordinates$stopNo),]
row.names(bike.coordinates) <- bike.coordinates$stopNo

### cut an unnecessary column
bike.coordinates <- bike.coordinates[,c(1,3,4)]

### check whether each stop name and coordinates in bike.coordinates match coordinates in bikeInfo.df
bike.coordinates[which(bike.coordinates$stopName == "平和停車場站"),c("StationLat", "StationLon")] == bikeInfo.df[which(bikeInfo.df$StationName == "平和停車場站"),c("StationLat", "StationLon")]

### check automatically
name.list <- bike.coordinates$stopName

for( i in name.list)
{
  print(sprintf("stopName : %s in bike.coordinates vs. StationName : %s in bikeInfo.df", i, i))
  v <- bike.coordinates[which(bike.coordinates$stopName == i),c("StationLat", "StationLon")] == bikeInfo.df[which(bikeInfo.df$StationName == i),c("StationLat", "StationLon")]
  if(v == TRUE){
    print(v)
  }else{
    print(v)
    break
  }
}

### output
write.csv(bike.coordinates, file = "Station_Coordinates.csv")

