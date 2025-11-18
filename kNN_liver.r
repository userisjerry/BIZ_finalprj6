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

# 1. 숫자형 변수만 추출
num_cols <- c("Age", "Total_Bilirubin", "Direct_Bilirubin",
              "Alkaline_Phosphotase", "Alamine_Aminotransferase",
              "Aspartate_Aminotransferase", "Total_Protiens",
              "Albumin", "Albumin_and_Globulin_Ratio")

train_x <- train[, num_cols]
valid_x <- valid[, num_cols]

train_y <- train$Dataset
valid_y <- valid$Dataset

# 2. center / scale (표준화)
preproc <- preProcess(train_x, method = c("center", "scale"))
train_x_scaled <- predict(preproc, train_x)
valid_x_scaled <- predict(preproc, valid_x)

# 3. kNN 학습 & 예측 (여기서는 k = 5 예시)
set.seed(2025)
knn_pred <- knn(train = train_x_scaled,
                test  = valid_x_scaled,
                cl    = train_y,
                k     = 5)

# 4. 성능 평가
confusionMatrix(knn_pred, valid_y,
                positive = "LiverDisease")

