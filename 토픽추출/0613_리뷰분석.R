# install.packages('KoNLP')
# install.packages('tm')
# install.packages('stringr')
# install.packages('lda')
# install.packages('topicmodels')
# install.packages('LDAvis')
# install.packages('servr')
# install.packages('LDAvisData')
# install.packages("devtools")
# install.packages('shiny')
# install.packages('devtools')
# install.packages('digest')
# install.packages('jsonlite')
# install.packages('glue')
# install.packages('pkgbuild')
# install.packages('usethis')
# devtools::install_github("lchiffon/wordcloud2")
# install.packages("treemap")

rm(list=ls())
library(plyr)
library(stringr)
library(shiny)
library(ggplot2)
library(lda)
library(stringr)
library(tm)
library(KoNLP)
library(topicmodels)
library(LDAvis)
library(servr)
library(LDAvisData)
library(MASS)
library(wordcloud)
library(wordcloud2)
library(RColorBrewer)
library(treemap)
#Sys.setlocale(category = "LC_CTYPE", locale = "ko_KR.UTF-8")

require(showtext) #R샤이니에서 한글 안깨지게 하는 코드
font_add_google(name='Nanum Gothic', regular.wt=400,bold.wt=700)
showtext_auto()
showtext_opts(dpi=112)

setwd("C:/Users/안운빈/Desktop/4-1/종설1/gamsung") #불러들일경로 (negative,positive.txt여기에있어야함)
#txt<-readLines("15.txt",warn=FALSE) #감정분석할 텍스트파일 불러오기

path <- file.path("C:/Users/안운빈/Desktop/4-1/종설1/txt")  # 폴더 경로를 객체로 만든다
kor <- list.files(file.path(path, "애쓰지 않고 편안하게"))  #폴더 경로 중 eng라는 폴더에 있는 파일들 이름을 list-up해서 객체로 만든다.
kor.files <- file.path(path, "애쓰지 않고 편안하게", kor)   #아까 list-up한 파일의 이름들로 폴더의 경로를 다시 객체로 만든다.
content<- readLines(file.path(path,"애쓰지 않고 편안하게/content.txt"))          # content를 따로 저장  
#all.files <- c(kor.files, eng.files) 다른 폴더에 있는 파일과 같이 돌릴때 사용
txt <- lapply(kor.files, readLines)    #txt에 이름을 붙여서 새 객체 생성
topic <- setNames(txt, kor.files)      # 텍스트 파일의 목록만큼 데이터를 읽어오고, 그 결과를 list 형태로 저장
topic <- sapply(topic, function(x) paste(x, collapse = " "))  #topic에 있는 리스트들을 공백을 두고 이어붙임

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
# ----------------------------------------------------------------------------여기까지 감정분석
#sentiment_percent

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
topic <- gsub("[A-Za-z]","",topic) 
doc.list <- strsplit(topic, "[[:space:]]+")

# 명사 추출
useSejongDic()  # 세종 사전 사용
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
#write.table(vocab,"아몬드.txt",sep="\t",row.names=FALSE)

# now put the documents into the format required by the lda package:
# 문서를 LDA패키지에 필요한 형식으로 삽입
get.terms <- function(x) {
  index <- match(x, vocab)
  index <- index[!is.na(index)]
  rbind(as.integer(index-1), as.integer(rep(1, length(index))))
}
documents <- lapply(doc.list, get.terms) # 각 문서에 나오는 단어와 빈도수를 리스트 형식으로 저장
#doc.list
#documents
#get.terms()
# Compute some statistics related to the data set:
# 데이터셋과 관련된 일부 통계를 계산
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

# Fit the model:
# 각 문서에 K개의 토픽들 중 하나를 랜덤하게 할당
# 모든 문서들은 토픽을 갖고, 모든 토픽은 단어 분포를 가지게 됨. 
#  각 토픽에 대해, 두 가지를 계산 
#     1. 문서 d의 단어들 w 중 토픽 t에 해당하는 단어들의 비율을 계산 (랜덤으로 할당된 토픽 t에 문서들의 어떤 단어들이 가장 많이 언급되었는지)
#     2. 단어 w를 가지고 있는 모든 문서들 중 토픽 t가 할당된 비율 계산 (해당 단어 w가 토픽 t에 적합한지)
#  결과 1*2에 따라 토픽 t를 새로 고른다. (토픽 t에 적합한 단어 w를 선정)
# 이 과정이 충분히 반복되고 나면, 안정적인 상태에 도달
library(lda)
library(topicmodels)
set.seed(357) # sampling
t1 <- Sys.time()
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

new_sentiment <- readLines("단어 감성사전.txt")
new_sentiment=new_sentiment[-1]

newterm.data<-data.frame(newterm.table)
newterm.vec<-rep(newterm.data$doc.list)

sent.matches = match(newterm.vec, new_sentiment)          # 단어를 matching
sent.matches = !is.na(sent.matches)            # NA 제거, 위치(숫자)만 추출

sent.table<-newterm.table[sent.matches]                # 단어와 빈도수로 새로운 테이블 생성
sent.frequency <- as.integer(sent.table)
#length(sent.table)
#---------------------------------------------------------------------------------------------------------------------

