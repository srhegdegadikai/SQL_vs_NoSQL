mysql <- read_csv("mysql_results.csv")
mongoDB <- read_csv("mongoDB_results.csv")
elasticsearch <- read_csv("elastic_results.csv")
results <- bind_rows(mongoDB, mysql, elasticsearch)


# create a new column to hold the database type(grouping object) and the query type
results %>%
  mutate(database = case_when(
    str_detect(results$expr,"mongoDB") ~ "MongoDB",
    str_detect(results$expr,"mysql") ~ "MySQL",
    str_detect(results$expr,"elastic") ~ "Elasticsearch"
  ),
  query_type = str_extract(results$expr, "_.{1,}") %>% str_remove("_") %>% str_remove("\\(\\)")) -> results

results %>%
  arrange(database, query_type, desc(time)) %>%
  mutate(id = rep(1:10, 15), time = nanoseconds(time)) -> results

# plot the distributuion of run time based db
results %>% filter(database == "MySQL") %>%
  ggplot(., aes(id,time, group= query_type)) +
  geom_line(aes(color= query_type)) +
  geom_point(aes(color= query_type)) +
  facet_wrap(~query_type, ncol = 3, scales = "free") +
  theme(legend.position = "none",
        axis.text.x = element_blank()) +
  ggtitle("Database - MySQL") +
  ylab("Time in Seconds") -> gg_mysql



results %>% filter(database == "MongoDB") %>%
  ggplot(., aes(id,time, group= query_type)) +
  geom_line(aes(color= query_type)) +
  geom_point(aes(color= query_type)) +
  facet_wrap(~query_type, ncol = 3, scales = "free") +
  theme(legend.position = "none",
        axis.text.x = element_blank()) +
  ggtitle("Database - MongoDB") +
  ylab("Time in Seconds")  -> gg_mongo

results %>% filter(database == "Elasticsearch") %>%
  ggplot(., aes(id,time, group= query_type)) +
  geom_line(aes(color= query_type)) +
  geom_point(aes(color= query_type)) +
  facet_wrap(~query_type, ncol = 3, scales = "free") +
  theme(legend.position = "none",
        axis.text.x = element_blank()) +
  ggtitle("Database - Elasticsearch") +
  ylab("Time in Seconds")  -> gg_elastic

# print the plots 
gg_mysql

gg_mongo

gg_elastic

# boxplot of run-times for all the db's
results %>%
  ggplot(., aes(database, time))+
  geom_boxplot(aes(fill = database)) +
  geom_point() +
  scale_y_log10() + 
  ylab("Time(seconds) in log10 scale") +
  theme(legend.position = "none",
        axis.title.x = element_blank())


results %>%
  group_by(database) %>%
  summarise(mean_run_time = mean(time))  

# loo at the queries taking max amount of time for mysql  
results %>% filter(database == "MySQL") %>%
  group_by(query_type) %>%
  summarise(maximum = max(time)) %>%
  arrange(desc(maximum))  

# filter out groupby query results from the data
results %>%
  group_by(database) %>%
  filter(database != "MySQL" | query_type != "count_groupby_host" & query_type != "group_by_avg" ) %>%
  summarise(mean_run_time = mean(time))

# t.test for elasticsearch and filtered mysql results  
results %>%
  group_by(database) %>%
  filter(database != "MySQL" | query_type != "count_groupby_host" & query_type != "group_by_avg" ) %>%
  filter(database == "Elasticsearch" | database == "MySQL") %>%
  t.test(time ~ database, data = . )  


# create new dataframes to hold the results after adding indexes
bind_rows(
  read_csv("mongoDB_results_after_index.csv"),
  read_csv("mysql_results_after_index.csv")
) %>%
  mutate(database = case_when(
    str_detect(.$expr,"mongoDB") ~ "MongoDB",
    str_detect(.$expr,"mysql") ~ "MySQL",
    str_detect(.$expr,"elastic") ~ "Elasticsearch"
  ),
  query_type = str_extract(.$expr, "_.{1,}") %>% str_remove("_") %>% str_remove("\\(\\)")) -> results_after_index

results_after_index %>%
  arrange(database, query_type, desc(time)) %>%
  mutate(id = rep(1:10, 10), time = nanoseconds(time)) -> results_after_index

results_after_index %>%
  group_by(database) %>%
  summarise(mean = mean(time))


results_after_index %>%
  ggplot(., aes(id, time)) +
  geom_line(aes(color = database))+
  geom_point(aes(color = database)) +
  facet_wrap(~ query_type, ncol = 2, scales = "free") +
  theme(axis.text.x = element_blank(),
        axis.title.x = element_blank()) +
  ylab("Run-Time in seconds")


# bind both set of results together into one big results table 
bind_rows(results, results_after_index, .id = "add_index") -> result_final

# add grouping variables to indicate the whether or not indexes have been added  
result_final %>%
  mutate(add_index = case_when(
    add_index == 1 ~ "Before adding index",
    add_index == 2 ~ "After adding index"
  )) -> result_final

# draw a boxplot to indicate the effect of indexes  
result_final %>%
  ggplot(., aes(database, time)) +
  geom_boxplot(aes(fill = database)) +
  geom_point(alpha = .5) +
  theme(axis.title.x = element_blank(),
        legend.position = "none") +
  facet_wrap(~ add_index, nrow = 2) +
  coord_flip() 