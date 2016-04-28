# dataManager

## What this is

hash-based data management system written in MATLAB. 

## Why you should use this:

1. share code and data easier: you don't have to worry about where the data is
2. ensure reproducible document builds. You want to have the same code run on the same data to generate the same document. 

## Installation

The reccomended way to install this is to use my package manager:

```matlab
urlwrite('http://srinivas.gs/install.m','install.m'); 
install data-manager
install srinivas.gs_mtools  
```

## Usage

First, generate a dataManager object:

```matlab
dm = dataManager;
```

Scan the current folder for all data files and determine their hashes:

```matlab
dm.rehash;
```

Scan a folder and add all the data there to the hash table:

```matlab
dm.reshash('/path/to/data/')
```

View all hashes and paths stored in the hash table:

```matlab
dm.view
```

Show the hash of a particular folder or a file:

```matlab
hash = dm.getHash('path/to/file.mat');
hash = dm.getHash('path/to/folder');
```

Retrieve the path corresponding to a particular hash:

```matlab
path_name = dm.getPath(hash);
```

# License 

[GPL v2](http://choosealicense.com/licenses/gpl-2.0/#)
