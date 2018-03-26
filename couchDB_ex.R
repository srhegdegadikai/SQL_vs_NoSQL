source("load_packages.R")


# create a connection between the couchDb local server instance and R
con <- Cushion$new(user = 'admin', pwd = 'admin')

con$ping()

# range query between two given dates
db_query(con, dbname = 'weblog', 
         query = '{
         "selector": {
            "timestamp": {"$gte" : "1995-06-01 06:00:59"},
            "timestamp": {"$lte" : "1995-11-15 11:59:59"}
         }
         }')

?sofa::doc_get()
