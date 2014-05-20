## Getting and Cleaning Data: Peer Assessment, Tidy Data
## Kristen Borchert
## May 25, 2014
## run_analysis.R

# Step 1: Unzip the files found in the url listed into a subfolder in your 
# working directory called "data"
# url1 <- https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

# Step 2: Set your working directory so that run_analysis.R is at the same level as the folder
# called "data" 
# setwd("~/Documents/Getting and Cleaning Data/Course Project")

# Step 3: Read the seven files needed for the analysis in:
TrainData <- read.table("./data/train/X_train.txt")
SubjectTrain <- read.table("./data/train/subject_train.txt")
ActivityTrain <- read.table("./data/train/y_train.txt")
TestData <- read.table("./data/test/X_test.txt")
SubjectTest <- read.table("./data/test/subject_test.txt")
ActivityTest <- read.table("./data/test/y_test.txt")
ActivityLabels <- read.table("./data/activity_labels.txt")
Features <- read.table("./data/features.txt")

# Check the dimensions of the two big files TrainData and TestData
# dim(TrainData); dim(TestData)
# [1] 7352  561  TrainData
# [1] 2947  561  TestData

# Add some details to TrainData (column names, as defined by 2nd column of Features 
# and a new column called DataType to indicate whether it was from the training 
# or test set
names <- Features[,2]
colnames(TrainData) <- names
TrainData$DataType <- "Train"

# Repeat process on TestData
colnames(TestData) <- names
TestData$DataType <- "Test"

#cbind SubjectTrain and ActivityTrain, add column titles then put JoinTrain and TrainData
# together to form one big TrainDataSet, called TrainAll
JoinTrain <- cbind (SubjectTrain, ActivityTrain)
colnames(JoinTrain) <- c("Subject", "ActivityId")
TrainAll <- cbind(TrainData, JoinTrain)

# Repeat cbind process on Test Data
JoinTest <- cbind (SubjectTest, ActivityTest)
colnames(JoinTest) <- c("Subject", "ActivityId")
TestAll <- cbind(TestData, JoinTest)

# Check the dimensions of the new big datasets before final merge...
# TrainAll should have 7352 obs of 564 variables
# TestAll should have 2947 obs of 564 variables
dim(TrainAll); dim(TestAll)
# [1] 7352  564  Both check out... go ahead with final merge
# [1] 2947  564

# Merge TrainAll and TestAll using rbind, call MergeData
MergeData <- rbind(TrainAll,TestAll)

# Add ActivityLabels to AllData to convert the ids to words
colnames(ActivityLabels) <- c("ActivityId", "Activity")
AllData <- merge(MergeData, ActivityLabels, by="ActivityId")

# At this point you could save this complete file...
# write.table(AllData, "./data/AllDataUncleaned.txt")

# Subset Mean and SD
# Select only column headers containing mean and std, use Features
# First, come up with a vector containing the names of all the columns we want to keep
# containing mean and std.  Then make a character vector containing the names of 
# all the columns we want to keep (mean, std plus Subject, DataType and Activity).
# Note I have dropped ActivityId, as we don't need it anymore.
MeanStdIndices <- grep("mean\\(\\)|std\\(\\)", Features[, 2], value=TRUE)
Sub<- c(MeanStdIndices, "Subject", "DataType", "Activity")
SubsetAllData <- AllData[,Sub]

# Now make the column titles pretty
# Things to remove: "-" and "()"
# Then capitalize "Mean" and "Std"
names(SubsetAllData) <- gsub("\\(\\)", "", names(SubsetAllData)) #Get rid of ()
names(SubsetAllData) <- gsub("\\-", "", names(SubsetAllData)) #Get rid of all -
names(SubsetAllData) <- gsub("mean", "Mean", names(SubsetAllData)) # Capitalize Mean
names(SubsetAllData) <- gsub("std", "Std", names(SubsetAllData)) #Capitalize Std

# Export the Subsetted and Cleaned Data
# write.table(SubsetAllData, "./data/MeanStdTidyData.txt")

# Now: to reduce the data down...
# 
# # This makes a tall and skinny dataset, melting everything except Subject and 
# Activity down - note: this leaves off DataType.  The measurements reside in all
# but the last three columns.  First you need to load reshape2.
require(reshape2)
Melted <- melt(SubsetAllData, id=c('Subject', 'Activity'),
                  measure.vars=names(SubsetAllData[1:(ncol(SubsetAllData)-3)]))
Melted$Subject <- as.factor(Melted$Subject)
Final <- dcast(Melted, Subject + Activity ~ variable, mean)
write.table(Final, file="./data/SummarizedActivityDatabySubject.txt", sep='\t', 
quote=FALSE, row.names=FALSE)

# 4) SAVE IT TO A TXT FILE

write.table(Final, file="./data/SummarizedActivityDatabySubject.txt", sep='\t', 
            quote=FALSE, row.names=FALSE)

  
  
