#######################################################
#                                                     #
#             import data to R                        #
# e.g. data.bike <- readRDS("path of bike data")      #
#                                                     #      
#######################################################

# data.bike <- readRDS("C:\\Users\\will.kuan\\Desktop\\ProjectX\\Data\\cityBike_Data.RDS")
# data.bikeWithRowName <- data.bike


row.names(data.bikeWithRowName) <- paste(data.bikeWithRowName$dateTime, 
                                         data.bikeWithRowName$stopName, 
                                         sep = " ")

View(data.bikeWithRowName)
  