## Creation of contributors to project text file.
# This is an example script to create a text file for contributors and their names.
# Set working directory (for example as below)
setwd("/Users/danielpett/3D/GitHub/micropasts-bai-contributors") #MacOSX
library(jsonlite)
library(plyr)

if (!file.exists('csv')){
  dir.create('csv')
}

# Create archives directory if it does not exist
if (!file.exists('archives')){
  dir.create('archives')
}

# Create JSON folder if it does not exist
if (!file.exists('json')){
  dir.create('json')
}

# Load library
library(RJSONIO)

# Set the project name eg for the SlideFastenerA16 project
project <- 'SlideFastenerA16'


# Set the task runs api path
url <- paste0('https://crowdsourced.micropasts.org/project/',project,'/tasks/export?type=task_run&format=json')


# Create the archive path
archive <- paste('archives/', project, 'TasksRun.zip', sep='')


# Import tasks from json, this method has changed due to coding changes by SciFabric to their code
download.file(url, archive)
outdir <- paste('/Users/danielpett/3D/GitHub/micropasts-bai-contributors/json/')
# Unzip the archive
unzip(archive,exdir=outdir)
jsonPath <-paste0('/Users/danielpett/3D/GitHub/micropasts-bai-contributors/json/',project,'_task_run.json')
# Get the user id from the task run data
data <- fromJSON(jsonPath)
length(data)
new <- setNames(do.call(cbind.data.frame, lapply(lapply(data, unlist),
                                                 `length<-`, max(lengths(data)))), paste0("V", 1:3))

library(data.table)
rotated <- transpose(new)

colnames(rotated) <- rownames(new)
#rownames(rotated) <- colnames(new)
userid <- as.data.frame(rotated$user_id)

## You  can only obtain these data if you are an admin for the project.

users <- read.csv('csv/all_users.csv', sep=",", header=TRUE)
userList <- users[,c("id","fullname")]

# Rename column id to user_id for merging
names(userList) <- c("user_id", "fullname")
names(userid)<-c("user_id")

# Merge the data
contributors <- merge(userid, userList, by="user_id")
as.vector(contributors$fullname) -> names

#Extract and print unique names
unique(names) -> names
thanks <- paste(as.character(names), collapse=", ")

# Write the thank you list to a text file.
fileConn<-file(paste(project, '.txt', sep=''))
writeLines(c(thanks), fileConn)
close(fileConn)
