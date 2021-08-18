# The script ApplyingRFE.R prints a correlation matrix of the features and applies the RFE method to 
# determine the optimal set of features.
# Copyright (c) 2020-2021, Angeliki Katsenou
# email: angeliki.katsenou@bristol.ac.uk
# email: akatsenou@gmail.com


# ensure the results are repeatable
set.seed(7)
# load the libraries
library(randomForest)
library(mlbench)
library(caret)
library(ggplot2)
library(corrplot)

# load the data
allfeatures <- read_excel("Data_Features.xls")

# calculate correlation matrix
correlationMatrix <- cor(allfeatures[,1:31])
# summarize the correlation matrix
print(correlationMatrix)
# find attributes that are highly corrected (ideally >0.75)
highlyCorrelated <- findCorrelation(correlationMatrix, cutoff=0.8)
# print indexes of highly correlated attributes
print(highlyCorrelated)
corrplot(correlationMatrix, method="circle")
#corrplot(correlationMatrix, type="upper", order="hclust", tl.col="black", tl.srt=45)
#corrplot(correlationMatrix, method="number")

# prepare training scheme
control <- trainControl(method="repeatedcv", number=5, repeats=10)
# train the model
model <- train(Annotation~., data=allfeatures[,1:31], method="lvq", preProcess="scale", trControl=control)

# estimate variable importance
importance <- varImp(model, scale=FALSE)
# summarize importance
print(importance)
# plot importance
plot(importance)

# define the control using a random forest selection function
control <- rfeControl(functions=rfFuncs, method="cv", number=5)
# run the RFE algorithm
results <- rfe(allfeatures[, 1:31], allfeatures[, 32], sizes=c(1:31), rfeControl=control)

# summarize the results
print(results)
# list the chosen features
predictors(results)
# plot the results

plot(results, xlab="Cardinality of Subset of Features", type=c("g", "o"), family = "serif") 
