use master;
drop database steinerdb;
drop table result_points;
drop table case_points;
drop table points;
drop table results;
drop table cases;
drop table algorithms;
use steinerdb;

set identity_insert algorithms on;
set identity_insert algorithms off;
set identity_insert cases on;
set identity_insert cases off;
set identity_insert results on;
set identity_insert results off;
set identity_insert points on;
set identity_insert points off;
set identity_insert case_points on;
set identity_insert case_points off;
set identity_insert result_points on;
set identity_insert result_points off;

select count(*) from algorithms;
select count(*) from cases;
select count(*) from results;
select count(*) from result_points;
select count(*) from case_points;
select count(*) from points;

update results
    set algorithm_id = 1
    where id % 5 = 0;

update results
    set steiner_tree = steiner_tree + 0.6
    where id % 17 = 0;

insert into algorithms (system_name, description)
values ('Test', 'Test Algorithm - without any results');

insert into results (case_id, algorithm_id, steiner_tree, ms_time)
values (1, null, 0.1337, null);
