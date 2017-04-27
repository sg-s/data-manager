# dataManager

## What this is

hash-based data management system. `MATLAB` and `python` offerings available.

## The problem

1. You write and share code. But code operates on data, and you want a way to work on the same code independently of where the code is, or where the data is. 
2. Data shouldn't change. But it does, because people make mistakes. Hard drives fail. You don't want your entire analysis pipeline to operate on data that isn't what you think it is. [GIGO](https://en.wikipedia.org/wiki/Garbage_in,_garbage_out). 

## The Solution

1. [hash](https://en.wikipedia.org/wiki/Cryptographic_hash_function)-based data integrity checks
2. your code is agnostic to the **location** of the data, but cares only about **what** the data is. Think of this as [URIs](https://en.wikipedia.org/wiki/Uniform_Resource_Identifier) vs. [URL](https://en.wikipedia.org/wiki/Uniform_Resource_Locator).  

This is inspired by how [magnet links](https://en.wikipedia.org/wiki/Magnet_URI_scheme) work. 

## Differences between MATLAB and python implementations

|   |MATLAB        | Python |
| -----  |-------       | ----------- |
|  Status |feature-complete	    | WIP | 
|  Location |hash table stored in `hash_table.mat` | hash table stored in `hash_table.pkl` |
| Tech  |uses MATLAB arrays    | uses python dictionaries | 
| Hashing  |uses system `md5` or `dataHash.m`| uses `hashlib` |

## Installation (MATLAB)

The recommended way to install this is to use my package manager:

```matlab
urlwrite('http://srinivas.gs/install.m','install.m'); 
install sg-s/data-manager
install sg-s/srinivas.gs_mtools  
```

Alternatively, you can clone this using `git`:

```bash
git clone https://github.com/sg-s/data-manager
git clone https://github.com/sg-s/srinivas.gs_mtools
```

Don't forget to fix your MATLAB paths so that it points to the correct folders. 

## Usage (MATLAB)

First, generate a dataManager object:

```matlab
dm = dataManager;
```

Scan the current folder for all data files and determine their hashes:

```matlab
dm.rehash;
```

Scan a specific folder and add all the data there to the hash table:

```matlab
dm.rehash('/path/to/folder/with/data/')
```

View all hashes and paths stored in the hash table, sorted by when they were last accessed:

```matlab
dm.view
```

View all hashes and paths stored in the hash table, sorted by path name:

```matlab
dm.view('','name')
```

View only hashes corresponding to paths that contain a specific string, and sorted by when they were last accessed:

```matlab
dm.view('bicameral-mind','la')
```

Retrieve the path corresponding to a particular hash:

```matlab
path_name = dm.getPath(hash);
```

Clean up entries in the hash table that no longer resolve to files.

```matlab
dm.cleanup
```

View all methods of `dataManager`:

```matlab
methods(dataManager)
```

View interactive help:
```matlab
dataManager
```

dataManager also uses a file called `dmignore.m` which lists file name patterns that it should ignore. You can add to `dmignore.m` to suit your needs. 

## Usage (python)

First, import the module:

```python
from DataManager import DataManager 
dm = DataManager()
```

Scan the current folder for all data files and determine their hashes:

```python
dm.rehash()
```

Scan a specific folder and add all the data there to the hash table:

```python
dm.rehash('/path/to/folder/with/data/')
```

Retrieve the path corresponding to a particular hash:

```python
path_name = dm[hash]
```

View all hashes and paths stored in the hash table, sorted by path name:

```python
dm.view()
```



# License 

data-manager is [free software](https://fsf.org/). 
[GPL v3](https://www.gnu.org/licenses/gpl-3.0.txt)
