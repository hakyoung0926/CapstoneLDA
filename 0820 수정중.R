
# rm(list=ls())
library(plyr)
library(stringr)
# library(ggplot2)
# library(stringr)
# library(tm)
library(KoNLP)
library(LDAvis)
library(lda)
library(topicmodels)
library(servr)
# library(LDAvisData)
# library(MASS)
# library(wordcloud)
# library(wordcloud2)
library(RColorBrewer)
library(treemap)
library(extrafont)
library(shiny)
library(shinydashboard)

#Sys.setlocale(category = "LC_CTYPE", locale = "ko_KR.UTF-8")
require(showtext) #R샤이니에서 한글 안깨지게 하는 코드
font_add_google(name='Nanum Gothic', regular.wt=400,bold.wt=700)

showtext_auto()
showtext_opts(dpi=112)
#font_import(pattern='NanumBarunGothic')  # C:\Windows\Fonts 에 깔려있는 폰트 중 선택
#font_add('NanumBarunGothic','NanumBarunGothic.ttf') # 위에 거로 해보고 깨지면 이걸로 추가
bookName <- "아몬드"
setwd(dirname(rstudioapi::getSourceEditorContext()$path)) #불러들일경로 (negative,positive.txt여기에있어야함)
path <- file.path(dirname(rstudioapi::getSourceEditorContext()$path))
kor <- list.files(file.path(path, bookName))  
kor.files <- file.path(path, bookName, kor)   
content<- readLines(file.path(path,bookName,"content.txt"))          
txt <- lapply(kor.files, readLines)
#image <- file.path(path,bookName,"image.png")

topic <- setNames(txt, kor.files)  
topic <- sapply(topic, function(x) paste(x, collapse = " "))  

positive <- readLines("positive.txt")

positive=positive[-1] 
negative <- readLines("negative.txt")
negative=negative[-1]

sentimental = function(sentences, positive, negative){
  
  scores = laply(sentences, function(sentence, positive, negative) {
    
    sentence = gsub('[[:punct:]]', '', sentence) # 문장부호 제거
    sentence = gsub('[[:cntrl:]]', '', sentence) # 특수문자 제거
    sentence = gsub('\\d+', '', sentence)        # 숫자 제거
    
    word.list = str_split(sentence, '\\s+')      # 공백 기준으로 단어 생성 -> \\s+ : 공백 정규식, +(1개 이상)
    words = unlist(word.list)                    # unlist() : list를 vector 객체로 구조변경
    
    pos.matches = match(words, positive)           # words의 단어를 positive에서 matching
    neg.matches = match(words, negative)
    
    pos.matches = !is.na(pos.matches)            # NA 제거, 위치(숫자)만 추출
    neg.matches = !is.na(neg.matches)
    
    score = sum(pos.matches) - sum(neg.matches)  # 긍정 - 부정   
    return(score)
  }, positive, negative)
  
  scores.df = data.frame(score=scores, text=sentences)
  return(scores.df)
}

result=sentimental(topic, positive, negative)
result$color[result$score >=1] = "Olive Drab 2"
result$color[result$score ==0] = "Gray 60"
result$color[result$score < 0] = "Orange Red 2"

result$remark[result$score >=1] = "긍정"
result$remark[result$score ==0] = "중립"
result$remark[result$score < 0] = "부정"

sentiment_result= table(result$remark)
sentiment_percent= round(sentiment_result/sum(sentiment_result)*100, 2) # 백분율로 환산

library(tm) # 텍스트 마이닝 패키지 
stop_words <- stopwords("SMART") # 패키지에서 지원하는 불용어 목록
stop_words <- c(stopwords("SMART"), "")
# stopwords("SMART")

