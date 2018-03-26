source("load_packages.R")

# create a connection to the mongoDB server instance
con <- mongo(collection = "weblog", url = "mongodb://localhost/27017")


# range query between two given dates
mongoDB_range <- function(){
con$find(
'{ "timestamp" : {
      "$gte" : {"$date" : "1995-06-01T06:00:59Z"},
      "$lte" : {"$date" : "1995-11-15T11:59:59Z"}
}}'
)}


# top visitors
mongoDB_count_groupby_host <- function(){
con$aggregate(
  '[
      {"$group":{"_id":"$host", "count":{"$sum":1}}},
      {"$sort": {"count": -1}},
      {"$limit": 10}
  ]'
)}

# count for HTTP_reply's
mongoDB_count_groupby_http <- function(){
con$aggregate(
  '[
  {"$group":{"_id":"$HTTP_reply", "count":{"$sum":1}}},
  {"$sort": {"count": -1}},
  {"$limit": 10}
  ]'
)}

# min and max reply_size
mongoDB_min_max <- function(){
con$aggregate(
'[
{ "$group" : {"_id": "null",
              "max" : {"$max" : "$reply_size"},
              "min" : {"$min" : "$reply_size"}}}    
]'
)}

# avg reply sizes for top 10 visitors
mongoDB_group_by_avg <- function(){
con$aggregate(
  '[
      {"$group":{"_id":"$host", "count":{"$sum":1}, 
                                "avg_reply_size":{"$avg":"$reply_size"}}},
      {"$sort": {"count": -1}},
      {"$limit": 10}
  ]'
)}

microbenchmark(mongoDB_count_groupby_host(), mongoDB_count_groupby_http(),
               mongoDB_group_by_avg(), mongoDB_min_max(),
               mongoDB_range(), times = 10) -> mongoDB_results

write_csv(mongoDB_results, "mongoDB_results_after_index.csv")


# add indexes to all the fields and benchmark the quries again
con$index(add = '{"host": 1, "timestamp": 1,"request": 1,"HTTP_reply": 1,"reply_size": 1}')


microbenchmark(mongoDB_count_groupby_host(), mongoDB_count_groupby_http(),
               mongoDB_group_by_avg(), mongoDB_min_max(),
               mongoDB_range(), times = 10) -> mongoDB_results_index

write_csv(mongoDB_results_index, "mongoDB_results_after_index.csv")
