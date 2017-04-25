class DataManager(dict):                
    "store file hash info"
    def __init__(self, filename=None):
        self["name"] = filename