require(geojsonio)
require(openxlsx)
require(rmongodb)
require(jsonlite)
require(mongolite)

options(digits = 20)

geoMap <- read.xlsx("Station_Coordinates.xlsx")
geoMap$StationLat <- as.numeric(geoMap$StationLat)
geoMap$StationLon <- as.numeric(geoMap$StationLon)

### connecting to mongodb
m <- mongo.create(db = "bike")  ; mongo.is.connected(m)

for(i in 1:nrow(geoMap))
{
  ### convert to geojson format
  geojson <- geojson_json(geoMap[i,], lat = 'StationLat', lon = 'StationLon', pretty = TRUE)
  
  ### convert to bson-format 
  bson <- mongo.bson.from.JSON(geojson)
  
  ### insert to mongodb
  mongo.insert(m, ns = "bike.geolocation", bson)
}

m.con <- mongo(collection = "geolocation", db = "bike")
m.con$export(file("geoMap.json"))
