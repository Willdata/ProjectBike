require(mongolite)
require(jsonlite)

### import data.bike into localhost mongoDB
data.bike <- readRDS("citybike_data.RDS")
m.bike <- mongo(collection = "citybike", db = "citybike")
m.bike$insert(data.bike)

### get json file and save it as a text file
json.bike <- tempfile(pattern = "citybike", 
                      tmpdir = tempdir())

system.time(
  m.bike$export(file(json.bike))
)

###########################################
###        output system time info.     ###
###########################################
# Done! Exported a total of 1408152 lines.#
# user  system elapsed                    #
# 49.67   2.10   56.22                    #
###########################################

### export two type of json format file
jsonPath <- tempfile(pattern = "citybike", 
                     tmpdir = tempdir(),
                     fileext = ".txt")

system.time(
  m.bike$export(file(jsonPath))
)

###########################################
###  output txt file system time info.  ###
###########################################
# Done! Exported a total of 1408152 lines.#
# user  system elapsed                    #
# 46.35   1.70   52.17                    #
###########################################
