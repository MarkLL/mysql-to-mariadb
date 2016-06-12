# MySQL to MariaDB
Windows batch scripts to export All MySQL databases and Users and Import into MariaDB (or other MySQL version)

## Introduction
My fist introduction to MySQL was when I installing WAMP Server on my Windows XP development machine several years ago. At the time it was version 5.0.45. At the time I found it really easy using PhpMyAdmin just to use the Create User and a Table for that user and grant all permissions. Sure it was maybe a bit lazy, but it worked. 

Over the years I ended up accumulating 60+ databses and their associated users. Even when I upgraded my version of WAMP I still kept the same database as it seemed "too hard" to migrate it to the later version of MySQL (5.6.12) so I left it at that.

Recently I decided it was time to upgrade and check out what the newer versions have to offer. In doing my research I discovered that quite a few people were not happy with the memory usage of the later MySQL versions and there seemed to be a general recommendation to try MariaDB.

The 2 scripts that I created enabled me to export all my databases, users and their permissions from the MySQL databse into the MariaDB and I discovered a few things along the way.
