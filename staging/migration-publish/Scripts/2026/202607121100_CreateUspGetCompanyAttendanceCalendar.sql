-- Company attendance calendar: page by employees, return attendance for period.
-- Prerequisites: dbo.EmployeeAttendance, dbo.Employee, dbo.EmployeeEmployment, dbo.CompanyBatch
CREATE OR ALTER PROCEDURE [dbo].[usp_GetCompanyAttendanceCalendar]
    @CompanyId           INT,
    @From                DATE,
    @To                  DATE,
    @EmployeeId          INT = NULL,
    @EmployeePage        INT = 1,
    @EmployeePageSize    INT = 50,
    @EmployeeTotalCount  INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF @EmployeePage < 1 SET @EmployeePage = 1;
    IF @EmployeePageSize < 1 SET @EmployeePageSize = 50;
    IF @EmployeePageSize > 100 SET @EmployeePageSize = 100;

    IF @From IS NULL OR @To IS NULL
    BEGIN
        SET @EmployeeTotalCount = 0;
        SELECT
            CAST(NULL AS INT) AS [EmployeeId],
            CAST(NULL AS NVARCHAR(200)) AS [Name],
            CAST(NULL AS DATE) AS [JoiningDate],
            CAST(NULL AS DATE) AS [LeavingDate]
        WHERE 1 = 0;

        SELECT
            CAST(NULL AS INT) AS [EmployeeAttendanceId],
            CAST(NULL AS INT) AS [EmployeeId],
            CAST(NULL AS NVARCHAR(200)) AS [EmployeeName],
            CAST(NULL AS INT) AS [EmploymentId],
            CAST(NULL AS INT) AS [CompanyId],
            CAST(NULL AS INT) AS [CompanyBatchId],
            CAST(NULL AS NVARCHAR(200)) AS [CompanyBatchName],
            CAST(NULL AS DATE) AS [WorkDate],
            CAST(NULL AS DATETIME2) AS [CheckInAt],
            CAST(NULL AS DATETIME2) AS [CheckOutAt],
            CAST(NULL AS DECIMAL(9,6)) AS [CheckInLatitude],
            CAST(NULL AS DECIMAL(9,6)) AS [CheckInLongitude],
            CAST(NULL AS DECIMAL(9,6)) AS [CheckOutLatitude],
            CAST(NULL AS DECIMAL(9,6)) AS [CheckOutLongitude],
            CAST(NULL AS TINYINT) AS [DayType],
            CAST(NULL AS TINYINT) AS [Status],
            CAST(NULL AS TINYINT) AS [Source],
            CAST(NULL AS NVARCHAR(500)) AS [Notes]
        WHERE 1 = 0;
        RETURN;
    END;

    ;WITH EligibleEmployees AS (
        SELECT
            e.[EmployeeId],
            e.[Name],
            stint.[JoiningDate],
            stint.[LeavingDate]
        FROM [dbo].[Employee] e
        CROSS APPLY (
            SELECT TOP (1)
                ee.[JoiningDate],
                ee.[LeavingDate]
            FROM [dbo].[EmployeeEmployment] ee
            WHERE ee.[EmployeeId] = e.[EmployeeId]
              AND ee.[CompanyId] = @CompanyId
              AND ee.[DeletedAt] IS NULL
              AND ee.[JoiningDate] <= @To
              AND (ee.[LeavingDate] IS NULL OR ee.[LeavingDate] >= @From)
            ORDER BY ee.[JoiningDate] DESC
        ) stint
        WHERE e.[DeletedAt] IS NULL
          AND (@EmployeeId IS NULL OR e.[EmployeeId] = @EmployeeId)
    )
    SELECT @EmployeeTotalCount = COUNT(1)
    FROM EligibleEmployees;

    ;WITH EligibleEmployees AS (
        SELECT
            e.[EmployeeId],
            e.[Name],
            stint.[JoiningDate],
            stint.[LeavingDate]
        FROM [dbo].[Employee] e
        CROSS APPLY (
            SELECT TOP (1)
                ee.[JoiningDate],
                ee.[LeavingDate]
            FROM [dbo].[EmployeeEmployment] ee
            WHERE ee.[EmployeeId] = e.[EmployeeId]
              AND ee.[CompanyId] = @CompanyId
              AND ee.[DeletedAt] IS NULL
              AND ee.[JoiningDate] <= @To
              AND (ee.[LeavingDate] IS NULL OR ee.[LeavingDate] >= @From)
            ORDER BY ee.[JoiningDate] DESC
        ) stint
        WHERE e.[DeletedAt] IS NULL
          AND (@EmployeeId IS NULL OR e.[EmployeeId] = @EmployeeId)
    ),
    PageEmployees AS (
        SELECT
            [EmployeeId],
            [Name],
            [JoiningDate],
            [LeavingDate]
        FROM EligibleEmployees
        ORDER BY [Name], [EmployeeId]
        OFFSET CASE WHEN @EmployeeId IS NOT NULL THEN 0 ELSE (@EmployeePage - 1) * @EmployeePageSize END ROWS
        FETCH NEXT CASE WHEN @EmployeeId IS NOT NULL THEN 1 ELSE @EmployeePageSize END ROWS ONLY
    )
    SELECT
        [EmployeeId],
        [Name],
        [JoiningDate],
        [LeavingDate]
    FROM PageEmployees
    ORDER BY [Name], [EmployeeId];

    ;WITH EligibleEmployees AS (
        SELECT
            e.[EmployeeId]
        FROM [dbo].[Employee] e
        CROSS APPLY (
            SELECT TOP (1) ee.[EmploymentId]
            FROM [dbo].[EmployeeEmployment] ee
            WHERE ee.[EmployeeId] = e.[EmployeeId]
              AND ee.[CompanyId] = @CompanyId
              AND ee.[DeletedAt] IS NULL
              AND ee.[JoiningDate] <= @To
              AND (ee.[LeavingDate] IS NULL OR ee.[LeavingDate] >= @From)
            ORDER BY ee.[JoiningDate] DESC
        ) stint
        WHERE e.[DeletedAt] IS NULL
          AND (@EmployeeId IS NULL OR e.[EmployeeId] = @EmployeeId)
    ),
    PageEmployees AS (
        SELECT e.[EmployeeId], emp.[Name]
        FROM EligibleEmployees e
        INNER JOIN [dbo].[Employee] emp ON emp.[EmployeeId] = e.[EmployeeId]
        ORDER BY emp.[Name], e.[EmployeeId]
        OFFSET CASE WHEN @EmployeeId IS NOT NULL THEN 0 ELSE (@EmployeePage - 1) * @EmployeePageSize END ROWS
        FETCH NEXT CASE WHEN @EmployeeId IS NOT NULL THEN 1 ELSE @EmployeePageSize END ROWS ONLY
    )
    SELECT
        a.[EmployeeAttendanceId],
        a.[EmployeeId],
        pe.[Name] AS [EmployeeName],
        a.[EmploymentId],
        a.[CompanyId],
        a.[CompanyBatchId],
        b.[BatchName] AS [CompanyBatchName],
        a.[WorkDate],
        a.[CheckInAt],
        a.[CheckOutAt],
        a.[CheckInLatitude],
        a.[CheckInLongitude],
        a.[CheckOutLatitude],
        a.[CheckOutLongitude],
        a.[DayType],
        a.[Status],
        a.[Source],
        a.[Notes]
    FROM [dbo].[EmployeeAttendance] a
    INNER JOIN PageEmployees pe ON pe.[EmployeeId] = a.[EmployeeId]
    LEFT JOIN [dbo].[CompanyBatch] b ON b.[CompanyBatchId] = a.[CompanyBatchId]
    WHERE a.[DeletedAt] IS NULL
      AND a.[CompanyId] = @CompanyId
      AND a.[WorkDate] >= @From
      AND a.[WorkDate] <= @To
    ORDER BY pe.[Name], a.[WorkDate], a.[CheckInAt];
END
GO
