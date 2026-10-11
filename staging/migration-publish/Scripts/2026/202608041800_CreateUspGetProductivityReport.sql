-- Productivity report (Pie1 sp_GetProductivityReport contract on Pie2 schema).
-- One row per Employee + Company for employments overlapping @StartDate..@EndDate.
-- Attendance/tasks counted only inside each company employment window (handles multi-company).
-- Prerequisites:
--   202602160000_CreateCompanyTable.sql
--   202605171010_CreateEmployeeTable.sql
--   202605171020_CreateEmployeeEmploymentTable.sql
--   202606231010_CreateEmployeeAttendanceTable.sql
--   202607191600_CreateEmployeeTaskTable.sql
CREATE OR ALTER PROCEDURE [dbo].[usp_GetProductivityReport]
    @StartDate  DATETIME     = NULL,
    @EndDate    DATETIME     = NULL,
    @Company    INT          = NULL,
    @NationaId  VARCHAR(50)  = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @FromDate DATE = CAST(@StartDate AS DATE);
    DECLARE @ToDate   DATE = CAST(@EndDate   AS DATE);

    ;WITH EmploymentInRange AS (
        -- Employment stints that overlap the report window (clipped to Start/End)
        SELECT
            ee.[EmployeeId],
            ee.[CompanyId],
            CASE
                WHEN @FromDate IS NOT NULL AND ee.[JoiningDate] < @FromDate THEN @FromDate
                ELSE ee.[JoiningDate]
            END AS [EffectiveFrom],
            CASE
                WHEN ee.[LeavingDate] IS NULL AND @ToDate IS NULL THEN CAST('99991231' AS DATE)
                WHEN ee.[LeavingDate] IS NULL THEN @ToDate
                WHEN @ToDate IS NOT NULL AND ee.[LeavingDate] > @ToDate THEN @ToDate
                ELSE ee.[LeavingDate]
            END AS [EffectiveTo]
        FROM [dbo].[EmployeeEmployment] ee
        INNER JOIN [dbo].[Company] c
            ON c.[CompanyId] = ee.[CompanyId]
           AND c.[DeletedAt] IS NULL
        WHERE ee.[DeletedAt] IS NULL
          AND (ISNULL(@Company, -1) = -1 OR ee.[CompanyId] = @Company)
          AND (@ToDate IS NULL OR ee.[JoiningDate] <= @ToDate)
          AND (
                @FromDate IS NULL
                OR ee.[LeavingDate] IS NULL
                OR ee.[LeavingDate] >= @FromDate
              )
          AND (
                ISNULL(@NationaId, '') = ''
                OR EXISTS (
                    SELECT 1
                    FROM [dbo].[Employee] e0
                    WHERE e0.[EmployeeId] = ee.[EmployeeId]
                      AND e0.[DeletedAt] IS NULL
                      AND e0.[NationalId] = @NationaId
                )
              )
    ),
    EmployeeFiltered AS (
        SELECT
            e.[EmployeeId],
            e.[Name],
            e.[NationalId],
            er.[CompanyId],
            c.[CompanyName]
        FROM EmploymentInRange er
        INNER JOIN [dbo].[Employee] e
            ON e.[EmployeeId] = er.[EmployeeId]
           AND e.[DeletedAt] IS NULL
        INNER JOIN [dbo].[Company] c
            ON c.[CompanyId] = er.[CompanyId]
           AND c.[DeletedAt] IS NULL
        WHERE (ISNULL(@NationaId, '') = '' OR e.[NationalId] = @NationaId)
        GROUP BY
            e.[EmployeeId],
            e.[Name],
            e.[NationalId],
            er.[CompanyId],
            c.[CompanyName]
    ),
    LoginSummary AS (
        SELECT
            a.[EmployeeId],
            a.[CompanyId],
            COUNT(1) AS [NoOfLogin],
            SUM(CASE WHEN a.[CheckOutAt] IS NOT NULL THEN 1 ELSE 0 END) AS [NoOfLogout],
            ISNULL(SUM(
                CASE
                    WHEN a.[CheckOutAt] IS NOT NULL
                        THEN DATEDIFF(MINUTE, a.[CheckInAt], a.[CheckOutAt])
                    ELSE 0
                END
            ), 0) AS [TotalTimeOnlineMinutes],
            SUM(CASE WHEN a.[CheckOutAt] IS NOT NULL THEN 1 ELSE 0 END) AS [LoginDays]
        FROM [dbo].[EmployeeAttendance] a
        WHERE a.[DeletedAt] IS NULL
          AND EXISTS (
                SELECT 1
                FROM EmploymentInRange er
                WHERE er.[EmployeeId] = a.[EmployeeId]
                  AND er.[CompanyId]  = a.[CompanyId]
                  AND a.[WorkDate] BETWEEN er.[EffectiveFrom] AND er.[EffectiveTo]
              )
        GROUP BY
            a.[EmployeeId],
            a.[CompanyId]
    ),
    TaskSummary AS (
        SELECT
            t.[OwnerEmployeeId] AS [EmployeeId],
            t.[CompanyId],
            COUNT(1) AS [TotalTask],
            SUM(CASE WHEN t.[Status] = 2 THEN 1 ELSE 0 END) AS [CompletedTask],
            SUM(CASE WHEN t.[Status] <> 2 THEN 1 ELSE 0 END) AS [PendingTask]
        FROM [dbo].[EmployeeTask] t
        WHERE t.[DeletedAt] IS NULL
          AND EXISTS (
                SELECT 1
                FROM EmploymentInRange er
                WHERE er.[EmployeeId] = t.[OwnerEmployeeId]
                  AND er.[CompanyId]  = t.[CompanyId]
                  AND t.[StartDate] <= er.[EffectiveTo]
                  AND t.[EndDate]   >= er.[EffectiveFrom]
              )
        GROUP BY
            t.[OwnerEmployeeId],
            t.[CompanyId]
    )
    SELECT
        ef.[CompanyName],
        ef.[Name] AS [TeleworkerName],
        CONCAT('Emp', RIGHT(CONCAT('00000000', CAST(ef.[EmployeeId] AS VARCHAR(10))), 8)) AS [TeleworkerID],
        ef.[NationalId] AS [ID],
        ISNULL(l.[NoOfLogin], 0) AS [NoOfLogin],
        ISNULL(l.[NoOfLogout], 0) AS [NoOfLogout],
        ISNULL(ts.[TotalTask], 0) AS [NoOfTask],
        ISNULL(ts.[CompletedTask], 0) AS [CompletedTask],
        ISNULL(ts.[PendingTask], 0) AS [PendingTask],
        LTRIM(RTRIM(
              CASE WHEN FLOOR(ISNULL(l.[TotalTimeOnlineMinutes], 0) / 60.0) > 0
                   THEN CAST(FLOOR(ISNULL(l.[TotalTimeOnlineMinutes], 0) / 60.0) AS VARCHAR(20)) + ' h '
                   ELSE '' END
            + CASE WHEN (ISNULL(l.[TotalTimeOnlineMinutes], 0) % 60) > 0
                   THEN CAST(ISNULL(l.[TotalTimeOnlineMinutes], 0) % 60 AS VARCHAR(20)) + ' min '
                   ELSE '' END
        )) AS [TimeOnline],
        ISNULL(l.[LoginDays], 0) AS [LoginDays]
    FROM EmployeeFiltered ef
    LEFT JOIN LoginSummary l
        ON l.[EmployeeId] = ef.[EmployeeId]
       AND l.[CompanyId]  = ef.[CompanyId]
    LEFT JOIN TaskSummary ts
        ON ts.[EmployeeId] = ef.[EmployeeId]
       AND ts.[CompanyId]  = ef.[CompanyId]
    ORDER BY
        ef.[CompanyName],
        ef.[Name];
END
GO
