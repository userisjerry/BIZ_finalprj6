# 패키지 로드
library(tidyverse)    # dplyr, ggplot2 등
library(caret)        # 데이터 분할, confusionMatrix, 전처리
library(e1071)        # naiveBayes
library(class)        # knn
library(rpart)        # 의사결정나무
library(rpart.plot)   # 나무 시각화
library(randomForest) # 랜덤포레스트
library(pROC)         # ROC, AUC
library(nnet)         # 신경망 (caret이 내부에서 사용)

# 1. 데이터 불러오기
liver <- read.csv("/Users/shinyuri/Desktop/cleaned_liver_patients.csv")

# 2. 범주형/타깃 변수 변환
liver$Gender  <- as.factor(liver$Gender)
liver$Dataset <- factor(liver$Dataset,
                        levels = c(1, 2),
                        labels = c("LiverDisease", "Normal"))
# positive class = LiverDisease 로 가정

# 3. train / valid 분할 (예: 70% / 30%)
set.seed(2025)
idx   <- createDataPartition(liver$Dataset, p = 0.7, list = FALSE)
train <- liver[idx, ]
valid <- liver[-idx, ]

# (공통) 모델에서 쓸 formula
form <- Dataset ~ Age + Gender + Total_Bilirubin + Direct_Bilirubin +
  Alkaline_Phosphotase + Alamine_Aminotransferase +
  Aspartate_Aminotransferase + Total_Protiens +
  Albumin + Albumin_and_Globulin_Ratio

# 1. 모델 학습
tree_fit <- rpart(form,
                  data   = train,
                  method = "class",
                  cp     = 0.01)  # cp는 가지치기 정도, 필요 시 조정

# 2. 나무 구조 시각화
rpart.plot(tree_fit, main = "Decision Tree for Liver Disease")

# 3. 예측
tree_pred_class <- predict(tree_fit,
                           newdata = valid,
                           type    = "class")

tree_pred_prob <- predict(tree_fit,
                          newdata = valid,
                          type    = "prob")[, "LiverDisease"]

# 4. Confusion Matrix
confusionMatrix(tree_pred_class, valid$Dataset,
                positive = "LiverDisease")

# 5. ROC & AUC
roc_tree <- roc(response  = valid$Dataset,
                predictor = tree_pred_prob,
                levels    = rev(levels(valid$Dataset)))
plot(roc_tree, main = "Decision Tree ROC")
auc(roc_tree)

# 6. 변수 중요도
tree_fit$variable.importance

