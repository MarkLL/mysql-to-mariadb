# MySQL to MariaDB
Windows batch scripts to export All MySQL Databases and Users and import into MariaDB (or other MySQL version)

## Introduction
My fist introduction to MySQL was when I installed [WampServer](http://www.wampserver.com/en/) on my Windows XP development machine several years ago.
At that time it was MySQL version 5.0.45 and I found it really easy, using PhpMyAdmin, just to utilise the "create a new User and a Database with the same name" option for each of my projects.
Sure it may of been a bit lazy, but it worked. 

Over the years I ended up accumulating 60+ databases and their associated user. 
Even when I upgraded my version of WampServer I still kept the same database as it seemed "too hard" to migrate everything to the later version of MySQL (5.6.12).
I simply moved the old version into the correct location and kept using it.

Recently I decided it was time to upgrade and check out what the newer versions have to offer. 
In doing my research I discovered that quite a few people were not happy with the memory usage of the later MySQL versions and there seemed to be a general recommendation to try [MariaDB](https://mariadb.org/).

The 2 scripts that I created enabled me to export all my databases, users and their permissions from MySQL and import them into MariaDB ... and I discovered a few things along the way.

## Usage
### Assumptions

So lets start with some assumptions.

1. You are running Windows (7,8,8.1,10) - sorry but if you are still running Windows XP (32 bit) this is not going to work for you
2. You have an existing MySQL installation with a number of databases and users defined
3. You are running WampServer 2.4 or later
4. I installed WampServer to **`D:\wamp`** so change this out, below, to suit your particular situation

**Disclaimer**: I have heavily modified the default WampServer v2.4 for my own purposes, but I'm pretty sure this will work on the standard edition.

### Downloading the Latest Stable release
1. Head over to the MariaDB site and [download the latest Stable version](https://downloads.mariadb.org/mariadb/10.1.14/) (10.1.14 as at the time this is written)
2. Make sure you pick the ZIP file **Package Type** for the Windows x86_64 **OS / CPU**. Do **not** use the msi installer!
3. Extract the contents of the Zip file into a **temporary location**. We will move it to the correct location as we progress.

### Setting up on WampServer

**Make sure you WampServer is running**

If you look in `D:\wamp\bin\mysql` you should find a folder with your current version of MySQL, for WampServer v2.4 it was version v5.6.12 stored in the `mysql5.6.12` folder.

Now perform the following tasks.

1. Create a folder for the new version ensuring the correct name. For version 10.1.14, it should be `mysql10.1.14`.

2. Copy the MariadDB contents from the temporary folder (Step 3 above) into this new folder.
Make sure that the *bin*, *data*, *lib* and *share* folders are directly under the `mysql10.1.14` folder.  
**Note:** you do not need to copy the *include*, *mysql-test* and *sql-bench* folders if you want to save space.  

3. Copy the `my.ini` and `wampserver.conf` files from the `mysql5.6.12` folder and paste into the new `mysql10.1.14` folder.

4. Now you need to edit `my.ini` with your favourite text editor and modify the `basedir`, `log-error` and `datadir` entries. 
You should just need to change the version number to point to the new locations.

5. Because MariaDB is compatible with MySQL there is no need to modify `wampserver.conf`. 

### Exporting your existing data
With your current MySQL server running perform the following steps.

1. Save the 2 batch scripts (`exportAllDbs.cmd` and `importAllDbs.cmd`) into the new `mysql10.1.14` folder.
2. Open a `Command Prompt` window and change directory to the new location. e.g. `cd /d d:\wamp\bin\mysql\mysql10.1.14`
3. Run the Export script and ensure you pass the root password as the only parameter e.g. `exportAllDbs.cmd rootPassword`

That's it... you have now exported all you databases and users to the `dump` folder. Simple wasn't it :smile:

### Importing the exported data
Once you have run the Export command, you should now find a `dump` folder that contains .sql files for each of your databases.
In addition there will be a `allUsers.sql` file in the current folder.

Now comes the tricky bit... First you need to stop the currently running MySQL instance. You can use any of the following methods to achieve this.

1. Use the WampServer utility to stop the MySQL service.
2. Use Task Manager's Service Tab to stop the service
3. Use the Administrative Tools/Service applet to stop the service.
4. From an *Admin* Command Prompt use `net stop wampmysqld`

Now that the current SQL service is stopped, we need to start the new mysqld.exe (MySQL daemon). 
We will achieve this by running the service manually so we can test everything first.

First though we need to make a quick change to the my.ini file.

If you have copied the my.ini file as instructed you should see the WampServer configuration section has all its settings, for the existing mysqld daemon, under the section called `wampmysqld`.

Change the file so it looks like the following:

```
#[;wampmysqld]
[mysqld]
```

This enables `mysqld.exe` to use the correct settings when run from the command line. To ensure your changes work as expected run the following command:

```
bin\mysqld.exe --print-defaults
```

The following is the output you are looking for:

```
bin\mysqld.exe would have been started with the following arguments:
--port=3306 --socket=/tmp/mysql.sock --skip-external-locking --key_buffer_size=16M --max_allowed_packet=1M --table_open_cache=64 --sort_buffer_size=512K --net_buffer_length=8K --read_buffer_size=256K --read_rnd_buffer_size=512K --myisam_sort_buffer_size=8M --basedir=D:/wamp/bin/mysql/mysql10.1.14 --log-error=D:/wamp/logs/mariadb.log --datadir=D:/wamp/bin/mysql/mysql10.1.14/data --tmpdir=D:/wamp/tmp/sql --log-bin=mysql-bin --binlog_format=mixed --server-id=1 --port=3306
```

If you only see `bin\mysqld.exe would have been started with the following arguments: --port=3306` then the section in my.ini is not set correctly.

Once you are happy that the correct settings are being used, you should start the Server with the following command: 

```
bin\mysqld.exe
```

Once the server has started you will need a second `Command Prompt` window and change directory to the same location. e.g. `cd /d d:\wamp\bin\mysql\mysql10.1.14`

Now run the second script to import the databases.

```
importAllDbs.cmd
```

Once the script has completed, you should run the following command to shut down the mysql daemon.

```
bin\mysqladmin.exe --user=root --password=rootPassword shutdown
```

**Note 1:** Don't forget to substitute `rootPassword` with your real root password!  

## Finishing off
You have now imported all you databases and user information into the new database server, so lets get it working with WampServer.

First you need to edit the `my.ini` file and re-instate the service name as the ini section. e.g.

```
[wampmysqld]
#[;mysqld]
```

1. Now right click on the WampServer icon and click *Refresh*.
This will update the configuration of your system and once complete you should now find a new version listed. 
2. Click on the new version (10.1.14) to swap to the new server.


## What if it does not work?
If you have issues, the first thing is to select the previous version of the MySQL server and make sure that still works.

If you have followed these instructions correctly you can always remove the databases from the new installation and start again making sure you correct the cause of your issues.

### Deleting the Data directory
**I can't stress enough that you need to make sure you do not delete the wrong data folder!**

1. Move into the MariaDB data directory (e.g. `cd /d d:\wamp\bin\mysql\mysql10.1.14\data`)
2. delete *all* the contents in this folder (e.g. `rd /s /q .` - that command will remove *everything* from the current folder.)
3. Copy the contents of the data folder you saved in the **_temporary location_** when you extracted the zip file. You now have a Blank data set.
4. Make what ever changes you need to make
5. Run the Import script again.


## What I discovered (aka Tips and Traps).
1. The default root password for a fresh install of MariaDB is blank - e.g. there is no password!
2. After importing all you databases and uses, the root password will be the same as it was in your previous install
3. The underscore character, when used as part of a database name, *may* cause issues on older version of MySQL. The Export script attempts to work around this issue.

### Useful commands
To Print out the current setting use the following command:

```
bin\my_print_defaults.exe --defaults-file=my.ini wampmysqld
```

See what the default settings are for the mysql daemon:

`
bin\mysqld.exe --print-defaults
`

If you have issues or feedback create an [issue](https://github.com/MarkLL/mysql-to-mariadb/issues) so we know about it.

Enjoy,  
MarkLL