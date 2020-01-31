from selenium import webdriver
from bs4 import BeautifulSoup
from urllib.request import urlopen

path = "C:/dev/chromedriver.exe"
driver = webdriver.Chrome(path)
driver.get('http://www.kyobobook.co.kr/product/detailViewKor.laf?mallGb=KOR&ejkGb=KOR&barcode=9791162540640')
window_before = driver.window_handles[0]
print(driver.current_url)
driver.find_element_by_link_text("전체보기").click()
window_after = driver.window_handles[1]
driver.switch_to_window(window_after)

print("현재윈도우 URL : ",driver.current_url)  
print("변경전윈도우: ",str(window_before))
print("변경후윈도우: ",str(window_after))

html = driver.page_source
bsObject = BeautifulSoup(html,"html.parser")
reviews = bsObject.find("ul",{"class":"list_detail_booklog"})
pages = bsObject.find("div",{"class":"list_paging"}).find("ul").find_all('li')
for i in range(1,len(pages)+1):
    #print("loop"+str(i))
    html = driver.page_source
    bsObject = BeautifulSoup(html,"html.parser")
    reviews = bsObject.find("ul",{"class":"list_detail_booklog"})
    with open("123.txt","a",encoding="utf-8") as f :
        for review in reviews.find_all('li'):
            f.write(review.text)
    if i < len(pages) :
        driver.find_element_by_link_text(str(i+1)).click()
    else :
        f.close()
        driver.close()
        driver.switch_to_window(window_before)
        driver.close()
        break
