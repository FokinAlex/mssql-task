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
     steiner_tree            numeric (20, 5),
     ms_time                 integer,
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
