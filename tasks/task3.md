# [:back:][readme]

# Task #3

## Contains

Task contains:
- [CLR Stored procedure](#clr-stored-procedure)
    - [C# Definition](#c-definition)
    - [Put into docker](#put-into-docker)
    - [SQL Definition](#sql-definition)
    - [Usage](#usage)

## CLR Stored procedure

### C# Definition

See [CLRProcedure.cs][csfile]

Creating constant `connectionString` for SQL connection string:

```csharp
readonly private static string connectionString = "context connection=true";
```

Creating main method `generateRandomCase :: Integer -> Integer`:

```csharp
[Microsoft.SqlServer.Server.SqlProcedure]
public static int generateRandomCase(int countOfPoints)
{
    if (countOfPoints < 3)
    {
        using (SqlConnection connection = new SqlConnection(connectionString))
        {
            using (SqlCommand command = new SqlCommand("raiserror('Count of points must be bigger than 2', 0, 1)", connection))
            {
                connection.Open();
                SqlContext.Pipe.ExecuteAndSend(command);
                if (connection.State == System.Data.ConnectionState.Open) connection.Close();
                return -1;
            }
        }
    }
    int case_id = generateCase(countOfPoints);
    for ( int i = 0; i < countOfPoints; i++ )
        generateCasePoint(case_id);
    return 0;
}
```

Creating additional method `generateCase :: Integer -> Integer`:

```csharp
private static int generateCase(int countOfPoints)
{
    using (SqlConnection connection = new SqlConnection(connectionString))
    {
        using (SqlCommand command = new SqlCommand("insert into cases(count_of_points) output inserted.id values(@count_of_points)", connection))
        {
            command.Parameters.AddWithValue("@count_of_points", countOfPoints);
            connection.Open();
            int caseId = (int)command.ExecuteScalar();
            if (connection.State == System.Data.ConnectionState.Open) connection.Close();
            return caseId;
        }
    }
}
```

Creating additional method `generateCasePoint :: Integer -> Integer`:

```csharp
private static int generateCasePoint(int caseId)
{
    using (SqlConnection connection = new SqlConnection(connectionString))
    {
        int pointId;
        using (SqlCommand command = new SqlCommand("insert into points(x, y) output inserted.id values(@x, @y)", connection))
        {
            Random rand = new Random();
            command.Parameters.AddWithValue("@x", rand.NextDouble());
            command.Parameters.AddWithValue("@y", rand.NextDouble());
            connection.Open();
            pointId = (int)command.ExecuteScalar();
        }
        using (SqlCommand command = new SqlCommand("insert into case_points(case_id, point_id) values(@case_id, @point_id)", connection))
        {
            command.Parameters.AddWithValue("@case_id", caseId);
            command.Parameters.AddWithValue("@point_id", pointId);
            setIdentity("case_points", true);
            command.ExecuteNonQuery();
            setIdentity("case_points", false);
            if (connection.State == System.Data.ConnectionState.Open) connection.Close();
        }
        return pointId;
    }
}
```

Creating additional method `setIdentity :: (String, Boolean) -> ( )`:

```csharp
private static void setIdentity(string tableName, bool isOn)
{
    using (SqlConnection connection = new SqlConnection(connectionString))
    {
        using (SqlCommand command = new SqlCommand("set identity_insert " + tableName + " " + (isOn ? "on" : "off"), connection))
        {
            connection.Open();
            command.ExecuteNonQuery();
            if (connection.State == System.Data.ConnectionState.Open) connection.Close();
        }
    }
}
```

As result we have [CLR.dll][dllfile]

### Put into docker

Copy `.dll` into docker:

```text
docker cp CLR.dll mssql-server:/usr/src/steinerdb
```

### SQL Definition

Preconditions:

```sql
alter database steinerdb set trustworthy on;

exec sp_configure 'clr enabled', 1;
reconfigure;
```

Creating assembly `CLR`:

```sql
create assembly CLR
    from '/usr/src/steinerdb/CLR.dll';
```

Creating procedure `CLR`:

```sql
create procedure CLR (
    @count_of_points integer
)
as external name CLR.StoredProcedures.generateRandomCase;
```

### Usage

Procedure usage:

```sql
execute steinerdb.dbo.CLR 7;
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
| 1201    | 7               | 13267    | 0.79611 | 0.59983
| 1201    | 7               | 13268    | 0.76704 | 0.76162
| 1201    | 7               | 13269    | 0.26040 | 0.21683
| 1201    | 7               | 13270    | 0.23133 | 0.37862
| 1201    | 7               | 13271    | 0.72469 | 0.83383
| 1201    | 7               | 13272    | 0.69562 | 0.99562
| 1201    | 7               | 13273    | 0.69562 | 0.99562
| 1200    | 5               | 13262    | 0.52188 | 0.64511

Wrong procedure usage:

```sql
execute steinerdb.dbo.CLR 2;
```

Result:

```text
[S0001][50000] Count of points must be bigger than 2
completed in 2 s 97 ms
```

[readme]:   https://github.com/FokinAlex/mssql-task/blob/master/readme.md
[csfile]:   https://github.com/FokinAlex/mssql-task/blob/master/resources/clr/CLRProcedure.cs
[dllfile]:  https://github.com/FokinAlex/mssql-task/blob/master/resources/clr/CLR.dll
