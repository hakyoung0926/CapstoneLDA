import sys
from PyQt5 import QtWidgets ,uic
from PyQt5.QtCore import *
import time
# from PyQt5.QtCore import QCoreApplication
class Worker(QThread):
    #finished = pyqtSignal(int)
    finished = pyqtSignal(list)
    def run(self):
        nmli =[]
        i = 1
        while True:
            print("Thread 실행중"+str(i))
            nmli.append(i)
            # self.finished.emit(i)
            i+=1
            self.sleep(1)
            if i>10:
                break
        self.finished.emit(nmli)

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
        self.worker = Worker()
        self.worker.finished.connect(self.update_number)
        self.worker.start()
        books = ['12314','12515','2111','zzzz']
        for i in books:
            self.ui.bookList.addItem(i)
    @pyqtSlot(list)
    def update_number(self,data):
        for i in data:
            self.ui.bookList.addItem(str(i))



if __name__ == '__main__':
    app = QtWidgets.QApplication(sys.argv)
    w = Form()
    sys.exit(app.exec())
