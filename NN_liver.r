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

# 1. caret용 trainControl 설정 (ROC 기준으로 튜닝하게 설정)
ctrl <- trainControl(method        = "cv",        # 교차검증
                     number        = 5,
                     classProbs    = TRUE,
                     summaryFunction = twoClassSummary)

# 2. 신경망 학습
set.seed(2025)
nn_fit <- train(form,
                data      = train,
                method    = "nnet",
                trControl = ctrl,
                metric    = "ROC",               # ROC 기준으로 최적 튜닝
                preProcess = c("center", "scale"),
                trace     = FALSE)               # 학습 로그 숨김

nn_fit    # 최적 size, decay 등 확인

# 3. 예측
nn_pred_prob <- predict(nn_fit,
                        newdata = valid,
                        type    = "prob")[, "LiverDisease"]

nn_pred_class <- predict(nn_fit,
                         newdata = valid,
                         type    = "raw")

nn_pred_class <- factor(nn_pred_class,
                        levels = levels(train$Dataset))

# 4. Confusion Matrix
confusionMatrix(nn_pred_class, valid$Dataset,
                positive = "LiverDisease")

# 5. ROC & AUC
roc_nn <- roc(response  = valid$Dataset,
              predictor = nn_pred_prob,
              levels    = rev(levels(valid$Dataset)))
plot(roc_nn, main = "Neural Network ROC")
auc(roc_nn)

