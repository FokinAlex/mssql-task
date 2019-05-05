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

insert into cases (minimum_spanning_tree, minimum_steiner_tree, count_of_points)
values (0, 0, 0);

select * from algorithms;

update results
    set algorithm_id = 4
    where algorithm_id = 5;

drop function getBestAlgorithmForCaseById;
drop function getEachAlgorithmAverageSteinerTreesForCaseById;
drop trigger update_count_of_case_points_trigger;
drop trigger update_results_trigger;
drop function check_points;
close check_points_cursor;
deallocate check_points_cursor;

drop procedure CLR;
drop assembly CLR;

