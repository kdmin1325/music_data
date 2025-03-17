# [**피아노 데이터 평가 및 수집 프로그램**]

### 본 리포지토리는DGU DAlab의 피아노 데이터 평가 및 수집 프로그램 소스 코드 입니다.
---
---

## 기술 스택

- **Frontend**  
  ![Flutter](https://img.shields.io/badge/flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)  ![Figma](https://img.shields.io/badge/-Figma-F24E1E?logo=figma&logoColor=white)

- **Backend**  
  ![flask](https://img.shields.io/badge/-flask-092E20?logo=flask&logoColor=white)  ![Swagger](https://img.shields.io/badge/-Swagger-85EA2D?logo=swagger&logoColor=black)  ![Python](https://img.shields.io/badge/-Python-3776AB?logo=python&logoColor=white)

- **DevOps**  
  ![GitHub](https://img.shields.io/badge/-GitHub-181717?logo=github&logoColor=white)  ![AWS](https://img.shields.io/badge/-AWS-181717?logo=AWS&logoColor=white)  ![AWS](https://img.shields.io/badge/-EC2-181717?logo=EC2&logoColor=white)
---

## 서비스 소개

### [**기능 소개**]
- 본 서비스는 피아노 연주 데이터를 평가 받기 위해 업로드 및 관리
- 피아노 연주 데이터 재생 및 항목별 평가

---

## 주요 기능(상세)

- ### 회원가입 및 로그인
![이미지 에러](./docs/img/login.PNG)
- ### 음악 검색
![이미지 에러](./docs/img/search.PNG)
- ### 10초 단위의 데이터 평가
![이미지 에러](./docs/img/10s.PNG)
- ### 곡 악보 표시 및 재생
![이미지 에러](./docs/img/score.PNG)
- ### 15가지 항목을 기준으로 평가 지원
   - 톤, 레가토, 해석, 프레이징, 멜로디, 음악성(음악적표현력), 보이싱, 음정, 셈여림, 셈여림 변화, 템포, 템포의 변화, 음의 길이와 관련된 아티큘레이션, 리듬, 페달링
![이미지 에러](./docs/img/evaluation.PNG)
- 연주자 익명 평가 시스템
![이미지 에러](./docs/img/anonymous_evaluation.PNG)
- SQL을 통해 평가결과 내보내기

---

## 서비스 아키텍처

![서비스 아키텍처](./System_Architecture.png)

---


## 설치 및 실행 방법

1. 저장소 클론

```bash
git clone https://github.com/dalabdgw/Piano_Performance_Evaluation_Application.git
```

2. 프로젝트 디렉터리로 이동

```bash
cd Piano_Performance_Evaluation_Application
```

3. 파이썬 개발 환경 설정
```bash
python -m venv venv
pip install -r requirements.txt
```

4. 다트 개발 환경 설정
Flutter 개발 환경이 설정되어 있지 않다면, [Flutter 설치 가이드](https://dart-ko.dev/)를 참고하여 설치하세요.

```bash
flutter pub get
```

5. 파이썬 플라스크 서버 실행

```bash
python main.py
```


---

## CI/CD 구축 및 배포 방법(추가 예정)

aws ec2를 통한 배포 및 서비스 제공

빌드 오류를 낮추기 위해서 사용
```bash
flutter clean
```
빌드 오류를 낮추기 위해서 사용


```bash
flutter pub get
```
패키지 적용

```bash
flutter build
```
빌드 파일 생성


```bash
cd ./build/web
```

```bash
move web ./backend/templates
```


```bash
cd ./backend/templates
```

이하 추가 예정

---

