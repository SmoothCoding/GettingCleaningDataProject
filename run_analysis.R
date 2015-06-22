#Load the name of the data and extract all mean and std names
featuresUrl <- "./data/features.txt"
features <- read.csv(featuresUrl, header = FALSE, sep= " ")
means <- lapply(features$V2, function(x) any(grepl("mean",x, ignore.case = TRUE)))
stds <- lapply(features$V2, function(x) any(grepl("std",x, ignore.case = TRUE)))
combined <- (means == TRUE | stds == TRUE)
# From this determine the columns which shall be kept
keepColums = features[,2][combined]

# Load training and test data as fixed width files
trainingXUrl <- "./data/train/X_train.txt"
testXUrl <- "./data/test/X_test.txt"
widths  <- rep(16,561)
trainingX <- read.fwf(trainingXUrl, header=FALSE, widths = widths, buffersize=500)
colnames(trainingX) = features$V2
# Delete those columns which are not representing 
# means or standard deviations from the training data
trainingXms <- trainingX[keepColums]
testX <- read.fwf(testXUrl, header=FALSE, widths = widths, buffersize=500)
colnames(testX) = features$V2
# Delete those columns which are not representing 
# means or standard deviations from the test data
testXms <- testX[keepColums]

# Read the subject data
subjectTrain <- read.csv("./data/train/subject_train.txt", header = FALSE)
subjectTest <- read.csv("./data/test/subject_test.txt", header = FALSE)

# Read activity data
trainingYUrl <- "./data/train/y_train.txt"
testYUrl <- "./data/test/y_test.txt"
trainingY <- read.csv(trainingYUrl, header=FALSE)
testY <- read.csv(testYUrl, header=FALSE)

# Give names to activities
trainingY[trainingY==1]<-"WALKING"
trainingY[trainingY==2]<-"WALKING_UPSTAIRS"
trainingY[trainingY==3]<-"WALKING_DOWNSTAIRS"
trainingY[trainingY==4]<-"SITTING"
trainingY[trainingY==5]<-"STANDING"
trainingY[trainingY==6]<-"LAYING"

testY[testY==1]<-"WALKING"
testY[testY==2]<-"WALKING_UPSTAIRS"
testY[testY==3]<-"WALKING_DOWNSTAIRS"
testY[testY==4]<-"SITTING"
testY[testY==5]<-"STANDING"
testY[testY==6]<-"LAYING"

# Join all the data
joinedXms <- merge(trainingXms, testXms, all = TRUE)
joinedSubject <- rbind(subjectTrain, subjectTest)
joinedY <- rbind(trainingY, testY)
joinedXms$activity <- joinedY$V1
joinedXms$subject <- joinedSubject$V1

# Write the final data to 'final.txt'
write.csv(file="./data/final.txt", x=joinedXms)

# Group the data according to step 4 of the task:
groupedData <- aggregate(joinedXms[, 1:86], list(joinedXms$activity, joinedXms$subject), mean)
colnames(groupedData)[1] <- "activity"
colnames(groupedData)[2] <- "subject"
write.csv(file="./data/final_grouped.txt", x=groupedData)