t2 <- Sys.time()
t2 - t1  # about 24 minutes on laptop

#Terms.Probability<- 10^t(result$theta)

theta <- t(apply(fit$document_sums + alpha, 2, function(x) x/sum(x)))
phi <- t(apply(t(fit$topics) + eta, 2, function(x) x/sum(x)))

#phi_t<-t(phi)
#y<-data.frame(vocab,phi_t)
#z<-data.frame(theta)
#srt1<-y[order(-y$X1),]
#sub3<-subset(srt1,select=c(1,2))
#rst3<-data.frame(sub3)

#srt2<-y[order(-y$X2),]
#sub1<-subset(srt2,select=c(1,3))
#rst1<-data.frame(sub1)

#srt3<-y[order(-y$X3),]
#sub2<-subset(srt3,select=c(1,4))
#rst2<-data.frame(sub2)
#vocab
#write.table(vocab,"녹나무.txt",sep="\t",row.names=FALSE)
#write.table(rst2,"LDA_data2.txt",sep="\t",row.names=FALSE)
#write.table(rst3,"LDA_data3.txt",sep="\t",row.names=FALSE)

result <- list(phi = phi,
               theta = theta,
               doc.length = doc.length,
               vocab = vocab,
               term.frequency = term.frequency,encoding='UTF-8')

#x<-data.frame(vocab,term.frequency)
#write.table(x,"LDA_data.txt",sep="\t",row.names=FALSE)
#sorted <- t(apply(phi,1,sort))

library(LDAvis)
options(encoding = 'UTF-8')
# create the JSON object to feed the visualization:
json <- createJSON(phi = result$phi, 
                   theta = result$theta, 
                   doc.length = result$doc.length, 
                   vocab = result$vocab, 
                   term.frequency = result$term.frequency,encoding='UTF-8')

serVis(json, out.dir = 'vis', open.browser = TRUE)

#----------------------------------------------------------------------------------------------------------------------------
# wordCloud <- wordcloud(
#   names(term.table),
#   freq=term.table,
#   scale=c(5,0.2), #빈도가 가장 큰 단어와 가장 빈도가 작은단어 폰사 사이 크기
#   rot.per=0.1, #90도 회전해서 보여줄 단어 비율
#   min.freq=3, max.words=100, # 빈도 3이상, 100미만
#   random.order=F, # True : 랜덤배치, False : 빈도수가 큰단어를 중앙에 배치
#   random.color=T, # True : 색랜덤, False : 빈도순
#   colors=brewer.pal(11, "Paired"), #11은 사용할 색상개수, 두번째는 색상타입이름
#   family="font")

#-----------------------------------------------------------------------------------------------------------------------------

data(TwentyNewsgroups, package = "LDAvis")

ui <- fluidPage(
  # App title ----
  titlePanel("Review Analysis System"),
  
  # Sidebar layout with input and output definitions ----
  sidebarLayout(
    # Sidebar panel for inputs ----
    sidebarPanel(
      "summary",textOutput("content"), br()),
    
    mainPanel(
      
      # Output: Tabset w/ plot, summary, and table ----
      tabsetPanel(type = "tabs",
                  tabPanel("topic", sliderInput("nTerms", "Number of terms to display", min = 20, max = 40, value = 30), visOutput('myChart')),
                  tabPanel("sentimental analysis", 
                           splitLayout(
                             style = "border: 1px solid silver;",
                             cellArgs = list(style = "padding: 4px"), 
                             cellWidths = 350,
                             plotOutput(outputId = "sentiment_result"),plotOutput(outputId = "treemap")))
      )
      
    )))

server <- shinyServer(function(input, output, session) {
  output$myChart <- renderVis({
    if(!is.null(input$nTerms)){
      with(result, 
           createJSON(phi = result$phi, 
                      theta = result$theta, 
                      doc.length = result$doc.length, 
                      vocab = result$vocab, 
                      term.frequency = result$term.frequency,encoding='UTF-8'))
      
      
    } 
  })
  output$sentiment_result <- renderPlot({pie(sentiment_result, main="감정분석 결과",col=c("dodger blue","Orange Red 2","dark olive green 3"),
                                             label=paste(names(sentiment_percent),'', sentiment_percent,"%"), radius=1)})
  
  output$content<-renderText(content)
  
  output$treemap <- renderPlot({
    dset<-data.frame(keywords=names(sent.table), 감정=sent.frequency)#괄호안에 데이터셋 넣으면됨()
    
    treemap(dset
            ,index=c("keywords")#괄호안에 "키워드" 로 바꾸면됨
            ,vSize=c("감정") # 타일의 크기 (언급횟수로 바꾸면 됨)
            ,vColor=c("감정") # 타일의 컬러
            ,type="value" # 타일 컬러링 방법
            ,fontsize.labels = 9
            ,fontface.labels = c("bold")
            ,fontfamily.labels = "wqy-microhei"
            ,palette = "BuGn" #위에서 받은 팔레트 정보 입력
            ,border.col = "white") # 레이블의 배경색
  })
})

shinyApp(ui = ui, server = server)