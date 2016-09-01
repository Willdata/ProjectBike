library(openxlsx)
library(data.table)
coordinates <- read.xlsx("Station_Coordinates.csv")
data.bike2 <- readRDS("cityBike_Data2_with5cols.RDS")

data.bike2 <- merge(data.bike2, coordinates, by = "stopName")
data.bike2 <- data.bike2[order(data.bike2$dateTime),]
data.bike2 <- setcolorder(data.bike2, c( "dateTime", "weekday", "stopName", "quantity", "vacancy", "StationLat", "StationLon"))


saveRDS(data.bike2, "cityBike_Data2_with7cols.RDS")


### remove two columns in data.table
data.bike2 <- data.bike2[,StationLat := NULL]
data.bike2 <- data.bike2[,StationLon := NULL]
