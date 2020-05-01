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

## 토픽추출 
  - LDA 알고리즘을 이용해 리뷰의 핵심 키워드인 토픽 추출 
  - R을 이용해 구현
  - rShiny 를 이용한 결과 웹 시각화
   <div>
  <img width="800" src="https://user-images.githubusercontent.com/58851760/80810830-97ec7980-8bff-11ea-93dd-aa49d1e25969.png">
</div>
 



