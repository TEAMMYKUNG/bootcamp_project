library(titanic)
library(caret)
glimpse(titanic_train)

#data clean -> Drop NA (Missing Value)
titanic_train <- na.omit(titanic_train)
nrow(titanic_train)

## SPLIT DATA
set.seed(42)
n <- nrow(titanic_train)
id <- sample(1:n, size=n*0.7) # 70% train 30% test
train_data <- titanic_train[id, ]
test_data <- titanic_train[-id, ]

## Train Model
model <- glm(Survived ~ Pclass + Age + Sex, train_data, family="binomial")
train_data$prob_train <- predict(model,type="response")
train_data$pred_train <- ifelse(train_data$prob_train>=0.5,1,0)
df<-data.frame(train_data)
df$Survived <- as.factor(df$Survived)
df$pred_train <- as.factor(df$pred_train)
train_result <- confusionMatrix(df$pred_train,df$Survived)
## Test Model 
test_data$prob_test <- predict(model, test_data, type="response")
test_data$pred_test <- ifelse(test_data$prob_test>=0.5,1,0)
df_test<-data.frame(test_data)
df_test$Survived <- as.factor(df_test$Survived)
df_test$pred_test <- as.factor(df_test$pred_test)
test_rerult <- confusionMatrix(df_test$pred_test,df_test$Survived)
## Accuracy
test_result
train_result
