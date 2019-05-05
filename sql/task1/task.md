-- union [V]

```sql
select  'case points' type,
        count(*) count
    from case_points
        union
select  'result points',
        count(*)
    from result_points;
```
    


-- union all []
```sql
-- TODO ...
```
    

```sql
-- except [ ]
-- TODO ...
select case_id
    from case_points
        except
select count(*) -- ?
    from cases;
```
    

```sql
-- intersect [V]
select point_id
    from case_points
        intersect
select point_id
    from result_points;
```
    

```sql
-- inner join [V]
select  algorithms.system_name algorithm,
        count(results.id) results
    from results
        join algorithms
            on results.algorithm_id = algorithms.id
group by algorithms.system_name;
```
    

```sql
-- left/right join [V]
select  algorithms.system_name algorithm,
        count(results.id) results
    from results
        right join algorithms
            on results.algorithm_id = algorithms.id
group by algorithms.system_name;
```
    

-- left/right join [V]
select  algorithms.system_name algorithm,
        count(results.id) results
    from results
        left join algorithms
            on results.algorithm_id = algorithms.id
group by algorithms.system_name;
```
    

```sql
-- cross join [X]
-- TODO ...
```
    

```sql
-- rollup [V]
select  isnull(algorithms.system_name,
            case
                when grouping(algorithms.system_name) = 1
                then 'Total:'
                else null end
        ) algorithm,
        count(results.id)
    from algorithms
        full join results
            on algorithms.id = results.algorithm_id
group by rollup (algorithms.system_name);
```
    

```sql
-- cube [ ]
```
    

```sql
-- grouping sets [ ]

```




-- update results set
--     algorithm_id = r2.id
--     from results r1
--     cross apply (
--         select top 1 id
--             from algorithms
-- --         where algorithms.id != r1.algorithm_id
--         order by newid()
--     ) r2

--
-- --
-- select  id,
--         minimum_steiner_tree
-- from cases
--     intersect
-- select  id,
--         steiner_tree
-- from results;
--
--
--
-- select count(*)
-- from points;


-- ?
select x, y, count(*) duplicates
from points
group by x, y
having count(*) > 1;

select results.steiner_tree, cases.minimum_steiner_tree, cases.minimum_spanning_tree
from results
    join cases
on results.case_id = cases.id;


