# dataManager

## What this is

hash-based data management system written in MATLAB. 

## The problem

1. you write and share code. But code operates on data, and you want a way to work on the same code independently of where the code is, or where the data is. 
2. data shouldn't change. But it does, because people make mistakes. You don't want your entire analysis pipeline to operate on data that isn't what you think it is. [GIGO](https://en.wikipedia.org/wiki/Garbage_in,_garbage_out). 

## The Solution

1. [hash](https://en.wikipedia.org/wiki/Cryptographic_hash_function)-based data integrity checks
2. your code is agnostic to the **location** of the data, but cares only about **what** the data is. Think of this as [URIs](https://en.wikipedia.org/wiki/Uniform_Resource_Identifier) vs. [URL](https://en.wikipedia.org/wiki/Uniform_Resource_Locator).  

## Installation

The recommended way to install this is to use my package manager:

```matlab
urlwrite('http://srinivas.gs/install.m','install.m'); 
install data-manager
install srinivas.gs_mtools  
```

Alternatively, you can clone this using `git`:

```bash
git clone https://github.com/sg-s/data-manager
git clone https://github.com/sg-s/srinivas.gs_mtools
```

Don't forget to fix your MATLAB paths so that it points to the correct folders. 

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

Clean up entries in the hash table that no longer resolve to files.

```matlab
dm.cleanup
``

# License 

data-manager is [free software](https://fsf.org/). 
[GPL v3](https://www.gnu.org/licenses/gpl-3.0.txt)
