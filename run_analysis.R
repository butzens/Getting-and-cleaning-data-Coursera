###
###Project work "getting and cleaning data" from coursera
###

# 1. Basic set up of workspace, working directory and data acquisition
#clear workspace
rm(list=ls(all=TRUE)) 

#load reshape2 package
library(reshape2)  
#if it not yet installed remove the following #
#install.packages('reshape2')

# create main and sub directory as values
mainDir <- 'Download_coursera'
subDir <- 'UCI HAR Dataset'
data <- 'getdata_dataset.zip'

# create main and sub directory in the workpath
dir.create('Download_coursera', recursive = TRUE)

#set working directory to the created folders
setwd(file.path('Download_coursera'))
 
# check if working directory path has been set right
getwd()    

# download data from url
download.file('https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip', #downoad data
      data)  

# unzip downloaded file
unzip(data)

# check downloaded & unzipped data 
  
list.files(".\\UCI HAR Dataset")
  
# 2. Read in the training and test datasets for further analysis.

# use read.table to load data into workspace
test.data <- read.table(file.path(subDir, 'test', 'X_test.txt'))
test.activities <- read.table(file.path(subDir, 'test', 'y_test.txt'))
test.subjects <- read.table(file.path(subDir, 'test', 'subject_test.txt'))
  
train.data <- read.table(file.path(subDir, 'train', 'X_train.txt'))
train.activities <- read.table(file.path(subDir, 'train', 'y_train.txt'))
train.subjects <- read.table(file.path(subDir, 'train', 'subject_train.txt'))
  
# 3. Merging data

# use row bind to put the data sets together 
test_train.data <- rbind(train.data, test.data)
test_train.activities <- rbind(train.activities, test.activities)
test_train.subjects <- rbind(train.subjects, test.subjects)

# combine all test_train data into one file, bound by columns (make sure to start with test_train.subjects)
all_data <- cbind(test_train.subjects, test_train.activities,test_train.data)

# 4. Load feature list & extract mean and standard deviation for each measurement. 

# load feature list from the download
all_features <- read.table(file.path(subDir, 'features.txt'))

# Filter to the features we want
subset_features <- all_features[grep('-(mean|std)\\(\\)', all_features[, 2 ]), 2]
all_data <- all_data[, c(1, 2, subset_features)]

# 5. Uses activity names to name the activities in the data set

# Read in the activity labels
activities <- read.table(file.path(subDir, 'activity_labels.txt'))

# Update the activity name
all_data[, 2] <- activities[all_data[,2], 2]

# Check structure of data

str(all_data)

# 6. labels the data set with the correct descriptive variable names. 

colnames(all_data) <- c('ID','activity',
                       gsub('\\-|\\(|\\)', '', 
                       as.character(subset_features)))



# Transforms activity column from factor to character for further analysis

all_data[, 2] <- as.character(all_data[, 2])

# 7. From the data before extract means and std to create another tidy dataset 

# Melt the data from wide to long (unique row for each observation)
melted <- melt(all_data, id = c('ID', 'activity'))

# Spread it again using dcast to get the mean value
final.mean <- dcast(melted, ID + activity ~ variable, mean)

# 8. Write tidy data as .txt file into directory
# Export the data out to a comma separated values (csv) file
write.table(final.mean, file=file.path("tidy_data.txt"), row.names = FALSE, quote = FALSE)
