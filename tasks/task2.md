# [:back:][readme]

# Task #2

## Contains

Task contains:
- [X] [Functions](#functions):
    - [X] [Function #1](#function-1)
    - [X] [Function #2](#function-2)
- [X] [Stored procedure](#stored-procedure)
- [X] [Triggers](#triggers):
    - [X] [Trigger #1](#trigger-1)
    - [X] [Trigger #2](#trigger-2)
- [X] [Cursor](#cursor)

## Functions

### Function #1

#### Definition

Creating function `getBestAlgorithmForCaseById :: Integer -> Integer`:

```sql
create function getBestAlgorithmForCaseById(@case_id integer)
returns integer
begin 
    declare @best_algorithm_id integer
    select @best_algorithm_id = algorithms_results.id
        from cases
            cross apply (
                select top 1 algorithms.id
                from results
                    join algorithms
                        on results.algorithm_id = algorithms.id
                where results.case_id = cases.id
                order by results.steiner_tree
            ) as algorithms_results
        where cases.id = @case_id
        order by cases.id
    return @best_algorithm_id
end;
```

#### Usage

Function usage:

```sql
select steinerdb.dbo.getBestAlgorithmForCaseById(3) as best_algorithm;
```

Result:

| best_algorithm
| :---:
| 2

All results for case `where id = 3`:

| case_id | steiner_tree| algorithm | algorithm_id
| :-----: | :----------:| :-------: | :---:
| 3	      | 1.16678     | IOA	    | 2
| 3	      | 5.07926     | GA	    | 3
| 3	      | 6.01873     | RA	    | 4

### Function #2

#### Definition

Creating function `getEachAlgorithmAverageSteinerTreesForCaseById :: Integer -> Table`:

```sql
create function getEachAlgorithmAverageSteinerTreesForCaseById(@case_id integer)
returns table
as return (
    select isnull(algorithms.system_name,
               case
                   when grouping(algorithms.system_name) = 1
                       then 'Any'
                   else null end
           ) algorithm,
           avg(results.steiner_tree) average_steiner_tree       
    from results
        full join algorithms
            on algorithms.id = results.algorithm_id
        join cases
            on cases.id = results.case_id
    where cases.id = @case_id
    group by rollup (algorithms.system_name)
);
```

#### Usage

Function usage:

```sql
select *
from steinerdb.dbo.getEachAlgorithmAverageSteinerTreesForCaseById(152)
order by average_steiner_tree;
```

Result:

| algorithm | average_steiner_tree
| :-------: | :---:
| IOA	    | 0.072950
| RA	    | 3.664555
| Any	    | 4.122086
| GA	    | 5.611395
| ORL	    | 6.107670

## Stored procedure

### Definition

Creating procedure `generateRandomCase`:

```sql
create procedure generateRandomCase(@count_of_points integer) as
begin 
    declare @counter integer = 0,
            @point_id integer,
            @case_id integer;
    if (@count_of_points < 3) begin 
        raiserror('Count of points must be bigger than 2', 0, 1);
        return -1;
    end;
    insert into cases (count_of_points)
        values (@count_of_points);     
    set @case_id = scope_identity();   
    while @counter < @count_of_points begin
        insert into points (x, y)
            values (rand(), rand());
        set @point_id = scope_identity(); 
        set identity_insert case_points on;
        insert into case_points (case_id, point_id) 
            values (@case_id, @point_id);
        set identity_insert case_points off;
        set @counter = @counter + 1;
    end;
    return 0;
end;
```

### Usage

Procedure usage:

```sql
execute steinerdb.dbo.generateRandomCase 5;
```

Result:

```sql
select cases.id case_id,
       cases.count_of_points,
       points.id point_id,
       points.x,
       points.y
from cases
    join case_points
        on case_points.case_id = cases.id
    join points
        on case_points.point_id = points.id
order by cases.id desc;
```

| case_id | count_of_points | point_id | x       | y
| :-----: | :-------------: | :------: | :-----: | :---:
| 202     | 5               | 12243    | 0.24163 | 0.83791
| 202     | 5               | 12244    | 0.83064 | 0.41790
| 202     | 5               | 12245    | 0.54839 | 0.31417
| 202     | 5               | 12246    | 0.97899 | 0.84327
| 202     | 5               | 12247    | 0.35475 | 0.02206
| 201     | ...             | ...      | ...     | ...
| ...     | ...             | ...      | ...     | ...

## Triggers

### Trigger #1

#### Definition

Creating trigger `update_count_of_case_points_trigger`:

```sql
create trigger update_count_of_case_points_trigger
    on case_points
        after insert, update, delete as
begin
    declare @old_case_id integer,
            @new_case_id integer,
            @count_of_points integer;
    select @old_case_id = case_id from deleted;
    select @count_of_points = (
        select count(*)
        from cases
            join case_points
                on cases.id = case_points.case_id
        where cases.id = @old_case_id
    );    
    update cases 
        set count_of_points = @count_of_points
    where cases.id = @old_case_id;
    select @new_case_id = case_id from inserted;
    select @count_of_points = (
        select count(*)
        from cases
            join case_points
                on cases.id = case_points.case_id
        where cases.id = @new_case_id
    );
    update cases 
        set count_of_points = @count_of_points
    where cases.id = @new_case_id;
end;
```

#### Usage

Checking trigger:

```sql
begin
    declare @test1_case_id integer = 202, -- from previous task
            @test_case1_count_of_points integer = 0,
            @test2_case_id integer = 201,
            @test_case2_count_of_points integer = 0,
            @point_id integer;
    insert into points (x, y)
        values (rand(), rand());
    set @point_id = scope_identity();
    select @test_case1_count_of_points = (
        select count_of_points
        from cases
        where cases.id = @test1_case_id
    );
    select @test_case2_count_of_points = (
        select count_of_points
        from cases
        where cases.id = @test2_case_id
    );
    print 'Before:          test_case1_count_of_points = ' + cast(@test_case1_count_of_points as varchar) +
                         '; test_case2_count_of_points = ' + cast(@test_case2_count_of_points as varchar);
    set identity_insert case_points on;
    insert into case_points (case_id, point_id)
        values (@test1_case_id, @point_id);
    set identity_insert case_points off;
    select @test_case1_count_of_points = (
        select count_of_points
        from cases
        where cases.id = @test1_case_id
    );
    select @test_case2_count_of_points = (
        select count_of_points
        from cases
        where cases.id = @test2_case_id
    );
    print 'After insertion: test_case1_count_of_points = ' + cast(@test_case1_count_of_points as varchar) +
                         '; test_case2_count_of_points = ' + cast(@test_case2_count_of_points as varchar);
    set identity_insert case_points on;
    update case_points
        set case_id = @test2_case_id
    where point_id = @point_id;
    set identity_insert case_points off;
    select @test_case1_count_of_points = (
        select count_of_points
        from cases
        where cases.id = @test1_case_id
    );
    select @test_case2_count_of_points = (
        select count_of_points
        from cases
        where cases.id = @test2_case_id
    );
    print 'After updating:  test_case1_count_of_points = ' + cast(@test_case1_count_of_points as varchar) +
                         '; test_case2_count_of_points = ' + cast(@test_case2_count_of_points as varchar);
    delete from case_points
    where point_id = @point_id;
    select @test_case1_count_of_points = (
        select count_of_points
        from cases
        where cases.id = @test1_case_id
    );
    select @test_case2_count_of_points = (
        select count_of_points
        from cases
        where cases.id = @test2_case_id
    );
    print 'After deleting:  test_case1_count_of_points = ' + cast(@test_case1_count_of_points as varchar) +
                         '; test_case2_count_of_points = ' + cast(@test_case2_count_of_points as varchar);
end;
```

Result:

```text
[S0001] Before:          test_case1_count_of_points = 5; test_case2_count_of_points = 3
[S0001] After insertion: test_case1_count_of_points = 6; test_case2_count_of_points = 3
[S0001] After updating:  test_case1_count_of_points = 5; test_case2_count_of_points = 4
[S0001] After deleting:  test_case1_count_of_points = 5; test_case2_count_of_points = 3
8 rows affected in 86 ms
```

```sql
select cases.id case_id,
       cases.count_of_points,
       case_points.point_id
from cases
    join case_points
        on cases.id = case_points.case_id
order by cases.id desc;
```

| case_id | count_of_points | point_id
| :-----: | :-------------: | :---:
| 202	  | 5	            | 12243
| 202	  | 5	            | 12244
| 202	  | 5	            | 12245
| 202	  | 5	            | 12246
| 202	  | 5	            | 12247
| 201	  | 3	            | 12240
| 201	  | 3	            | 12241
| 201	  | 3	            | 12242
| 200	  | ...             | ...
| ...     | ...             | ...

### Trigger #2

#### Definition

Creating triggers `update_results_trigger`:

```sql
create trigger update_results_trigger
    on results
        after insert, update as
begin
    declare @result_id integer,
            @steiner_tree numeric (20, 5),
            @minimum_steiner_tree numeric (20, 5),
            @minimum_spanning_tree numeric (20, 5);
    select @result_id = id from inserted;
    select @steiner_tree = results.steiner_tree,
           @minimum_steiner_tree = cases.minimum_steiner_tree,
           @minimum_spanning_tree = cases.minimum_spanning_tree
    from cases
        join results
            on cases.id = results.case_id
    where results.id = @result_id;
    if @steiner_tree < @minimum_steiner_tree
        raiserror('[WARN] Broken consistency - steiner tree can not be less than minimum steiner tree (results.id = %i)',
            0, 1, @result_id);
    if @steiner_tree > @minimum_spanning_tree
        raiserror('[WARN] Broken consistency - steiner tree can not be bigger than minimum spanning tree (results.id = %i)',
            0, 2, @result_id);
end;
```

#### Usage

Checking trigger:

```sql
select results.id result_id,
       cases.minimum_steiner_tree,
       results.steiner_tree,
       cases.minimum_spanning_tree
from cases
    join results
        on cases.id = results.case_id
where results.id = 983;
```

| result_id | minimum_steiner_tree | steiner_tree | minimum_spanning_tree
| :-------: | :------------------: | :----------: | :---:
| 983	    | 6.88260	           | 7.08671	  | 7.13710

```sql
begin
    declare @result_id integer = 983,
            @steiner_tree numeric (20, 5) = 7.08671,
            @minimum_steiner_tree numeric (20, 5) = 6.88260,
            @minimum_spanning_tree numeric (20, 5) = 7.13710,
            @message_steiner_tree numeric (20, 5),
            @message_minimum_steiner_tree numeric (20, 5),
            @message_minimum_spanning_tree numeric (20, 5);
    select @message_steiner_tree = steiner_tree,
           @message_minimum_steiner_tree = minimum_steiner_tree,
           @message_minimum_spanning_tree = minimum_spanning_tree
    from cases
        join results
            on cases.id = results.case_id
    where results.id = @result_id;
    print '#1: ' + cast(@message_minimum_steiner_tree as varchar) + ' < ' +
                   cast(@message_steiner_tree as varchar) + ' < ' +
                   cast(@message_minimum_spanning_tree as varchar);
    update results
        set steiner_tree = @minimum_steiner_tree - 1 -- wrong value
    where results.id = @result_id;
    select @message_steiner_tree = results.steiner_tree,
           @message_minimum_steiner_tree = cases.minimum_steiner_tree,
           @message_minimum_spanning_tree = cases.minimum_spanning_tree
    from cases
        join results
            on cases.id = results.case_id
    where results.id = @result_id;
    print '#2: ' + cast(@message_minimum_steiner_tree as varchar) + ' < ' +
                   cast(@message_steiner_tree as varchar) + ' < ' +
                   cast(@message_minimum_spanning_tree as varchar);
    update results
        set steiner_tree = @minimum_spanning_tree + 1 -- wrong value
    where results.id = @result_id;
    select @message_steiner_tree = results.steiner_tree,
           @message_minimum_steiner_tree = cases.minimum_steiner_tree,
           @message_minimum_spanning_tree = cases.minimum_spanning_tree
    from cases
        join results
            on cases.id = results.case_id
    where results.id = @result_id;
    print '#3: ' + cast(@message_minimum_steiner_tree as varchar) + ' < ' +
                   cast(@message_steiner_tree as varchar) + ' < ' +
                   cast(@message_minimum_spanning_tree as varchar);
    update results
        set steiner_tree = @steiner_tree -- correct value
    where results.id = @result_id;
    select @message_steiner_tree = results.steiner_tree,
           @message_minimum_steiner_tree = cases.minimum_steiner_tree,
           @message_minimum_spanning_tree = cases.minimum_spanning_tree
    from cases
        join results
            on cases.id = results.case_id
    where results.id = @result_id;
    print '#4: ' + cast(@message_minimum_steiner_tree as varchar) + ' < ' +
                   cast(@message_steiner_tree as varchar) + ' < ' +
                   cast(@message_minimum_spanning_tree as varchar);
end;
```

Result:

```text
[S0001] #1: 6.88260 < 0.73622 < 7.13710
[S0001][50000] [WARN] Broken consistency - steiner tree can not be less than minimum steiner tree (results.id = 983)
[S0001] #2: 6.88260 < 5.88260 < 7.13710
[S0002][50000] [WARN] Broken consistency - steiner tree can not be bigger than minimum spanning tree (results.id = 983)
[S0001] #3: 6.88260 < 8.13710 < 7.13710
[S0001] #4: 6.88260 < 7.08671 < 7.13710
3 rows affected in 65 ms
```

## Cursor

### Definition

Creating cursor `check_points_cursor`:

```sql
declare check_points_cursor cursor
    forward_only fast_forward read_only for
    select points.id point_id,
               case_points.case_id,
               result_points.result_id
    from points
        left join case_points
            on points.id = case_points.point_id
        left join result_points
            on points.id = result_points.point_id;
```

Creating function `check_points :: ( ) -> Table` with cursor `check_points_cursor`:

```sql
create function check_points()
returns @warnings table (
    point_id integer,
    message varchar(255)
) begin
    declare check_points_cursor cursor
        forward_only fast_forward read_only for
        select points.id point_id,
                   case_points.case_id,
                   result_points.result_id
        from points
            left join case_points
                on points.id = case_points.point_id
            left join result_points
                on points.id = result_points.point_id;
    declare @point_id integer,
            @case_id integer,
            @result_id integer;
    open check_points_cursor
    fetch next from check_points_cursor
    into @point_id,
         @case_id,
         @result_id
    while @@fetch_status = 0 begin 
        if @case_id is null and @result_id is null begin 
            insert into @warnings (point_id, message)
                values (@point_id, 'Point without usages');
        end;
        if @case_id is not null and @result_id is not null begin
            insert into @warnings (point_id, message)
                values (@point_id, 'Point with repeated usage');
        end;
        fetch next from check_points_cursor
        into @point_id,
             @case_id,
             @result_id
    end;
    close check_points_cursor;
    deallocate check_points_cursor;
    return;
end;
```

`@warnings` tables example:

| point_id | message
| :------: | :---:
| 13259    | Point without usages
| 13260    | Point with duplicated usage

### Usage

Function usage:

```sql
select * from steinerdb.dbo.check_points();
```

Checking function:

```sql
begin
    declare @count_of_warnings integer,
            @point_id integer;
    select @count_of_warnings = count(*)
        from steinerdb.dbo.check_points();
    print 'count_of_warnings = ' + cast(@count_of_warnings as varchar);
    insert into points (x, y)
        values (rand(), rand());
    set @point_id = scope_identity();
    select @count_of_warnings = count(*)
        from steinerdb.dbo.check_points();
    print 'count_of_warnings = ' + cast(@count_of_warnings as varchar);
    delete from points
    where points.id = @point_id;
    select @count_of_warnings = count(*)
        from steinerdb.dbo.check_points();
    print 'count_of_warnings = ' + cast(@count_of_warnings as varchar);    
end;
```

Result:

```text
[S0001] count_of_warnings = 0
[S0001] count_of_warnings = 1
[S0001] count_of_warnings = 0
2 rows affected in 1 s 228 ms
```

[readme]:   https://github.com/FokinAlex/mssql-task/blob/master/readme.md
