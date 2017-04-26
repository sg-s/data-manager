class DataManager(dict):
	"""hash-based data manager"""
	def __init__(self):
		self.version_number = "0.0.15"
		self.readDMIgnore()

	def readDMIgnore(self):
		"""reads the dmignore file to determine what file patterns to ignore"""
		with open('dmignore.m') as f:
			content = f.readlines()
		content = [x.strip() for x in content]
		content = [i for i in content if not i.find('%') > -1 and len(i) > 0]
		self.ignore_these = content