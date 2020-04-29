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
import os

search = None # 검색어
selectNum = None # 책 선택 인덱스
status = False # 웹 크롤링 시작 상태 True : 진행중 , False : 꺼짐
class Worker(QThread):
    finished = pyqtSignal(list)
    runCheck = pyqtSignal(bool) # 크롤링 후 팝업 띄우기용
    reviewCheck = pyqtSignal(bool) # 리뷰 유무 확인 True : review 있음, False : 없음
    def run(self):
        global status
        global search
        global selectNum
        checkend = False # False : 진행중 , True: 종료됨
        reviewExist = None # True : review 있음, False : 없음
        path = "C:/dev/chromedriver.exe"
        print(path)
        driver = webdriver.Chrome(path)
        driver.implicitly_wait(3)
        driver.get('http://www.kyobobook.co.kr/index.laf')
        # time.sleep(2)
        driver.implicitly_wait(3)
        if driver.window_handles[1]:
            print("팝업 제거.")
            driver.switch_to.window(driver.window_handles[1])
            driver.close()
            driver.switch_to.window(driver.window_handles[0])
        driver.find_element_by_xpath("//*[@id='searchKeyword']").send_keys(search)
        driver.find_element_by_xpath("/html/body/div[4]/div[1]/div[1]/div[1]/form[2]/div/input").click()
        books = [] # 검색한 책 리스트
        driver.implicitly_wait(3)
        try:
            bookExist = driver.find_element_by_xpath("//*[@id='search_list']/tr[1]/td[2]/div[2]/a")
            # 검색한 책 찾았을 경우
            for i in range(1, 6):
                try:
                    bookName = driver.find_element_by_xpath(
                        "//*[@id='search_list']/tr[" + str(i) + "]/td[2]/div[2]/a/strong").text
                    print(str(i) + ".", bookName)
                    books.append(bookName)
                # 책 이름이 없을 시 반복문 종료
                except NoSuchElementException:
                    break
            self.finished.emit(books) # 검색 완료 후 결과 전송(검색 결과 있음)

            # 사용자가 책을 선택할 때 까지 대기
            while True :
                if selectNum is None:
                    pass
                else : break
        except NoSuchElementException:
            # 검색한 책 찾지 못했을 경우
            self.finished.emit(books) # 검색 완료 후 결과 전송(검색 결과 없음)
            search = None
            selectNum = None
            status = False
            checkend = True
            driver.quit()
            # self.quit()
            return None
        selectedBook = driver.find_element_by_xpath("//*[@id='search_list']/tr[" + str(selectNum) + "]/td[2]/div[2]/a")
        selectedBookName = driver.find_element_by_xpath("//*[@id='search_list']/tr[" + str(selectNum) + "]/td[2]/div[2]/a/strong").text
        selectedBook.click()
        window_before = driver.window_handles[0]
        try:
            showReview = driver.find_element_by_link_text("전체보기")
            print("검색하신 책의 리뷰를 찾았습니다.")
            reviewExist = True
        except NoSuchElementException:
            print("검색하신 책의 리뷰가 없습니다. 종료합니다")
            reviewExist = False
            self.reviewCheck.emit(reviewExist)
            driver.quit()
            reviewExist = None
            search = None
            selectNum = None
            status = False
            checkend = True
            return None
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
            # 다음페이지로 이동
            if i < len(pages):
                driver.find_element_by_link_text(str(i + 1)).click()
            # 마지막 페이지 크롤링 후 종료
            else:
                break
        print("리뷰 추출이 완료되었습니다.")
        openPath = "./"+selectedBookName
        openPath = os.path.realpath(openPath)
        os.startfile(openPath)
        search = None
        selectNum = None
        status = False
        checkend = True
        savedDir = None
        reviewExist = None
        self.runCheck.emit(checkend) # True 보내면서 종료
        driver.quit()
class Form(QtWidgets.QDialog):
    def __init__(self,parent=None):
        super().__init__()
        self.ui = uic.loadUi("test.ui")
        self.ui.search_btn.clicked.connect(self.searchBook)
        self.ui.quit_btn.clicked.connect(self.quitGUI)
        self.ui.bookList.itemDoubleClicked.connect(self.select_book)
        self.ui.show()
    def quitGUI(self):
        QtWidgets.QMessageBox.about(self, 'Message', '프로그램을 종료합니다')
        exit()
    def searchBook(self):
        global search
        global status
        if status is False:
            status = True
            self.worker = Worker()
            search = self.ui.search_name.text()
            self.worker.finished.connect(self.update_list)
            self.worker.runCheck.connect(self.checkEnd)
            self.worker.reviewCheck.connect(self.checkReview)
            self.worker.start() # 웹 크롤링 시작
    def select_book(self):
        global selectNum
        # QtWidgets.QMessageBox.about(self, 'Message', self.ui.bookList.currentItem().text())
        selectNum = self.ui.bookList.currentRow()+1
        # print(self.ui.bookList.currentRow())
        print(self.ui.bookList.currentItem().text())

    @pyqtSlot(list)
    def update_list(self, data):
        # data에 books에 있는 책 리스트가 넘어옴
        # 만약 책 리스트가 비어있을 시 팝업 출력
        if len(data) == 0:
            QtWidgets.QMessageBox.about(self,'Message','검색 결과 없음, 다시 검색하세요  ')
        # 책 리스트가 있을 시 bookList에 값 추가
        else:
            # 책 이름으로 추가
            for bookName in data:
                self.ui.bookList.addItem(str(bookName))

    # 리뷰 하나끝나면 팝업띄우기
    @pyqtSlot(bool)
    def checkEnd(self,data):
        QtWidgets.QMessageBox.about(self,'Message','리뷰 추출이 완료되었습니다.')
        self.ui.bookList.clear()

    @pyqtSlot(bool)
    def checkReview(self,data):
        if data == False:
            QtWidgets.QMessageBox.about(self,'Message','리뷰가 없습니다. 종료하겠습니다.')
            self.ui.bookList.clear()
if __name__ == '__main__':
    app = QtWidgets.QApplication(sys.argv)
    w = Form()
    sys.exit(app.exec())