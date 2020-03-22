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
class Worker(QThread):
    finished = pyqtSignal(list)
    def run(self):
        global search
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
        except NoSuchElementException:
            print("검색하시려는 책이 없습니다. 종료합니다")
            self.finished.emit(books)
            driver.quit()
            exit()

class Form(QtWidgets.QDialog):
    def __init__(self,parent=None):
        super().__init__()
        self.ui = uic.loadUi("test.ui")
        self.ui.show()
        self.ui.search_btn.clicked.connect(self.searchBook)
        self.ui.quit_btn.clicked.connect(self.quitGUI)
    def quitGUI(self):
        exit()
    def searchBook(self):
        global search
        search = self.ui.search_name.text()
        self.worker = Worker()
        self.worker.finished.connect(self.update_number)
        self.worker.start()
    @pyqtSlot(list)
    def update_number(self, data):
        for i in data:
            self.ui.bookList.addItem(str(i))

if __name__ == '__main__':
    app = QtWidgets.QApplication(sys.argv)
    w = Form()
    sys.exit(app.exec())