# mongo-importex

> A one-click windows utility tool that:  
>
> - Exports `(mongodump)` a mongodb database in binary format.
> - Imports `(mongorestore)` the exported binary database into a new database.
> - Drops a specified localhost database.

### Table of Contents

- [Dependencies](#dependencies)
- [Content](#content)
- [Usage and Installation](#usage-and-installation)
- [Troubleshooting](#troubleshooting)



### Dependencies

1. **Windows 10 OS 64-bit**

2. **MongoDB**  
Version is not strict, but for reference, the project used **MongoDB Community Server v4.2.0, OS Windows x86 x64** for its INITIAL local installation in 2019. Its shell must be available globally from the command line.

		MongoDB shell version v4.2.0
		git version: a4b751dcf51dd249c5865812b390cfd1c0129c30
		allocator: tcmalloc
		modules: none
		build environment:
		  distmod: 2012plus
		  distarch: x86_64
		  target_arch: x86_64

	The project used **MongoDB Community Server v7.0.3, OS Windows x86 x64**, available on [the link](https://www.mongodb.com/try/download/community) for its LATEST local installation in 2023. This MongoDB version requires a separate installation of the MongoDB Shell and the MongoDB Database Tools (mongodump, mongorestore, etc). Its shell and tools must be available globally from the command line.

		MongoDB (mongod) version v7.0.3
		git version: b96efb7e0cf6134d5938de8a94c37cec3f22cff4
		allocator: tcmalloc
		modules: none
		build environment:
			distmod: windows
			distarch: x86_64
			target_arch: x86_64

	**MongoDB Shell** [[link]](https://www.mongodb.com/try/download/shell)

		MongoDB Shell v2.0.2
		Platform: Windows x64 (10+)
		Package: msi

	**MongoDB Command Line Database Tools** (MongoDB Database Tools) [[link]](https://www.mongodb.com/try/download/database-tools)

		MongoDB Database Tools v100.9.3
		Platform: Windows x86_64
		Package: msi

3. Access to an [Atlas](https://www.mongodb.com/atlas) database (or any other mongodb database sources).  

		host: localhost
		port: 27017
		user: tester
		password: tester
		mongo shell: 
		- mongo (for MongoDB v4.2.0 or lower versions)
		- mongosh (for MongoDB v4.4.0 or higher versions)


## Content

1. **main.bat**  
Windows batch script to automate switching of MongoDB database credentials for a faster database export `(mongodump)`, import `(mongorestore)` and database drop process.


## Usage and Installation

1. Clone this repository.  
`git clone https://github.com/weaponsforge/mongo-importex.git`

2. Click to run **main.bat**.

3. The **MONGODB CONNECTION CREDENTIALS SETUP** screen will appear on the script's first run. Select the following options to encode the following required fields:  

	| NO. | Prompt | Description |
	|---|---|---|
	| 1 | Enter database host | MongoDB host name |
	| 2 | Enter database name | MongoDB database name |
	| 3 | Database port | MongoDB port number name. Uses 27017 by default. |
	| 4 | Enter user name | MongoDB user name |
	| 5 | Enter password | MongoDB user password |
	| 6 | Enter mongo shell | The available and active MongoDB shell. Choose:<br> - `mongo` (for MongoDB v4.2.0 or lower versions) <br>- `mongosh` (for MongoDB v4.4.0 or higher versions)|
	| 7 | Save | Saves the encoded database credentials for future use to a `.env` file and exit to the main screen. |
	| 8 | Save and Export Database | Saves the mongodb settings to a `.env` file and starts the **Export Database** process. |
	| 9 | Save and Import Database | Saves the mongodb settings to a `.env` file and starts to the **Import Database** process. |
	| 10 | Export Database | Exports (`mongodump`) the database defined in the MongoDB Connection Credentials Setup to a database in binary JSON format.<br> - **NOTE:** Choosing this option will NOT save recent updates made to the database credentials.<br>- Type `"Y"` and press ENTER if you want to use the `"mongo+srv://"` SRV Connection String.<br>- Type `"n"` and press ENTER if you want to use the `"mongo://"` Standard Connection String. |
	| 11 | Import Database | Imports (`mongorestore`) a binary database to the database defined in the MongoDB Connection Credentials settings.<br>It expects to find binary database contents in subdirectories relative to the script, similar to the output of the **[10] Export Database option**.<br>- **NOTE:** Choosing this option will NOT save recent updates made to the database credentials.<br>- Type `"Y"` and press ENTER if you want to use the `"mongo+srv://"` SRV Connection String.<br>- Type `"n"` and press ENTER if you want to use the `"mongo://"` Standard Connection String. |
	| x | Exit | Exit the script. |

4. The **VIEWING THE [ACTIVE] MONGODB CONNECTION CREDENTIALS** screen provides quick links for database import, export, drop, and database credentials updating, which will be accessible after saving the initial database credentials required from the **MONGODB CONNECTION CREDENTIALS SETUP**.<br>

	The **Export Database**, **Import Database**, and **List Databases** options will prompt selecting the `"mongo+srv://"` SRV Connection String. Type `"Y"` or `"n"` and press ENTER when prompted.
	- Type `"Y"` and press ENTER if you want to use the `"mongo+srv://"` SRV Connection String.
	- Type `"n"` and press ENTER if you want to use the `"mongo://"` Standard Connection String.

	| NO. | Prompt | Description |
	|---|---|---|
	| 1 | Export Database | Exports (`mongodump`) the database defined in the MongoDB Connection Credentials Setup to a binary JSON format database. |
	| 2 | Import Database | Imports (`mongorestore`) the database defined in the MongoDB Connection Credentials settings to a local binary JSON format database relative to the script's location |
	| 3 | Drop Database | It deletes a database defined in the MongoDB connection credentials. Currently available only for localhost MongoDB. |
	| 4 | List Databases | Lists the available databases from the defined MongoDB connection credentials. |
	| 5 | List Local Databases | Lists the available localhost databases. |
	| 6 | Create Local Database and User | Creates a local database and a local user and password associated with the local database.<br>It also creates an empty collection using the database name with a `"_"` prefix i.e., `"_mydatabase"` |
	| 7 | Update Connection Credentials | Displays the **MONGODB CONNECTION CREDENTIALS SETUP** screen for editing the stored database connection details. |
	| 8 | Reset | Resets the database conection details |
	| x | Exit | Exit the script. |


## Troubleshooting

1. This script expects to access properly configured MonogoDB databases with existing users and passwords.
2. The script expects a properly set up and configured MongoDB installation.
   - The `"mongod,"` `"mongodump,"` `"mongorestore,"` `"mongosh"` (for MongoDB v4.4 or later versions), and `"mongo"` (for MongoDB v4.2 or earlier versions) MongoDB shell commands should be globally accessible from the command prompt.
2. If the **Export Database** process takes too long to finish:
   - Terminate and re-run the script.
   - Re-check if the correct database credentials are available in the **MONGODB CONNECTION CREDENTIALS SETUP** screen.


20191116