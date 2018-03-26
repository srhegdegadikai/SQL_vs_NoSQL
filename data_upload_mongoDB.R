source("load_packages.R")
source("weblog_to_json.R")

library(stringi)

# encode the "request" column into the native encoding format ie, "WINDOWS-1252"
stri_enc_tonative(weblog$request) -> weblog$request

# create a path variable to the .json file where weblog needs to be written
#path_variable <- paste(getwd(), "/weblog.json",sep = "")

#weblog %>%
# toJSON(x=., raw = "mongo") %>%
 # write_lines(x=., path = path_variable)

# create a connection to the mongoDB server instance
con <- mongo(collection = "weblog", url = "mongodb://localhost/27017")

con$insert(weblog)
con$count()