# pre-processing:
topic <- gsub("'", "", topic)  # remove apostrophes(')
topic <- gsub("[[:punct:]]", " ", topic)  # replace punctuation(구두점(!@#,.)) with space
topic <- gsub("[[:cntrl:]]", " ", topic)  # replace control characters(제어문자(\n, \t)) with space
topic <- gsub("^[[:space:]]+", "", topic) # remove whitespace at beginning of documents 
topic <- gsub("[[:space:]]+$", "", topic) # remove whitespace at end of documents 
for(i in (0:100)) {topic <- gsub(i,"",topic)}
for(i in (2000:2020)) {topic <- gsub(i,"",topic)}
topic <- gsub("lineheigh", "", topic)
topic <- gsub("setextparagraphalignlef", "", topic)
topic <- gsub("clas", "", topic)
topic <- gsub("styl", "", topic)
topic <- gsub("setextparagrap", "", topic)
topic <- gsub("있습니", "", topic)
topic <- gsub("malgu", "", topic)
topic <- gsub("gothi", "", topic)
topic <- gsub("합니", "", topic)
topic <- gsub("때문", "", topic)
topic <- gsub("않았", "", topic)
topic <- gsub("있었", "", topic)
topic <- gsub("그렇", "", topic)
topic <- gsub("것같", "", topic)
topic <- gsub("되었", "", topic)
topic <- gsub("없으", "", topic)
topic <- gsub("이렇", "", topic)
topic <- gsub("있도", "", topic)
topic <- gsub("김수", "", topic)
topic <- gsub("하게", "", topic)
topic <- gsub("많았", "", topic)
topic <- gsub("말해", "", topic)
topic <- gsub("내용", "", topic)
topic <- gsub("이야기", "", topic)
topic <- gsub("경우", "", topic)
topic <- gsub("무엇", "", topic)
topic <- gsub("지키", "", topic)
topic <- gsub("부분", "", topic)
topic <- gsub("제목", "", topic)
topic <- gsub("보이", "", topic)
topic <- gsub("다르", "", topic)
topic <- gsub("가지", "", topic)
topic <- gsub("각자", "", topic)
topic <- gsub("것처", "", topic)
topic <- gsub("나답", "", topic)
topic <- gsub("그동", "", topic)
topic <- gsub("해보", "", topic)
topic <- gsub("모르", "", topic)
topic <- gsub("오늘", "", topic)
topic <- gsub("맞추", "", topic)
topic <- gsub("들었", "", topic)
topic <- gsub("인간관", "", topic)
topic <- gsub("어떻", "", topic)
topic <- gsub("괴로", "", topic)
topic <- gsub("사람으", "", topic)
topic <- gsub("스스", "", topic)
topic <- gsub("싶었", "", topic)
topic <- gsub("[A-Za-z]","",topic) 
doc.list <- strsplit(topic, "[[:space:]]+")

# 명사 추출
useSejongDic()  # 세종 사전 사용
#--------------------------5 ~ 10초 소요------------------------------------
doc.list <- sapply(doc.list, extractNoun, USE.NAMES=F)
doc.list <- unlist(doc.list)
doc.list <- Filter(function(x){nchar(x)>1}, doc.list)

# compute the table of terms:
# 저장한 용어를 테이블 형식으로 저장
term.table <- table(doc.list)
term.table <- sort(term.table, decreasing = TRUE)

# remove terms that are stop words or occur fewer than 5 times:
# 불용어 또는 5회 미만으로 언급된 단어들을 제거
#del <- names(term.table) %in% stop_words | term.table < 5
del <- term.table < 5
term.table <- term.table[!del]
vocab <- names(term.table)

get.terms <- function(x) {
  index <- match(x, vocab)
  index <- index[!is.na(index)]
  rbind(as.integer(index-1), as.integer(rep(1, length(index))))
}
documents <- lapply(doc.list, get.terms) # 각 문서에 나오는 단어와 빈도수를 리스트 형식으로 저장

D <- length(documents)  # number of documents (2,000)
W <- length(vocab)  # number of terms in the vocab (14,568)
doc.length <- sapply(documents, function(x) sum(x[2, ]))  # number of tokens(단어) per document [312, 288, 170, 436, 291, ...]
N <- sum(doc.length)  # total number of tokens in the data (546,827)

term.frequency <- as.integer(term.table)  # frequencies of terms in the corpus [8939, 5544, 2411, 2410, 2143, ...]
# MCMC and model tuning parameters:
# MCMC 및 모델 튜닝 매개 변수
K <- 3  # 토픽의 개수 설정 
G <- 5000 # 반복 횟수
alpha <- 0.02
eta <- 0.02



set.seed(357) # sampling
t1 <- Sys.time()
#--------------------------------시간이 소요됨(약 1분 30초)----------------------------------------------------------------
fit <- lda.collapsed.gibbs.sampler(documents = documents, K = K, vocab = vocab, 
                                   num.iterations = G, alpha = alpha, 
                                   eta = eta, initial = NULL, burnin = 0,
                                   compute.log.likelihood = TRUE)

#----------------------------------------------------------------------------------------------------------------------
# 토픽 단어들을 단어 감성사전과 매칭
topicwords <- top.topic.words(fit$topics, 20, by.score = TRUE)  # 토픽별로 상위 20개 단어뽑기
topicwords<-c(topicwords[,1],topicwords[,3],topicwords[,3])     # 단어들 리스트로 합치기

search<- names(term.table) %in% topicwords                      # 빈도수 테이블에서 단어 검사
newterm.table <- term.table[search]                             # 단어와 빈도수로 새로운 테이블 생성

new_sentiment <- readLines("sorted.txt")
new_sentiment=new_sentiment[-1]

newterm.data<-data.frame(newterm.table)
newterm.vec<-rep(newterm.data$doc.list)

sent.matches = match(newterm.vec, new_sentiment)          # 단어를 matching
sent.matches = !is.na(sent.matches)            # NA 제거, 위치(숫자)만 추출

sent.table<-newterm.table[sent.matches]                # 단어와 빈도수로 새로운 테이블 생성
sent.frequency <- as.integer(sent.table)
#length(sent.table)

t2 <- Sys.time()
t2 - t1  # about 24 minutes on laptop

