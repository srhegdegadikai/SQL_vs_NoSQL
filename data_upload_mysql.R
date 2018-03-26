source("load_packages.R")
source("weblog_to_json.R")

# create a connection to the database
con <- dbConnect(RMySQL::MySQL(),  user = "root", password = "Gadikai123",
                                                            dbname = "apache_logs")

# make sure there is no table called weblog
dbListTables(con)

# create a table called weblog with all the listed attributes
#dbSendQuery(con, 
            "CREATE TABLE weblog (
              host VARCHAR(255),
              timestamp DATETIME,
              request VARCHAR(255),
              HTTP_reply INTEGER,
              reply_size BIGINT
            )"#)

# load the data into the weblog table
dbWriteTable(con, "weblog", weblog, row.names = FALSE, overwrite=TRUE)

# alter the table so that timestamp is datetime again
dbSendQuery(con,
            "ALTER TABLE weblog
              MODIFY timestamp DATETIME")
dbSendQuery(con,
            "ALTER TABLE weblog
              MODIFY host VARCHAR(255)")

dbSendQuery(con,
            "ALTER TABLE weblog
              MODIFY request VARCHAR(1000)")

