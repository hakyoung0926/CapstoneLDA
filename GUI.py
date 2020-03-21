import sys
from PyQt5 import QtWidgets ,uic
import time
# from PyQt5.QtCore import QCoreApplication

class Form(QtWidgets.QDialog):
    def __init__(self,parent=None):
        super().__init__()
        self.ui = uic.loadUi("test.ui")
        self.ui.show()
        self.ui.search_btn.clicked.connect(self.showBook)
        # self.ui.quit_btn.clicked.connect(QCoreApplication.instance().quit)
        self.ui.quit_btn.clicked.connect(self.quitGUI)
    def showBook(self):
        books = ['12314','12515','2111','zzzz']
        # bookname = self.ui.search_name.text()
        # self.ui.bookList.addItem(bookname) #리스트에 추가
        time.sleep(10)
        for i in books:
            self.ui.bookList.addItem(i)
        # print(bookname)

    def quitGUI(self):
        exit()

if __name__ == '__main__':
    app = QtWidgets.QApplication(sys.argv)
    w = Form()
    sys.exit(app.exec())
