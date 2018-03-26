source("load_packages.R")
source("weblog_to_json.R")

library(stringi)

# encode the "request" column into the native encoding format ie, "WINDOWS-1252"
stri_enc_tonative(weblog$request) -> weblog$request

# create a connection between the couchDb local server instance and R
con <- Cushion$new(user = 'admin', pwd = 'admin')

# create the database
db_create(con, 'weblog')

db_list(con)

# add row_id to weblog
weblog %>%
  arrange(timestamp) %>%
  mutate(row_id = row_number()) -> weblog

# create a sequence to loop through
c(seq(from =0, to = 2408625, by = 200000),2408625) -> row_seq

# function to filter the data and bul upload based on row_id
couch_bulk_upload_custom <- function(gte, lte){
  weblog %>%
    filter(row_id > gte & row_id <= lte ) %>%
    select(-row_id) %>%
    db_bulk_create(con, doc = ., dbname = 'weblog')
}

# loop through the sequence pass the variables from the sequence 
# into gte and lte parameters and bulk upload the data
for(i in seq(1,13,1)){
  couch_bulk_upload_custom(row_seq[i], row_seq[i+1])
  
}




