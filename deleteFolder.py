import shutil

def removeFolder(foldername):
    shutil.rmtree(foldername, ignore_errors=True)
