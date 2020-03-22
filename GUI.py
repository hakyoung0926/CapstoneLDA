import sys
from PyQt5 import QtWidgets ,uic
import time
# from PyQt5.QtCore import QCoreApplication

class Form(QtWidgets.QDialog):
    def __init__(self,parent=None):
        super().__init__()
        self.ui = uic.loadUi("test.ui")
        self.ui.show()
        self.ui.search_btn.clicked.connect(self.searchBook)
        self.ui.quit_btn.clicked.connect(self.quitGUI)

    def searchBook(self):
        books = ['12314','12515','2111','zzzz']
        for i in books:
            self.ui.bookList.addItem(i)
    def quitGUI(self):
        exit()

if __name__ == '__main__':
    app = QtWidgets.QApplication(sys.argv)
    w = Form()
    sys.exit(app.exec())
