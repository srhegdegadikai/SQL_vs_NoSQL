source("load_packages.R")

# create a connection to the database
con <- dbConnect(RMySQL::MySQL(),  user = "root", password = "Gadikai123",
                 dbname = "apache_logs")

# make sure there is a table called weblog
dbListTables(con)


# range query between two given dates
mysql_range <- function(){
dbSendQuery(con,
            "SELECT COUNT(timestamp)
              FROM weblog
              WHERE timestamp >= '1995-06-01 06:00:59' AND timestamp <= '1995-11-15 11:59:59'")-> s 
dbFetch(s)
dbClearResult(s)}



# top visitors
mysql_count_groupby_host <- function(){
dbSendQuery(con,
            "SELECT host,COUNT(*)
              FROM weblog
              GROUP BY host
              ORDER BY COUNT(*) DESC
              LIMIT 10") -> s
dbFetch(s)
dbClearResult(s)}


# count for HTTP_reply's
mysql_count_groupby_http <- function(){
dbSendQuery(con,
            "SELECT HTTP_reply,COUNT(*)
            FROM weblog
            GROUP BY HTTP_reply
            ORDER BY COUNT(*) DESC
            LIMIT 10") -> s
dbFetch(s)
dbClearResult(s)}

# min and max reply_size
mysql_min_max <- function(){
dbSendQuery(con,
            "SELECT MIN(reply_size), MAX(reply_size)
            FROM weblog") -> s
dbFetch(s)
dbClearResult(s)}

# avg reply sizes for top 10 visitors
mysql_group_by_avg <- function(){
dbSendQuery(con,
            "SELECT host,COUNT(*), AVG(reply_size) 
              FROM weblog
              GROUP BY host
              ORDER BY COUNT(*) DESC
              LIMIT 10") -> s
dbFetch(s)
dbClearResult(s)}


microbenchmark(mysql_count_groupby_host(), mysql_count_groupby_http(),
               mysql_group_by_avg(), mysql_min_max(),
               mysql_range(), times = 10) -> mysql_results

write_csv(mysql_results, "mysql_results.csv")


# add indexes and then re-run the benchmark
dbSendQuery(con,
            "CREATE INDEX time_ind
              ON weblog (timestamp)")

dbSendQuery(con, 
            "CREATE INDEX multi_ind
              ON weblog (host,reply_size)")


microbenchmark(mysql_count_groupby_host(), mysql_count_groupby_http(),
               mysql_group_by_avg(), mysql_min_max(),
               mysql_range(), times = 10) -> mysql_results_index

write_csv(mysql_results_index, "mysql_results_after_index.csv")
