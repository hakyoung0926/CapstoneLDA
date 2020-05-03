# 문서토픽추출시스템 (Document Topic Extraction System)
## 교보문고 홈페이지의 책 리뷰를 이용하여 핵심 키워드 추출, 감정분석을 통해 책의 내용 유추 및 사용자들의 리뷰를 분석
한국산업기술대학교 컴퓨터공학과 종합설계 S3-12





# 시스템
  - 웹 크롤링(CrawlGui.py)
  - 토픽추출(LDA_한글.R)
  - 감정분석(추가예정)


## 웹크롤링 
  - Selenium, BeautifulSoup4 을 이용한 크롤링 자동화 
  - PyQt5 를 이용한 GUI 구현
 <div>
  <img width="600" src="https://user-images.githubusercontent.com/43024383/80808116-c8c9b000-8bf9-11ea-953f-99304b275353.png">
</div>

  - 설치
```
    pip install selenium
    pip install pyqt5
    pip install bs4
```
  - 웹크롤링은 Google chrome을 사용하므로 Chrome Webdriver를 설치해야함<br> 
    설치 경로 : C:/dev/chromedriver.exe  <br>
    https://sites.google.com/a/chromium.org/chromedriver/downloads
* [Selenium](https://www.selenium.dev/documentation/ko/) - 브라우저 자동화

## 토픽추출 
  - LDA 알고리즘을 이용해 리뷰의 핵심 키워드인 토픽 추출 
  - R을 이용해 구현
  - rShiny 를 이용한 결과 웹 시각화
   <div>
  <img width="800" src="https://user-images.githubusercontent.com/58851760/80811424-da628600-8c00-11ea-9c43-df04276206e9.png">
</div>
 
## 감정분석
 - 크롤링된 리뷰들을 감정분석
 - R을 이용해 구현
 - 감정사전(긍정어,부정어 사전)을 이용하여 감정분석
 - rShiny 를 이용한 웹 시각화


