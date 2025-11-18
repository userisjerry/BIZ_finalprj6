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
logit_fit <- glm(form,
                 data   = train,
                 family = binomial)

summary(logit_fit)   # 계수, p-value 등 확인 (위험요인 해석용)

# 2. 검증 데이터에 대한 예측 확률 & 클래스
logit_prob <- predict(logit_fit,
                      newdata = valid,
                      type    = "response")

logit_pred <- ifelse(logit_prob > 0.5, "LiverDisease", "Normal")
logit_pred <- factor(logit_pred, levels = levels(train$Dataset))

# 3. 성능 평가 (Confusion Matrix)
confusionMatrix(logit_pred, valid$Dataset,
                positive = "LiverDisease")

# 4. ROC & AUC
roc_logit <- roc(response = valid$Dataset,
                 predictor = logit_prob,
                 levels   = rev(levels(valid$Dataset))) # level 순서 주의
plot(roc_logit, main = "Logistic Regression ROC")
auc(roc_logit)

