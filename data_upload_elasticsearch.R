source("load_packages.R")
source("weblog_to_json.R")

# create a path variable to the .json file where weblog needs to be written
path_variable <- paste(getwd(), "/data/weblog.json",sep = "")

#weblog %>%
# toJSON(x=.) %>%
#write_lines(x=., path = path_variable)

# prep the weblog to be written into the elasticsearch data-store
docs_bulk_prep(x = weblog, index = "weblog", path = path_variable)

# connect to the elasticsearch local client
connect()

# create "mappings" for the "type" of data
# in RDB terms, create a table and list all the datatypes for indvidual columns
# not necessary but helps in the longrun
mapping_body <-'{
  "mappings" : {
    "weblog": {
      "properties": {
        "host" : {"type" : "keyword"},
        "timestamp": {"type" : "date",
                      "format" : "yyyy-MM-dd HH:mm:ss"
                      },
        "request" : {"type" : "text"},
        "HTTP_reply" : {"type" : "long"},
        "reply_size" : {"type" : "long"}
      }
    }
  }
}'


# create the field mapping in the index
index_create(index = "weblog", body = mapping_body)

# get the file paths to the .json files that need 
# to be put into the elasticseacrh index
path_to_files <- paste(getwd(),"/data", sep = "")
files <- list.files(path = path_to_files, full.names = TRUE, recursive = F)

# recursivley bulk load all the prepared json files into the data store
for(i in seq_along(files)){
  invisible(
    docs_bulk(
      x =sprintf(files[i]), index = "weblog"
    )
  )
}
