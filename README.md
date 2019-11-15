# mongo-importer

> A one-click windows utility tool that:  
- Exports `(mongodump)` a mongodb database in binary format.  
- Imports `(mongorestore)` the exported binary database into a new database. 


### Dependencies

1. **Windows 10 OS 64-bit**

2. **MongoDB**  
Version is not strict but for references, **MongoDB Community Server v4.2.0, OS Windows x86 x64** was used for this tutorial's local installation.    

		   MongoDB shell version v4.2.0
		   git version: a4b751dcf51dd249c5865812b390cfd1c0129c30
		   allocator: tcmalloc
		   modules: none
		   build environment:
		       distmod: 2012plus
		       distarch: x86_64
		       target_arch: x86_64


3. Access to an [mlab](https://mlab.com/) database (or any other mongodb database sources).  

		host: localhost
		port: 27017
		user: tester
		password: tester


20191116