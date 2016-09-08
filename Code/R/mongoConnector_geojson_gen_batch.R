require(geojsonio)
require(openxlsx)
require(rmongodb)
require(jsonlite)

options(digits = 20)

geoMap <- read.xlsx("Station_Coordinates.xlsx")
geoMap$StationLat <- as.numeric(geoMap$StationLat)
geoMap$StationLon <- as.numeric(geoMap$StationLon)

### convert to geojson format
geojson <- geojson_json(geoMap, lat = 'StationLat', lon = 'StationLon', pretty = TRUE)

### output json-format geojson file
write(geojson, "GeoSpatial.json")

### connecting to mongodb
m <- mongo.create(db = "bike")  ; mongo.is.connected(m)

### convert to bson-format 
bson <- mongo.bson.from.JSON(geojson)

### insert to mongodb
mongo.insert(m, ns = "bike.geolocation", bson)
