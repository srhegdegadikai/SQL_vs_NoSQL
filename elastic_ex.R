source("load_packages.R")

connect()


# this works! c style string formatting
user_in <- 404

mmatch <- '
{
  "query": {
    "bool": {
      "must": [
        { "match": {"HTTP_reply": "%i"}}
        
      ]
    }
  }
}
'
sprintf(mmatch, user_in) -> mmatch

Search(index = "weblog", body = mmatch)$hits$hits ->s 

# do the following
# range query between two given dates
# histograms and other aggregations
# top visitors
# count for HTTP_reply's
# min and max reply_size
# avg reply sizes for top 10 visitors

# date range query
elastic_range <- function(){
date1 <- "1995-06-01 06:00:59"
date2 <- "1995-11-15 11:59:59"

# works
mmatch <- '
{
  "query" : {
    "bool" : {
      "must" : {
        "range" : {
          "timestamp" : {
            "gte" : "%s",
            "lte" : "%s",
            "format" : "yyyy-MM-dd HH:mm:ss"
          }
        }
      }
    }
  }
}
'
sprintf(mmatch, date1, date2) -> mmatch
Search(index = "weblog", body = mmatch)$hits$total}

# top visitors
elastic_count_groupby_host <- function(){
mmatch <- '
{
  "size" : 0,  
  "aggs" : {
    "top_visitors" : {
      "terms" : { "field" : "host"}
    }
  }
}
'

Search(index = "weblog", body = mmatch, raw = TRUE)}

# reply type counts
elastic_count_groupby_http <- function(){
mmatch <- '
{
  "size" : 0,  
  "aggs" : {
    "top_reply_types" : {
      "terms" : { "field" : "HTTP_reply"}
    }
  }
}
'
Search(index = "weblog", body = mmatch, raw = TRUE)}

# max and min reply size
elastic_min_max <- function(){
mmatch <- '
{
  "size" : 0,
  "aggs" : {
    "max_reply_size" : { "max" : {"field" : "reply_size"} },
    "min_reply_size" : { "min" : {"field" : "reply_size"} }
  }
}
'
Search(index = "weblog", body = mmatch, raw = TRUE)}

# for each top 10 visitor avg_reply size
elastic_group_by_avg <- function(){
mmatch <- '
{
  "size" : 0,  
  "aggs" : {
    "group_by_host" : {
      "terms" : { "field" : "host"},
        "aggs" : {
          "avg_reply_size" : {
            "avg" : {"field" : "reply_size"}
          }
        }
    }
  }
}
'
Search(index = "weblog", body = mmatch, raw = TRUE)}


microbenchmark(elastic_count_groupby_host(), elastic_count_groupby_http(),
               elastic_group_by_avg(), elastic_min_max(),
               elastic_range(), times = 10) -> elastic_results

write_csv(elastic_results, "elastic_results.csv")
