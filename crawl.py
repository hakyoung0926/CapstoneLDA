#-*- coding:utf-8 -*-
from selenium import webdriver
from bs4 import BeautifulSoup
from urllib.request import urlopen
from selenium.common.exceptions import NoSuchElementException
from pathlib import Path
import time
import io

# 브라우저 띄우지 않고
# chrome_options = webdriver.ChromeOptions()
# chrome_options.add_argument('headless')
# chrome_options.add_argument('--disable-gpu')
# chrome_options.add_argument('lang=ko_KR')

search = input("검색하고싶은 책 이름 : ")
path = "C:/dev/chromedriver.exe"

# selenium 설정
# 브라우저 백그라운드
#driver = webdriver.Chrome(path, options=chrome_options)
# 브라우저 백그라운드 X
driver = webdriver.Chrome(path)
driver.implicitly_wait(3)
driver.get('http://www.kyobobook.co.kr/index.laf')
time.sleep(5) # 인터넷이 느린경우 팝업이 늦게 떠서 sleep 사용
if driver.window_handles[1]:
    print("팝업 제거.")
    driver.switch_to.window(driver.window_handles[1])
    driver.close()
    driver.switch_to.window(driver.window_handles[0])

driver.find_element_by_xpath("//*[@id='searchKeyword']").send_keys(search)
driver.find_element_by_xpath("/html/body/div[4]/div[1]/div[1]/div[1]/form[2]/div/input").click()
bookCount = 0
books=[]
print("-----------------------------")
try:
    # 검색결과가 존재하는지 확인
    bookExist = driver.find_element_by_xpath("//*[@id='search_list']/tr[1]/td[2]/div[2]/a")
    for i in range(1, 6):
        try:
            bookName = driver.find_element_by_xpath("//*[@id='search_list']/tr["+str(i)+"]/td[2]/div[2]/a/strong").text
            print(str(i)+".", bookName)
            books.append(bookName)
            bookCount = bookCount + 1
        except NoSuchElementException:
            break
    print("-----------------------------")
    time.sleep(2)
    while True:
        selectNum = str(input("번호 입력 : "))
        if int(selectNum) <= bookCount:
            break
        else:
            continue
    selectedBook = driver.find_element_by_xpath("//*[@id='search_list']/tr["+selectNum+"]/td[2]/div[2]/a")
    selectedBookName = driver.find_element_by_xpath("//*[@id='search_list']/tr["+selectNum+"]/td[2]/div[2]/a/strong").text
    print("선택한 책 :", selectedBookName)
    print("사용자 검색어 :", search)
    print("----------------------------------------")
except NoSuchElementException:
    print("검색하시려는 책이 없습니다. 종료합니다")
    driver.quit()
    exit()
selectedBook.click()
window_before = driver.window_handles[0]
print(driver.current_url)
try:
    showReview = driver.find_element_by_link_text("전체보기")
    print("검색하신 책의 리뷰를 찾았습니다.")
except NoSuchElementException:
    print("검색하신 책의 리뷰가 없습니다. 종료합니다")
    driver.quit()
    exit()
showReview.click()
window_after = driver.window_handles[1]
driver.switch_to.window(window_after)

print("현재윈도우 URL : ",driver.current_url)
print("변경전윈도우: ",str(window_before))
print("변경후윈도우: ",str(window_after))

html = driver.page_source
bsObject = BeautifulSoup(html, "html.parser")
reviews = bsObject.find("ul", {"class":"list_detail_booklog"})
pages = bsObject.find("div", {"class":"list_paging"}).find("ul").find_all('li')
reviewNum=1
for i in range(1,len(pages)+1):
    html = driver.page_source
    bsObject = BeautifulSoup(html, "html.parser")
    reviews = bsObject.find("ul", {"class": "list_detail_booklog"})
    reviewslis = reviews.find_all('li')
    for review in reviewslis:
        reviewC = review.find("div", {"class": "content"})
        if reviewC is None:
            continue
        # savedDir = "./reviewF/"
        Path("./"+selectedBookName).mkdir(parents=True, exist_ok=True)
        savedDir = "./"+selectedBookName+"/"
        savedName = str(reviewNum)+".txt"
        print(type(reviewC))
        reviewContent = reviewC.get_text()
        # 데이터 띄어쓰기,줄바꿈 제거
        reviewContent = " ".join(reviewContent.split())
        reviewContent = reviewContent.replace('>', '').replace('<', '').replace('*', '').replace('-', '').replace('#', '').replace('^', '').replace('~', '')
        # reviewContent = reviewContent.splitlines()
        path = savedDir+savedName
        with open(path, "w", encoding="cp949", errors='ignore') as f:
            f.write(reviewContent)
            print(reviewNum, "번째 리뷰가 저장되었습니다.")
        f.close()
        reviewNum = reviewNum + 1
    if i < len(pages):
        driver.find_element_by_link_text(str(i+1)).click()
    else:
        f.close()
        driver.close()
        driver.switch_to.window(window_before)
        driver.close()
        break
