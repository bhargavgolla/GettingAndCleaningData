## Create one R script called run_analysis.R that does the following:
## 1. Merges the training and the test sets to create one data set.
## 2. Extracts only the measurements on the mean and standard deviation for each measurement.
## 3. Uses descriptive activity names to name the activities in the data set
## 4. Appropriately labels the data set with descriptive variable names.
## 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.


# Install dependencies if needed
if (!require(data.table)) {
  install.packages('data.table')
}
require(data.table)

# Activity labels loaded. They are just in the second column
activity_labels <- fread('./UCI HAR Dataset/activity_labels.txt')[,as.factor(V2)]

# Activity labels loaded. They are just in the second column
features <- fread('./UCI HAR Dataset/features.txt')[,as.factor(V2)]

# We are required to just extract mean and std parts
extract_features <- grepl('mean|std', features)

## Processing Test data ##

# X_test, y_test, subject_test data
X_test <- fread('./UCI HAR Dataset/test/X_test.txt')
y_test <- fread('./UCI HAR Dataset/test/y_test.txt')
subject_test <- fread('./UCI HAR Dataset/test/subject_test.txt')

# Add names to X_test
names(X_test) <- as.character(features)

# Subset only the std and mean columns
X_test <- X_test[,extract_features, with = FALSE]

# Add Activity labels to y_test
y_test <- cbind(y_test, activity_labels[y_test$V1])
# Add names to y_test
names(y_test) <- c('Activity_ID', 'Activity_Label')
names(subject_test) <- 'Subject_ID'

# Get Test Data together: Subject_ID, Activity_ID, Activity_Label, and X
test_data <- cbind(subject_test, y_test, X_test)

## Processing Training data ##

# X_train, y_train, subject_train data
X_train <- fread('./UCI HAR Dataset/train/X_train.txt')
y_train <- fread('./UCI HAR Dataset/train/y_train.txt')

subject_train <- fread('./UCI HAR Dataset/train/subject_train.txt')

# Add names to X_train
names(X_train) <- as.character(features)

# Subset only the std and mean columns
X_train <- X_train[,extract_features, with = FALSE]

# Add Activity labels to y_train
y_train <- cbind(y_train, activity_labels[y_train$V1])
# Add names to y_train
names(y_train) = c('Activity_ID', 'Activity_Label')
names(subject_train) = 'Subject_ID'

# Get Train Data together: Subject_ID, Activity_ID, Activity_Label, and X
train_data <- cbind(subject_train, y_train, X_train)

# Merge test and train data
data = rbind(test_data, train_data)

id_labels   = c('Subject_ID', 'Activity_ID', 'Activity_Label')
data_labels = as.vector(features[extract_features])
melt_data      = melt(data, id = id_labels, measure.vars = data_labels)

# Apply mean function to dataset using dcast function
tidy_data   = dcast(melt_data, Subject_ID + Activity_Label ~ variable, mean)

write.table(tidy_data, file = './tidy_data.txt')
