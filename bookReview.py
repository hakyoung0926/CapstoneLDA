from urllib.request import urlopen
from bs4 import BeautifulSoup
# 링크만 바꿔서 책 종류 선택 가능
html = urlopen('http://www.kyobobook.co.kr/bestSellerNew/bestseller.laf?mallGb=KOR&linkClass=B&range=1&kind=0&orderClick=DAb')
bsObject = BeautifulSoup(html,"html.parser")

book_page_urls = []
for cover in bsObject.find_all('div',{'class':'detail'}):
    link = cover.select('a')[0].get('href')
    #print(link)
    book_page_urls.append(link)
for index,book_page_url in enumerate(book_page_urls):
    review =[]
    html = urlopen(book_page_url)
    bsObject = BeautifulSoup(html,"html.parser")
    title = bsObject.find('meta',{'property':'rb:itemName'}).get('content')
    author = bsObject.select('span.name a')[0].text
    url = bsObject.find('meta',{'property':'rb:itemUrl'}).get('content')
    print(index+1, title,author,url)