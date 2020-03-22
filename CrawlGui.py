import sys
from PyQt5 import QtWidgets ,uic
from PyQt5.QtCore import *
from selenium import webdriver
from bs4 import BeautifulSoup
from urllib.request import urlopen
from selenium.common.exceptions import NoSuchElementException
from pathlib import Path
import time
import io
path = "C:/dev/chromedriver.exe"
search = None
selectNum = None
status = False
class Worker(QThread):
    finished = pyqtSignal(list)
    def run(self):
        global status
        global search
        global selectNum
        global path
        status = True
        driver = webdriver.Chrome(path)
        driver.implicitly_wait(3)
        driver.get('http://www.kyobobook.co.kr/index.laf')
        time.sleep(2)

        if driver.window_handles[1]:
            print("팝업 제거.")
            driver.switch_to.window(driver.window_handles[1])
            driver.close()
            driver.switch_to.window(driver.window_handles[0])

        driver.find_element_by_xpath("//*[@id='searchKeyword']").send_keys(search)
        driver.find_element_by_xpath("/html/body/div[4]/div[1]/div[1]/div[1]/form[2]/div/input").click()
        bookCount = 0
        books = []
        try:
            bookExist = driver.find_element_by_xpath("//*[@id='search_list']/tr[1]/td[2]/div[2]/a")
            for i in range(1, 6):
                try:
                    bookName = driver.find_element_by_xpath(
                        "//*[@id='search_list']/tr[" + str(i) + "]/td[2]/div[2]/a/strong").text
                    print(str(i) + ".", bookName)
                    books.append(bookName)
                    bookCount = bookCount + 1
                except NoSuchElementException:
                    break
            self.finished.emit(books)
            while True :
                if selectNum == None:
                    pass
                else : break
            selectedBook = driver.find_element_by_xpath("//*[@id='search_list']/tr[" + str(selectNum) + "]/td[2]/div[2]/a")
            selectedBookName = driver.find_element_by_xpath("//*[@id='search_list']/tr[" + str(selectNum) + "]/td[2]/div[2]/a/strong").text
        except NoSuchElementException:
            self.finished.emit(books)
            driver.quit()

        selectedBook.click()
        window_before = driver.window_handles[0]
        try:
            showReview = driver.find_element_by_link_text("전체보기")
            print("검색하신 책의 리뷰를 찾았습니다.")
        except NoSuchElementException:
            print("검색하신 책의 리뷰가 없습니다. 종료합니다")
            driver.quit()
        showReview.click()
        window_after = driver.window_handles[1]
        driver.switch_to.window(window_after)

        print("현재윈도우 URL : ", driver.current_url)
        print("변경전윈도우: ", str(window_before))
        print("변경후윈도우: ", str(window_after))

        html = driver.page_source
        bsObject = BeautifulSoup(html, "html.parser")
        reviews = bsObject.find("ul", {"class": "list_detail_booklog"})
        pages = bsObject.find("div", {"class": "list_paging"}).find("ul").find_all('li')
        reviewNum = 1
        for i in range(1, len(pages) + 1):
            html = driver.page_source
            bsObject = BeautifulSoup(html, "html.parser")
            reviews = bsObject.find("ul", {"class": "list_detail_booklog"})
            reviewslis = reviews.find_all('li')
            for review in reviewslis:
                reviewC = review.find("div", {"class": "content"})
                if reviewC is None:
                    continue
                # savedDir = "./reviewF/"
                Path("./" + selectedBookName).mkdir(parents=True, exist_ok=True)
                savedDir = "./" + selectedBookName + "/"
                savedName = str(reviewNum) + ".txt"
                print(type(reviewC))
                reviewContent = reviewC.get_text()
                # 데이터 띄어쓰기,줄바꿈 제거
                reviewContent = " ".join(reviewContent.split())
                reviewContent = reviewContent.replace('>', '').replace('<', '').replace('*', '').replace('-',
                                                                                                         '').replace(
                    '#', '').replace('^', '').replace('~', '')
                # reviewContent = reviewContent.splitlines()
                path = savedDir + savedName
                with open(path, "w", encoding="cp949", errors='ignore') as f:
                    f.write(reviewContent)
                    print(reviewNum, "번째 리뷰가 저장되었습니다.")
                f.close()
                reviewNum = reviewNum + 1
            if i < len(pages):
                driver.find_element_by_link_text(str(i + 1)).click()
            else:
                f.close()
                # driver.close()
                # driver.switch_to.window(window_before)
                # driver.close()
                driver.quit()
        print("리뷰 추출이 완료되었습니다.")
        status = False
class Form(QtWidgets.QDialog):
    def __init__(self,parent=None):
        super().__init__()
        self.ui = uic.loadUi("test.ui")
        self.ui.show()
        self.ui.search_btn.clicked.connect(self.searchBook)
        self.ui.quit_btn.clicked.connect(self.quitGUI)
        self.ui.bookList.itemDoubleClicked.connect(self.select_book)
    def quitGUI(self):
        QtWidgets.QMessageBox.about(self, 'Message', '프로그램을 종료합니다')
        exit()
    def searchBook(self):
        global search
        search = self.ui.search_name.text()
        self.worker = Worker()
        self.worker.finished.connect(self.update_list)
        self.worker.start()
    def select_book(self):
        global selectNum
        # QtWidgets.QMessageBox.about(self, 'Message', self.ui.bookList.currentItem().text())
        selectNum = self.ui.bookList.currentRow()+1
        # print(self.ui.bookList.currentRow())
        print(self.ui.bookList.currentItem().text())
    @pyqtSlot(list)
    def update_list(self, data):
        self.ui.bookList.clear()
        print(type(data))
        if len(data)==0:
            QtWidgets.QMessageBox.about(self,'Message','검색 결과 없음, 다시검색 ')
        else:
            for i in data:
                self.ui.bookList.addItem(str(i))

if __name__ == '__main__':
    app = QtWidgets.QApplication(sys.argv)
    w = Form()
    sys.exit(app.exec())