theta <- t(apply(fit$document_sums + alpha, 2, function(x) x/sum(x)))
phi <- t(apply(t(fit$topics) + eta, 2, function(x) x/sum(x)))

result <- list(phi = phi,
               theta = theta,
               doc.length = doc.length,
               vocab = vocab,
               term.frequency = term.frequency,encoding='UTF-8')


# options(encoding = 'UTF-8')

#create the JSON object to feed the visualization:

# json <- createJSON(phi = result$phi,
#                    theta = result$theta,
#                    doc.length = result$doc.length,
#                    vocab = result$vocab,
#                    term.frequency = result$term.frequency,encoding='UTF-8')
# 
# serVis(json, out.dir = 'vis', open.browser = FALSE)
#bookName <- paste('<',bookName,'>')


ui <- dashboardPage(skin="blue",
  title= "리뷰 분석 시스템",
  dashboardHeader(
    title = "리뷰 분석 시스템",
    titleWidth = 350
  ),
  dashboardSidebar(
    width = 350,
    h3(textOutput("bookName"),align="center"),
    sidebarMenu(
      menuItem("줄거리",tabName="bookContent",icon=icon("book")),
      menuItem("토픽분석",tabName ="topic",icon=icon("dashboard")),
      menuItem("감정분석",tabName ="sentiment",icon = icon("chart-pie")),
      textInput("directory",label="경로",value=path)
    )
      
    # textInput("bookName",label = "??? ??????",placeholder="??? ????????? ???????????????",width="90%"),
    # actionButton("button",label = "??????",icon("paper-plane"))
  ),
  dashboardBody(
    
    tags$head(tags$style(HTML('
      .main-header .logo {
        font-weight: bold;
        font-size: 24px;
      }
      
    '))),
    # Boxes need to be put in a row (or column)
    #h1(textOutput("value"))
    #h3(textOutput("value"),textOutput("text1"))
    
    #h3(textOutput("text"))
    tabItems(
      
      tabItem(tabName="bookContent",
        hr(),
        imageOutput("image"),
        h1("줄거리"),
        hr(),  
        box(
            textOutput("content")
        )
      ),
      
      tabItem(tabName = "topic",
          h1("토픽분석"),
          hr(),
          visOutput('myChart')
      ),
      
      tabItem(tabName="sentiment",
        h1("감정분석"),
        hr(),
        splitLayout(
          style = "border: 1px solid silver;border-radius: 4px;",
          cellArgs = list(style = "padding: 4px"), 
          plotOutput(outputId = "sentiment_result"),plotOutput(outputId = "treemap"))
      )
    )
  )
)

server <- function(input, output,session) {
  
  # observeEvent(input$button,{
  #   bookN <- input$bookName
  #   output$value <- renderText(bookN)
  #   output$text1 <- renderText({paste("??? ?????? ????????? ?????????????????????.")})
  #   output$text <- renderText({paste(bookN,"??? ?????? ????????? ?????? ???????????????")})
  # })
  output$bookName <- renderText(bookName)
  output$content <- renderText(content)
  output$image <- renderImage({
     list(
       src = file.path(path,bookName,"image.png"),
       contentType = "image/png",
       alt = "img"
     )
    
  },deleteFile = FALSE)
  
  output$myChart <- renderVis({
    with(result,
         createJSON(phi = result$phi,
                    theta = result$theta,
                    doc.length = result$doc.length,
                    vocab = result$vocab,
                    term.frequency = result$term.frequency,encoding='UTF8'))
  })
  output$sentiment_result <- renderPlot({pie(sentiment_result, main="감정분석 결과",col=c("skyblue2","lightcoral","palegreen2"),
                                             label=paste(names(sentiment_percent),'', sentiment_percent,"%"),
                                             border = FALSE, radius=1)})
  
  output$treemap <- renderPlot({
    dset<-data.frame(keywords=names(sent.table), sentiment=sent.frequency)#괄호안에 데이터셋 넣으면됨()
    
    treemap(dset
            ,index=c("keywords")#괄호안에 "키워드" 로 바꾸면됨
            ,vSize=c("sentiment") # 타일의 크기 (언급횟수로 바꾸면 됨)
            ,vColor=c("sentiment") # 타일의 컬러
            ,type="value" # 타일 컬러링 방법
            ,title="감정"
            ,title.legend="빈도수"
            ,fontsize.title=15
            ,fontsize.legend=11
            ,fontsize.labels = 11
            ,fontface.labels = c("bold")
            ,fontfamily.labels = "NanumBarunGothic"  # 추가한 폰트 넣기
            ,fontfamily.title = "NanumBarunGothic"
            ,fontfamily.legend = "NanumBarunGothic"
            ,palette = "GnBu" #위에서 받은 팔레트 정보 입력
            ,border.col = "white") # 레이블의 배경색
  })
  # output$myChart <- renderVis(json)
  #output$value <- renderText({bookName})
  #output$value <- renderText({input$bookName})
  
  
}

shinyApp(ui, server)