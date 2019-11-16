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

4. Press **[6] - Save** to save the previously encoded database credentials for future use and exit to the main screen.

5. Press **[7] Save and Export Database** to save the previously encoded database credentials for future use and start database export `(mongodump)`.

6. If you already have exported binary databases directories saved in this project's root directory, press **[8] - Save and Import Database** to save the previously encoded database credentials for future use, and to start the  database import `(mongorestore)` of the binary database which you will get to select on the resulting **AVAILABLE DATABASES TO IMPORT** screen.


7. Press **[9] Export Database** to start the database export process using the credentials that have been previously encoded.
	> **NOTE:** Any updates made to the database credentials will NOT be saved if this option is chosen.

8. Press **[10] Import Database** to  select a binary database to import from the **AVAILABLE DATABASES TO IMPORT** screen. A list of exported binary database directories will be listed.
	> **NOTE:** Any updates made to the database credentials will NOT be saved if this option is chosen.
	- Enter the name of the database you want to import, or
	- Press **"x"** to exit.

9. Wait for the database export `(mongodump)` or import `(mongorestore)` process to finish.

10. Quick links for database import, export and database connection updating are available in the **VIEWING THE [ACTIVE] MONGODB CONNECTION CREDENTIALS** screen, which will be accessible after saving the initial database credentials required from **# 3**.
	- **[1] - Export Database**
	- **[2] - Import Database**
	- **[3] - Update Connection Credentials**
	- **[4] - Reset**
	- **[x] - Exit**



## Troubleshooting

1. MonogoDB databases that are to be accessed using this tool are expected to have been properly set-up with users and passwords.

2. If the **export database** process takes too long to finish, close this tool and re-check if the database credentials haven been encoded properly. 


20191116