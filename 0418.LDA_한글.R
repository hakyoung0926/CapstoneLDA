# 디렉토리 내 파일들 불러오기 http://rfriend.tistory.com/219
# 코드 설명 참조 https://ldavis.cpsievert.me/reviews/reviews.html 

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
rm(list=ls())
library(lda)
library(stringr)
library(tm)
library(KoNLP)
library(topicmodels)
library(LDAvis)
library(servr)
library(LDAvisData)
library(MASS)
# KoNLP 사용을 위한 
path <- file.path("C:/Users/안운빈/Desktop/4-1/종설1")  # 폴더 경로를 객체로 만든다
kor <- list.files(file.path(path, "스스로 행복하라"))  #폴더 경로 중 eng라는 폴더에 있는 파일들 이름을 list-up해서 객체로 만든다.
kor.files <- file.path(path, "스스로 행복하라", kor)   #아까 list-up한 파일의 이름들로 폴더의 경로를 다시 객체로 만든다.
#all.files <- c(kor.files, eng.files) 다른 폴더에 있는 파일과 같이 돌릴때 사용
txt <- lapply(kor.files, readLines)    #txt에 이름을 붙여서 새 객체 생성월
topic <- setNames(txt, kor.files)      # 텍스트 파일의 목록만큼 데이터를 읽어오고, 그 결과를 list 형태로 저장
topic <- sapply(topic, function(x) paste(x, collapse = " "))  #topic에 있는 리스트들을 공백을 두고 이어붙임

# 폴더 경로 객체로 만들
#src_dir <- c("D:/R/WordPlace/review_polarity.tar/txt_sentoken/neg")
# 폴더 내 파일들 이름을 list-up 하여 객체로 만들기
#src_file <- list.files(src_dir)
# 파일 개수 객체로 만들기
#src_file_cnt <- length(src_file)

#setwd("D:/R/WordPlace/review_polarity.tar/txt_sentoken/neg")

# 현재 작업 공간에 있는 텍스트 파일 목록 가져오기
#files = dir(pattern = "txt")
# 텍스트 파일의 목록만큼 데이터를 읽어오고, 그 결과를 list 형태로 저장
#datas = lapply(files, read.table, sep="\n", header=F)
# list 형태로 된 R 데이터를 rbind() 함수를 이용하여 합침
#topic = do.call(rbind, datas)

# read in some stopwords:
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
topic <- gsub("Malgu", "", topic)
topic <- gsub("Gothi", "", topic)
topic <- gsub("합니", "", topic)
topic <- gsub("때문", "", topic)
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
term.table

# remove terms that are stop words or occur fewer than 5 times:
# 불용어 또는 5회 미만으로 언급된 단어들을 제거
del <- names(term.table) %in% stop_words | term.table < 5
term.table <- term.table[!del]
vocab <- names(term.table)
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

#write.table(rst1,"LDA_data1.txt",sep="\t",row.names=FALSE)
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

library(shiny)
library(LDAvis)

data(TwentyNewsgroups, package = "LDAvis")
ui <- shinyUI(
  fluidPage(
    sliderInput("nTerms", "Number of terms to display", min = 20, max = 40, value = 30),
    visOutput('myChart')
  )
)

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
})

shinyApp(ui = ui, server = server)
