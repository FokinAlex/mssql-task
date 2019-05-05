# `mssql-task`

## Contains

Repository contains:
- [X] [Getting started](#Getting-started)
    - [X] [Getting MS SQL](#getting-ms-sql)
    - [X] [Creating database](#creating-database)
    - [X] [Creating tables](#creating-tables)
- [X] [Task 1](#task-1)
- [X] [Task 2](#task-2)
- [X] [Task 3](#task-3)

## Getting started

### Getting MS SQL

1\. Pulling docker image:

```text
docker pull mcr.microsoft.com/mssql/server:2017-latest
```

2\. Running docker container:

```text
docker run -e 'ACCEPT_EULA=Y' \
           -e 'SA_PASSWORD=<YourStrong!Passw0rd>' \
           -p 1433:1433 \
           -d mcr.microsoft.com/mssql/server:2017-latest \
           --name mssql-server 
```

3\. Connecting to `mssql-server`:

```text
datasource:
    mssql-server:
        url: jdbc:sqlserver://localhost:1433
        username: SA
        password: <YourStrong!Passw0rd>
```

### Creating database

Creating database `steinerdb` with two file groups `major` and `minor`:

```sql
create database [steinerdb]
on primary
    (name = 'f1', filename = '/usr/src/steinerdb/major/sdb_1.mdf', size = 10Mb, maxsize = unlimited, filegrowth = 5Mb),
    (name = 'f2', filename = '/usr/src/steinerdb/major/sdb_2.ndf', size = 10Mb, maxsize = 100mb, filegrowth = 5Mb),
filegroup minor
    (name = 'f3', filename = '/usr/src/steinerdb/minor/sdb_2.ndf', size = 10Mb, maxsize = 100mb, filegrowth = 5Mb),
    (name = 'f4', filename = '/usr/src/steinerdb/minor/sdb_3.ndf', size = 10Mb, maxsize = 100mb, filegrowth = 5Mb),
    (name = 'f5', filename = '/usr/src/steinerdb/minor/sdb_4.ndf', size = 10Mb, maxsize = 100mb, filegrowth = 5Mb)
log on
    (name = 'lf1', filename = '/usr/src/steinerdb/major/log_1.ldf', size = 10Mb, maxsize = 100mb, filegrowth = 5Mb),
    (name = 'lf2', filename = '/usr/src/steinerdb/minor/log_2.ldf', size = 10Mb, maxsize = 100mb, filegrowth = 5Mb);
```

`ls -Rlh` for `/usr/src/steinerdb` returns:

```text
.:
total 8.0K
drwxr-xr-x 2 root root 4.0K Apr 27 09:59 major
drwxr-xr-x 2 root root 4.0K Apr 27 09:59 minor

./major:
total 31M
-rw-r----- 1 root root 10M Apr 27 09:59 log_1.ldf
-rw-r----- 1 root root 10M Apr 27 09:59 sdb_1.mdf
-rw-r----- 1 root root 10M Apr 27 09:59 sdb_2.ndf

./minor:
total 40M
-rw-r----- 1 root root 10M Apr 27 09:59 log_2.ldf
-rw-r----- 1 root root 10M Apr 27 09:59 sdb_2.ndf
-rw-r----- 1 root root 10M Apr 27 09:59 sdb_3.ndf
-rw-r----- 1 root root 10M Apr 27 09:59 sdb_4.ndf
```

### Creating tables

Database structure:

![Database diagram][diagram]

Creating tables:

```sql
create table algorithms (
    id                      integer identity primary key,
    system_name             varchar (10),
    description             varchar (255)
);

create table cases (
    id                      integer identity primary key,
    minimum_spanning_tree   numeric (20, 5),
    minimum_steiner_tree    numeric (20, 5),
    count_of_points         numeric (3)
);

create table results (
     id                      integer identity primary key,
     case_id                 integer,
     algorithm_id            integer,
     steiner_tree            numeric (20, 5)
     constraint results_case_fk      foreign key (case_id)      references cases (id),
     constraint results_algorithm_fk foreign key (algorithm_id) references algorithms (id)
);

create table points (
    id                      integer identity primary key,
    x                       numeric (20, 5),
    y                       numeric (20, 5)
);

create table case_points (
    point_id                integer unique identity,
    case_id                 integer,
    constraint case_points_point_fk foreign key (point_id) references points (id),
    constraint case_points_case_fk  foreign key (case_id)  references cases (id)
);

create table result_points (
     point_id               integer unique identity,
     result_id              integer,
     constraint result_points_point_fk  foreign key (point_id)  references points (id),
     constraint result_points_result_fk foreign key (result_id) references results (id)
);
```

For inserts see [resources/sql/inserts][inserts]

**Note:** Use `set identity_insert` for inserts with ids

```sql
set identity_insert %table_name% on;

-- inserts

set identity_insert %table_name% off;
```

## [Task #1][task1]

Contains:
- Set theory
- Joins
- Groupings
- Ranking functions
- Analytic functions
- Pivot / unpivot
- Applies

## [Task #2][task2]

Contains:
- Functions
- Stored procedure
- Triggers
- Cursor

## [Task #3][task3]

Contains:
- CLR stored procedure

[diagram]: https://github.com/FokinAlex/mssql-task/blob/master/resources/steinerdb.png?raw=true
[task1]:   https://github.com/FokinAlex/mssql-task/blob/master/tasks/task1.md
[task2]:   https://github.com/FokinAlex/mssql-task/blob/master/tasks/task2.md
[task3]:   https://github.com/FokinAlex/mssql-task/blob/master/tasks/task3.md
[inserts]: https://github.com/FokinAlex/mssql-task/blob/master/resources/sql/inserts
