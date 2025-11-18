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
set.seed(2025)
rf_fit <- randomForest(form,
                       data      = train,
                       ntree     = 500,  # 트리 개수
                       mtry      = 3,    # 각 분할에서 고려할 변수 수
                       importance = TRUE)

print(rf_fit)  # OOB 에러 등 확인

# 2. 변수 중요도 플롯
varImpPlot(rf_fit, main = "Random Forest Variable Importance")

# 3. 예측
rf_pred_class <- predict(rf_fit,
                         newdata = valid,
                         type    = "class")

rf_pred_prob <- predict(rf_fit,
                        newdata = valid,
                        type    = "prob")[, "LiverDisease"]

# 4. Confusion Matrix
confusionMatrix(rf_pred_class, valid$Dataset,
                positive = "LiverDisease")

# 5. ROC & AUC
roc_rf <- roc(response  = valid$Dataset,
              predictor = rf_pred_prob,
              levels    = rev(levels(valid$Dataset)))
plot(roc_rf, main = "Random Forest ROC")
auc(roc_rf)
