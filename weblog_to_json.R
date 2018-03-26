source("load_packages.R")
options(encoding = "WINDOWS-1252")

# create a vector to hold column names
column_names <- c("host", "drop1", "drop2", "timestamp", "request", "HTTP_reply", 
                  "reply_size")

# explicitly map the data-type of columns
column <- cols(host = "c", drop1 = "-", drop2 = "-", timestamp = "?", request = "c", 
               HTTP_reply = "i", reply_size = "i")

# read the weblog from the text file
weblog <- read_log("UofS_access_log", 
                   col_types = column, col_names = column_names)

# convert the date into a more traditional date format
weblog %>%  pull(timestamp) %>% dmy_hms(.) -> weblog$timestamp


