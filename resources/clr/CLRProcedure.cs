using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using Microsoft.SqlServer.Server;

public partial class StoredProcedures
{
    readonly private static string connectionString = "context connection=true";

    [Microsoft.SqlServer.Server.SqlProcedure]
    public static int generateRandomCase(int countOfPoints)
    {
        if (countOfPoints < 3)
        {
            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                using (SqlCommand command = new SqlCommand("raiserror('Count of points must be bigger than 2', 0, 1)", connection))
                {
                    SqlContext.Pipe.ExecuteAndSend(command);
                }
            }
        }
        int case_id = generateCase(countOfPoints);
        for ( int i = 0; i < countOfPoints; i++ )
            generateCasePoint(case_id);
        return 0;
    }

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
}
