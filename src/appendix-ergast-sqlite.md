# Appendix - Converting the ergast Database to SQLite

This recipe describes how to convert the original MySQL export file of the ergast database to a SQLite3 format.

From the [ergast website download area](http://ergast.com/mrd/db), download the ANSI version of the database. This has all the required options for the conversion script published at [https://gist.github.com/esperlu/943776](https://gist.github.com/esperlu/943776) (archive copy: https://gist.github.com/psychemedia/8519869 ) which reprinted below.

Although we will be using sqlite to query the ergast data, you will need to use MySQL to run the conversion script. You will also need to ensure you have sqlite3 installed.

* Download  the ANSI version of the ergast database export from [http://ergast.com/mrd/db](http://ergast.com/mrd/db)
* Create an empty database in MySQL, for example: *ergast*
* Import the downloaded ergast database export file into the *ergast* database 
* Download the conversion script as *mysql2sqlite.sh*
* In the terminal, *cd* into the folder containing *mysql2sqlite.sh*
* Run the conversion script using a shell (command line) command of the form:

        ./mysql2sqlite -u root ergast | sqlite3 ergastdb.sqlite

You should now have a copy of the ergast database available as the sqlite database *ergastdb.sqlite*.

<<(code/mysql2sqlite.sh)