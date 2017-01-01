# Question 1 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#Download File and save in Data Science Class folder
if(!file.exists("~/Desktop/Data Science Class")){dir.create("~/Desktop/Data Science Class")}
Url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(Url,destfile="~/Desktop/Data Science Class/Dataset.zip",method="curl")

#unzip folder
unzip(zipfile="~/Desktop/Data Science Class/Dataset.zip",exdir="./data")

#List all the files in the subfolder
path <- file.path("~/Desktop/Data Science Class/data" , "UCI HAR Dataset")
files<-list.files(path, recursive=TRUE)
files

#Read in Activity Data
ActivityTest  <- read.table(file.path(path, "test" , "Y_test.txt" ),header = FALSE)
ActivityTrain <- read.table(file.path(path, "train", "Y_train.txt"),header = FALSE)

#Read in Subject Files
SubjectTrain <- read.table(file.path(path, "train", "subject_train.txt"),header = FALSE)
SubjectTest  <- read.table(file.path(path, "test" , "subject_test.txt"),header = FALSE)

#Read in Features File
FeaturesTest  <- read.table(file.path(path, "test" , "X_test.txt" ),header = FALSE)
FeaturesTrain <- read.table(file.path(path, "train", "X_train.txt"),header = FALSE)

#Rbind to combine test and training data 
dataSubject <- rbind(SubjectTrain, SubjectTest)
dataActivity<- rbind(ActivityTrain, ActivityTest)
dataFeatures<- rbind(FeaturesTrain, FeaturesTest)

#Add variable names
names(dataSubject)<-c("subject")
names(dataActivity)<- c("activity")
dataFeaturesNames <- read.table(file.path(path, "features.txt"),head=FALSE)
names(dataFeatures)<- dataFeaturesNames$V2

#Cbind to combine data sets
Data <- cbind(dataSubject, dataActivity, dataFeatures)

# Question 2 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#Identify names with mean and std 
subdataFeaturesNames<-dataFeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", dataFeaturesNames$V2)]

#subset data by selected features names
selectedNames<-c(as.character(subdataFeaturesNames), "subject", "activity" )
Data_subset<-subset(Data,select=selectedNames)

#check structure of new data
str(Data_subset)

# Question 3 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#add in activity labels
activityLabels <- read.table(file.path(path, "activity_labels.txt"),header = FALSE)
names(activityLabels)<-c("activity", "activity_name")
Data_subset2 <- cbind(dataSubject, dataActivity, Data_subset)

library(plyr)
Data_subset_withactivity <- join(Data_subset2, activityLabels, by = "activity")

# Question 4 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#Updating names
names(Data_subset_withactivity)<-gsub("^t", "time", names(Data_subset_withactivity))
names(Data_subset_withactivity)<-gsub("^f", "frequency", names(Data_subset_withactivity))
names(Data_subset_withactivity)<-gsub("Acc", "Accelerometer", names(Data_subset_withactivity))
names(Data_subset_withactivity)<-gsub("Gyro", "Gyroscope", names(Data_subset_withactivity))
names(Data_subset_withactivity)<-gsub("Mag", "Magnitude", names(Data_subset_withactivity))
names(Data_subset_withactivity)<-gsub("BodyBody", "Body", names(Data_subset_withactivity))

names(Data_subset_withactivity)

# Question 5 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#creating independent tidy data set with the average of each variable for each activity and each subject
library(plyr)
TidyData<-aggregate(. ~subject + activity_name, Data_subset_withactivity, mean)
TidyData<-TidyData[order(TidyData$subject,TidyData$activity),]
write.table(TidyData, file = "tidydata.txt",row.name=FALSE)

install.packages("knitr")
library(knitr)

