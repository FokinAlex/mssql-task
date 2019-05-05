# [:back:][readme]

# Task #1

## Contains

Task contains:
- [Set theory](#set-theory):
    - [X] [`union`](#union)
    - [ ] [`union all`](#union-all)
    - [X] [`except`](#except)
    - [X] [`intersect`](#intersect)
- [Joins](#joins):
    - [X] [`inner join`](#inner-join)
    - [X] [`left join`](#left-join)
    - [X] [`right join`](#right-join)
    - [X] [`full join`](#full-join)
    - [X] [`cross join`](#cross-join)
    - [ ] [`self join`](#self-join)
    - [ ] [`natural join`](#natural-join)
- [Groupings](#groupings):
    - [X] [`rollup`](#rollup)
    - [X] [`cube`](#cube)
    - [X] [`grouping sets`](#grouping-sets)
    - [X] [`grouping`](#grouping)
- [Ranking functions](#ranking-functions):
    - [X] [`row_number`](#ranking-functions)
    - [X] [`rank`](#ranking-functions)
    - [X] [`dense_rank`](#ranking-functions)
    - [X] [`ntile`](#ranking-functions)
- [Analytic functions](#analytic-functions):
    - [X] [`lead` & `lag`](#lead--lag)
    - [X] [`percentile_count` & `percentile_disc`](#percentile_cont--percentile_disc)
- [Pivot / unpivot](#pivot--unpivot):
    - [X] [`pivot`](#pivot)
    - [X] [`unpivot`](#unpivot)
- [Applies](#applies):
    - [X] [`cross apply`](#cross-apply)
    - [X] [`outer apply`](#outer-apply)

## Set theory

### `union`

```sql
select 'case points' type,
       count(*) count
from case_points
    union
select 'result points',
       count(*)
from result_points;
```

Result:

| type          | count
| :-----------: | :---:
| case points   | 8760
| result points | 3476

### ~~`union all`~~

```sql
-- can't be implemented
```

### `except`

```sql
select results.steiner_tree
from results
    except
select cases.minimum_steiner_tree
from cases;
```

Result:

| steiner_tree
| :---:
| 0.00001
| 0.00666
| 0.02039
| ...
| 7.28062

**NOTE:** 276 rows with `except` and 391 without `except`

### `intersect`

```sql
select point_id
from case_points
    intersect
select point_id
from result_points;
```

Result:

| point_id
| :---:
| -

## Joins

### `inner join`

```sql
select algorithms.system_name algorithm,
       count(results.id) results
from results
    join algorithms
        on results.algorithm_id = algorithms.id
group by algorithms.system_name;
```

Result:

| algorithm	| results
| :-------: | :---:
| GA	    | 76
| IOA	    | 173
| ORL	    | 57
| RA	    | 84
 
### `left join`

```sql
select algorithms.system_name algorithm,
       count(results.id) results
from algorithms
    left join results
        on results.algorithm_id = algorithms.id
group by algorithms.system_name;
```

Result:

| algorithm	| results
| :-------: | :---:
| GA	    | 76
| IOA	    | 173
| ORL	    | 57
| RA	    | 84
| Test	    | 0

### `right join`

```sql
select algorithms.system_name algorithm,
       count(results.id) results
from algorithms
    right join results
        on results.algorithm_id = algorithms.id
group by algorithms.system_name;
```

Result:

| algorithm	| results
| :-------: | :---:
| `<null>`  | 1
| GA	    | 76
| IOA	    | 173
| ORL	    | 57
| RA	    | 84

### `full join`

```sql
select algorithms.system_name algorithm,
       count(results.id) results
from algorithms
    full join results
        on results.algorithm_id = algorithms.id
group by algorithms.system_name;
```

Result:

| algorithm	| results
| :-------: | :---:
| `<null>`  | 1
| GA	    | 76
| IOA	    | 173
| ORL	    | 57
| RA	    | 84  
| Test	    | 0

### `cross join`

```sql
select cases.id case_id,
       algorithms.system_name algorithm,
       results.steiner_tree
from cases
    cross join algorithms
    left join results
        on cases.id = results.case_id and algorithms.id = results.algorithm_id
order by cases.id;


```

### ~~`self join`~~

```sql
-- can't be implemented
```

### ~~`natural join`~~

MS SQL does **not** support `natural join`

```sql
select *
from case_points
    natural join result_points 
       use (point_id);
```

## Groupings:

### `rollup`

```sql
select isnull(algorithms.system_name,
           case
               when grouping(algorithms.system_name) = 1
                   then 'Any'
               else null end
       ) algorithm,
       isnull(cast(cases.count_of_points as varchar),
           case
               when grouping(cases.count_of_points) = 1
                   then 'Any' 
               else null end
       ) count_of_points,
       avg(results.steiner_tree) average_steiner_tree       
from results
    full join algorithms
        on algorithms.id = results.algorithm_id
    join cases
        on cases.id = results.case_id
group by rollup (algorithms.system_name, cases.count_of_points);
```

Result:

| algorithm	| count_of_points | average_steiner_tree
| :-------: | :-------------: | :---:
| `<null>`  | 3	              | 0.000010
| `<null>`  | Any	          | 0.000010
| GA	    | 3               | 5.079260
| GA	    | 4               | 1.560197
| GA	    | 5               | 1.191710
| ...       | ...             | ...
| GA	    | 90	          | 4.358770
| GA	    | 100	          | 5.346278
| GA	    | Any	          | 3.630100
| IOA	    | ...             | ...
| ...       | ...             | ...
| ORL	    | ...             | ...
| ...       | ...             | ...
| RA	    | ...             | ...
| ...       | ...             | ...
| Any       | Any	          | 3.690420

### `cube`

```sql
select isnull(algorithms.system_name,
           case
               when grouping(algorithms.system_name) = 1
                   then 'Any'
               else null end
       ) algorithm,
       isnull(cast(cases.count_of_points as varchar),
           case
               when grouping(cases.count_of_points) = 1
                   then 'Any' 
               else null end
       ) count_of_points,
       avg(results.steiner_tree) average_steiner_tree       
from results
    full join algorithms
        on algorithms.id = results.algorithm_id
    join cases
        on cases.id = results.case_id
group by cube (algorithms.system_name, cases.count_of_points);
```

Result:

| algorithm	| count_of_points | average_steiner_tree
| :-------: | :-------------: | :---:
| `<null>`  | 3               | 0.000010
| GA	    | 3               | 5.079260
| IOA	    | 3               | 2.071324
| ORL	    | 3               | 6.277410
| RA	    | 3               | 2.691083
| Any	    | 3               | 2.609938
| ...       | ...             | ...
| GA	    | 100	          | 5.346278
| IOA	    | 100	          | 6.298158
| ORL	    | 100	          | 3.649808
| RA	    | 100	          | 4.444340
| Any	    | 100	          | 5.122236
| Any	    | Any	          | 3.690420
| `<null>`  | Any	          | 0.000010
| GA	    | Any	          | 3.630100
| IOA	    | Any	          | 3.813475
| ORL	    | Any	          | 3.632730
| RA	    | Any	          | 3.574641

### `grouping sets`

```sql
select isnull(algorithms.system_name,
           case
               when grouping(algorithms.system_name) = 1
                   then 'Any'
               else null end
       ) algorithm,
       isnull(cast(cases.count_of_points as varchar),
           case
               when grouping(cases.count_of_points) = 1
                   then 'Any' 
               else null end
       ) count_of_points,
       avg(results.steiner_tree) average_steiner_tree       
from results
    join algorithms
        on algorithms.id = results.algorithm_id
    join cases
        on cases.id = results.case_id
group by grouping sets (algorithms.system_name, cases.count_of_points);
```

Result:

| algorithm	| count_of_points | average_steiner_tree
| :-------: | :-------------: | :---:
| Any	    | 3	              | 2.827432
| Any	    | 4	              | 2.358545
| Any	    | 5	              | 1.558096
| ...       | ...             | ...
| Any	    | 100             | 5.122236
| GA	    | Any             | 3.630100
| IOA	    | Any             | 3.813475
| ORL	    | Any             | 3.632730
| RA	    | Any             | 3.574641

### `grouping`

See [`rollup`](#rollup), [`cube`](#cube) and [`grouping sets`](#grouping-sets)

## Ranking functions

- [X] `row_number`
- [X] `rank`
- [X] `dense_rank`
- [X] `ntile`

Example:

```sql
select algorithms.system_name,
       avg(results.steiner_tree) avg_st,
       round(avg(results.steiner_tree), 2) rounded_avg_st,
       -- Ranking analytical functions:
       rank()       over (order by round(avg(results.steiner_tree), 2)) rank,
       dense_rank() over (order by round(avg(results.steiner_tree), 2)) dense_rank,
       row_number() over (order by avg(results.steiner_tree)) row_number,
       ntile(2)     over (order by avg(results.steiner_tree)) ntile
from results
    join algorithms
        on algorithms.id = results.algorithm_id
group by algorithms.system_name;
```

Result:

| system_name | avg_st   | rounded_avg_st | rank  | dense_rank | row_number | ntile
| :---------: | :------: | :------------: | :---: | :--------: | :--------: | :---:
| RA	      | 3.574641 | 3.570000       | 1	  | 1	       | 1          | 1
| GA	      | 3.630100 | 3.630000       | 2	  | 2	       | 2          | 1
| ORL	      | 3.632730 | 3.630000       | 2	  | 2	       | 3          | 2
| IOA	      | 3.813475 | 3.810000       | 4	  | 3	       | 4          | 2

## Analytic functions:

### `lead` & `lag`

```sql
select algorithms.system_name,
       lag(avg(results.steiner_tree)) over (order by avg(results.steiner_tree)) previous,
       avg(results.steiner_tree) average_steiner_tree,
       lead(avg(results.steiner_tree)) over (order by avg(results.steiner_tree)) next
from results
    join algorithms
        on algorithms.id = results.algorithm_id
group by algorithms.system_name;
```

Result: 

| algorithm	| previous | average_steiner_tree | next
| :-------: | :------: | :------------------: | :---:
| RA        | `<null>` | 3.574641             | 3.630100
| GA        | 3.574641 | 3.630100             | 3.632730
| ORL       | 3.630100 | 3.632730             | 3.813475
| IOA       | 3.632730 | 3.813475             | `<null>`

### `percentile_cont` & `percentile_disc`

```sql
select distinct
        case_points.case_id case_id,
        percentile_cont(0.5)
            within group (order by points.x)
                over (partition by case_points.case_id) median_x_cont,
        percentile_cont(0.5)
            within group (order by points.y)
                over (partition by case_points.case_id) median_y_cont,
        percentile_disc(0.5)
            within group (order by points.x)
                over (partition by case_points.case_id) median_x_disc,
        percentile_disc(0.5)
            within group (order by points.y)
                over (partition by case_points.case_id) median_y_disc
from case_points
    join points
        on case_points.point_id = points.id
order by case_points.case_id;
```

Result:

| case_id | median_x_cont | median_y_cont | median_x_disc | median_y_disc
| :-----: | :-----------: | :-----------: | :-----------: | :---:
| 1       | 0.5           | 0.9           | 0.50000       | 0.90000
| ...     | ...           | ...           | ...           | ...
| 7       | 0.45          | 0.2           | 0.10000       | 0.20000
| ...     | ...           | ...           | ...           | ...

All `x` and `y` values for cases with `id = 1` or `id = 7`:

| case_id | x       | y
| :-----: | :-----: | :---:
| 1       | 0.20000 | 0.90000
| 1       | 0.50000 | 0.38000
| 1       | 0.80000 | 0.90000
| 7       | 0.10000 | 0.08000
| 7       | 0.10000 | 0.20000
| 7       | 0.80000 | 0.20000
| 7       | 0.80000 | 0.28000

## `pivot` & `unpivot`

### `pivot`

```sql
select pvt.id case_id,
       pvt.[ORL], 
       pvt.[IOA], 
       pvt.[RA], 
       pvt.[GA]
from (
    select cases.id,
           algorithms.system_name,
           results.steiner_tree
    from cases
        join results
            on cases.id = results.case_id
        join algorithms
            on results.algorithm_id = algorithms.id
    ) as src
        pivot ( avg(src.steiner_tree) 
            for src.system_name
                in ([ORL], [IOA], [RA], [GA])
        ) as pvt;
```

Result:

| case_id | ORL      | IOA      | RA       | GA
| :-----: | :------: | :------: | :------: | :---:
| 1       | `<null>` | 1.435195 | `<null>` | `<null>`
| 2       | 6.277410 | 2.886890 | `<null>` | `<null>`
| 3       | `<null>` | 1.166780 | 6.018730 | 5.079260
| 4       | `<null>` | 0.198970 | 1.880170 | `<null>`
| ...     | ...      | ...      | ...      | ...

### `unpivot`

```sql
select id case_id,
       column_name,
       value
from cases
unpivot ( value
    for column_name
        in (
            [minimum_spanning_tree],
            [minimum_steiner_tree]
        )
) as unpvt;
```

Result:

| case_id | column_name           | value
| :-----: | :-------------------: | :---:
| 1	      | minimum_spanning_tree | 1.20033
| 1	      | minimum_steiner_tree  | 1.03962
| 2	      | minimum_spanning_tree | 1.48678
| 2	      | minimum_steiner_tree  | 1.46598
| ...     | ...                   | ...
| 196     | minimum_spanning_tree | 6.38253
| 196     | minimum_steiner_tree  | 6.20515

## Applies

### `cross apply`

```sql
select cases.id case_id,
       algorithms_results.*
from cases
    cross apply (
        select top 1 algorithms.system_name algorithm,
                     results.steiner_tree
        from results
            join algorithms
                on results.algorithm_id = algorithms.id
        where results.case_id = cases.id
        order by results.steiner_tree
    ) as algorithms_results
order by cases.id;
```

Result:

| case_id | algorithm | steiner_tree
| :-----: | :-------: | :---:
| 1	      | IOA	      | 1.03962
| 2	      | IOA	      | 1.46598
| 3	      | IOA	      | 1.16678
| ...     | ...       | ...
| 101     | GA	      | 3.43525
| 102     | ORL	      | 0.40405
| 103     | IOA	      | 2.22567
| ...     | ...       | ...

### `outer apply`

```sql
select cases.id case_id,
       algorithms_results.*
from cases
    outer apply (
        select top 1 algorithms.system_name algorithm,
                     results.steiner_tree
        from results
            join algorithms
                on results.algorithm_id = algorithms.id
        where results.case_id = cases.id
        order by results.steiner_tree
    ) as algorithms_results
order by cases.id;
```

Result:

| case_id | algorithm | steiner_tree
| :-----: | :-------: | :---:
| 1	      | IOA	      | 1.03962
| 2	      | IOA	      | 1.46598
| 3	      | IOA	      | 1.16678
| ...     | ...       | ...
| 101     | GA	      | 3.43525
| 102     | ORL	      | 0.40405
| 103     | IOA	      | 2.22567
| ...     | ...       | ...
| 197     | `<null>`  | `<null>`

[readme]:   https://github.com/FokinAlex/mssql-task/blob/master/readme.md
