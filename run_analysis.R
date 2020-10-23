
## Loading necessary packages
if("dplyr" %in% rownames(installed.packages()) == FALSE) {install.packages("dplyr")}
library(dplyr)

## Importing row data
x_test <- readLines(file.path("UCI HAR Dataset","test","X_test.txt"))
x_train <- readLines(file.path("UCI HAR Dataset","train","X_train.txt"))

## Splitting row data from blocks of text into individual values
x_test <- strsplit(x_test, " +")
x_train <- strsplit(x_train, " +")

## Removing empty first value from each row
x_test <- lapply(x_test, tail,561)
x_train <- lapply(x_train, tail,561)

## Transforming lists into data frames
x_test <- data.frame(matrix(unlist(x_test), nrow=length(x_test), byrow=TRUE))
x_train <- data.frame(matrix(unlist(x_train), nrow=length(x_train), byrow=TRUE))

## Importing column headers
features <- readLines(file.path("UCI HAR Dataset","features.txt"))

## Removing numbers from column headers
features[1:9] <- gsub("^. ", "", features[1:9])
features[10:99] <- gsub("^.. ", "", features[10:99])
features[100:length(features)] <- gsub("^... ", "", features[100:length(features)])

## Adding column headers to data frame
names(x_test) <- features
names(x_train) <- features

## Importing activity column and activity labels
y_test <- readLines(file.path("UCI HAR Dataset","test","y_test.txt"))
y_train <- readLines(file.path("UCI HAR Dataset","train","y_train.txt"))
activity_labels <- readLines(file.path("UCI HAR Dataset","activity_labels.txt"))

## Transforming activity labels into data frame for matching
activity_labels <- strsplit(activity_labels, " ")
activity_labels <- data.frame(matrix(unlist(activity_labels), nrow=length(activity_labels), byrow=T))

## Replacing activity numbers by labels
for(i in 1:6) {y_test <- sapply(y_test, gsub, pattern = activity_labels[i,1], replacement = activity_labels[i,2])}
for(i in 1:6) {y_train <- sapply(y_train, gsub, pattern = activity_labels[i,1], replacement = activity_labels[i,2])}

## Adding activity column to data frame
x_test <- cbind(activity = y_test, x_test)
x_train <- cbind(activity = y_train, x_train)

## Importing subject column
subject_test <- readLines(file.path("UCI HAR Dataset","test","subject_test.txt"))
subject_train <- readLines(file.path("UCI HAR Dataset","train","subject_train.txt"))

## Adding subject column to data frame
x_test <- cbind(subject = subject_test, x_test)
x_train <- cbind(subject = subject_train, x_train)

## Merging training and test data frames
df <- rbind(x_test, x_train)

## Removing unwanted columns
wantedcolumns <- c(1,2, grep("mean\\(\\)|std\\(\\)", names(df)))
df <- df[,wantedcolumns]

## Turning character values into numbers
df[,1] <- as.integer(df[,1])
df[,3:length(df)] <- apply(df[,3:length(df)], 2, as.numeric)

## Sorting data frame by subject and activity
df <- arrange(df, subject, activity)

## Create summary data frame
df <- tibble::as_tibble(df)
df <- group_by(df, subject, activity)
df_summary <- summarise_if(df, is.numeric, mean)

## Deleting temporary objects
rm(activity_labels, features, i, subject_test, subject_train, wantedcolumns, x_test, x_train, y_test, y_train)

## Saving tidy data frames
write.csv(df, file = "UCI HAR tidy dataset.csv")
write.csv(df_summary, file = "UCI HAR summary dataset.csv")
