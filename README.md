# mongo-importex

> A one-click windows utility tool that:  
- Exports `(mongodump)` a mongodb database in binary format.  
- Imports `(mongorestore)` the exported binary database into a new database. 


### Dependencies

1. **Windows 10 OS 64-bit**

2. **MongoDB**  
Version is not strict but for references, **MongoDB Community Server v4.2.0, OS Windows x86 x64** was used for this project's local installation.    

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



## Content

1. **main.bat**  
Windows batch script to automate switching of MongoDB database credentials for a faster database import `(mongodump)` process.



## Usage

1. Clone this repository.  
`git clone https://github.com/weaponsforge/mongo-importex.git`

2. Click to run **main.bat**.

3. The **MONGODB CONNECTION CREDENTIALS SETUP** screen will appear on the script's first-time run. Select the following options to encode the following required fields:  
	- **[1]** - database host name
	- **[2]** - database name
	- **[3]** - database user
	- **[4]** - database user's password

4. Press **[6] Save and Export Database** to save the previously encoded database credentials for future use. The database export process will proceed soon after.

5. Press **[7] Export Database** to start the database export process using the credentials that have been previously encoded.
	> **NOTE:** Any updates made to the database credentials will NOT be saved if this option is chosen.

6. Wait for the database export `(mongodump)` process to finish.



## Troubleshooting

1. MonogoDB databases that are to be accessed using this tool are expected to have been properly set-up with users and passwords.

2. If the **export database** process takes too long to finish, close this tool and re-check if the database credentials haven been encoded properly. 


20191116