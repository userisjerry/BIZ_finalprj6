# BIZ_finalprj6

# Risk Factor Analysis and Diagnostic Decision Support for Early Detection of Liver Disease in India
## > Early Liver Disease Detection Strategy for Indian Hospitals Using Blood Test Data
raw data on kaggle


### 연구 질문

1. **간질환 환자와 정상 환자의 차이를 만드는 핵심 요인은 무엇인가?**
2. **어떤 특성(연령, 성별, 검사지표 등)이 간질환 위험도를 높이는가?**
3. **병원에서 어떤 환자를 우선 검사해야 비용 대비 효율적인가?**
4. **고위험 군 환자를 그룹화하면 어떤 특징이 드러나는가?**

## 1 > Logistic Regression

![image.png](attachment:8a3f3466-eb23-4f14-8c1f-4cda91d0bf36:image.png)

- 예측 성능 자체는 매우 떨어지는 편. → 상당수를 정상으로 예측하는 경향을 보임
- 계수와, p-value 값을 통해 → Age, ALT, Protein, Albumine, A/G 비율 같은 변수들이 간질환에 통계적으로 유의한 영향응ㄹ 준다는 점을 보여 줌
- 간질환의 위험요인을 보여줌

⇒ 예측 정확도는 낮지만, 어떤 검사 지표가 간질환 위험을 높이는지 방향성을 파악할 수 있음

## 2 > kNN

![image.png](attachment:b4e69a3b-f4d8-4a76-9042-033dc8b74401:image.png)

- 너무 예민한 모델 → 조금이라도 경향이 보이면 간질환 환자로 간주 ⇒ 오판 위험성이 큼

⇒ 추후, 정밀 검사용으로는 좋음

## 3 > Decision Tree

![image.png](attachment:3c12c279-c303-4ee1-ae60-44474e99f85d:image.png)

- Bilirubin, AST/ALT, Alkaline_Pho처럼 전형적인 간 기능 관련 지표들이 상위 분기점에 올라옴
- 특정 값 이상일 때 간질환으로 분류하는 경로가 만들어짐
- 정확도 면에서는 중간 수준이지만, bilirubin이 어느 수준 이상이면서 효소 수치가 높으면 간질환 위험이 크다 ⇒ 꽤나 실용적인 결과를 도출

⇒ 가장 직관적으로 이해하고 활용하기 좋은 모델

## 4 > Naive Baise

![image.png](attachment:c22b4e4f-83b4-4ddf-bce4-85ac6e593e6a:image.png)

![image.png](attachment:684fc9bb-0253-48b6-8efa-3f83cbb14347:image.png)

- 정상 환자는 매우 잘 잡아내지만, 간질환 환자를 잡아내지 못함 → 정상 판정에 적합

⇒ 추가 검사 비용을 줄이기 위해, 정말로 위험도가 낮은 사람을 골라낼 수 있음

## 5 > Random Forest

![image.png](attachment:aaf405fe-0afa-4ec6-96e0-1485bd702266:image.png)

- 지표들이 가장 안정적, 균형.
- 간질환 환자 잘 캐치 및 정확도 가장 높음, AUC 높음.
- 간 기능과 직접적으로 관련된 지표들이 상위에 올라와 있어 → 의학 지식과도 일치

⇒ ** 간질환 조기 예측의 목적에 가장 좋은 알고리즘. 성능, 해석력이 모두 좋은 가장 현실적인 결과를 도출해내는 모델

## 6 > NN

![image.png](attachment:b6439040-7f13-451d-9173-fd5e4591f22c:image.png)

![image.png](attachment:c28c8d5c-d78a-49a5-ade1-2fc92e776b2e:image.png)

![image.png](attachment:e7433411-bd05-43ff-bb07-b5f7761a25bb:image.png)

- 간질환 환자를 잘 잡아내지만, 정상 환자 구분을 잘 하지 못함.
- 랜덤 포레스트의 하위 모델. → 데이터가 더 많다면 확장 가능성 있음
