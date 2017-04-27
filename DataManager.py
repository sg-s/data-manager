import os
import pickle
import hashlib
from functools import partial

class DataManager(dict):
	"""hash-based data manager"""
	def __init__(self):
		self.version_number = "0.0.22"
		temp = self.loadDict()
		for key in temp.keys():
			self[key] = temp[key]

	def view(self):
		"""view hash table"""
		sorted_keys = sorted(self, key=self.get)
		for key in sorted_keys:
			print(key + "   " + self[key])

	def readDMIgnore(self):
		"""reads the dmignore file to determine what file patterns to ignore"""
		with open('dmignore.m') as f:
			content = f.readlines()
		content = [x.strip() for x in content]
		content = [i for i in content if not i.find('%') > -1 and len(i) > 0]
		self.ignore_these = content

	def loadDict(self):
		"""loads the dict from file. if none exists, create it """

		# check if hash table exists
		hash_table_path = os.path.join(os.path.dirname(os.path.realpath(__file__)),'hash_table.pkl')
		if os.path.isfile(hash_table_path):
			with open(hash_table_path, 'rb') as f:
				temp = pickle.load(f)
			return temp

	def rehash(self,path_name=''):
		"""computes hashes for all files in specified folder, and adds to hash table"""
		if len(path_name) == 0:
			path_name = os.getcwd()
		assert (os.path.exists(path_name)), "Path does not exist!"
		
		# get all files in this path 
		all_files = []
		for path, subdirs, files in os.walk(path_name):
			for name in files:
				if (name[0] is not "."):
					all_files.append(os.path.join(path, name))

		# ignore files that match .dmignore 

		# for each file, hash it 
		for i in range(len(all_files)):
			self[self.md5sum(all_files[i])] = all_files[i]

		# save this
		self.saveHashTable()

	def saveHashTable(self):
		hash_table_path = os.path.join(os.path.dirname(os.path.realpath(__file__)),'hash_table.pkl')
		print(hash_table_path)
		with open(hash_table_path, 'wb') as f:
			pickle.dump(self, f, pickle.HIGHEST_PROTOCOL)

	def md5sum(self,filename):
		BUF_SIZE = 65536  # lets read stuff in 64kb chunks!
		md5 = hashlib.md5()
		with open(filename, 'rb') as f:
			while True:
				data = f.read(BUF_SIZE)
				if not data:
					break
				md5.update(data)
		return md5.hexdigest()

