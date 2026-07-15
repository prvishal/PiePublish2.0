-- Company payroll generation (one call per company; employee loop inside SQL, not C#).
-- @UpsertMode: 0 = insert-if-missing / skip existing; 1 = insert or update (not Approved/Void).
-- Prerequisites: 202607101051, 202607101052, 202607101053.
CREATE OR ALTER PROCEDURE [dbo].[usp_GenerateCompanyPayroll]
    @PayrollBatchId INT,
    @UpsertMode BIT = 0,
    @DefaultCountryIso2 CHAR(2) = 'SA',
    @PayrollRunId INT = NULL,
    @PayrollRunCompanyId INT = NULL,
    @SuccessCount INT OUTPUT,
    @SkippedCount INT OUTPUT,
    @FailureCount INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SET @SuccessCount = 0;
    SET @SkippedCount = 0;
    SET @FailureCount = 0;

    DECLARE @CompanyId INT;
    DECLARE @PayrollYear SMALLINT;
    DECLARE @PayrollMonth TINYINT;
    DECLARE @PeriodStart DATE;
    DECLARE @PeriodEnd DATE;
    DECLARE @DaysDivisor INT;
    DECLARE @CurrencyCode CHAR(3);
    DECLARE @BatchStatus NVARCHAR(20);

    DECLARE @EmploymentId INT;
    DECLARE @EmployeeId INT;
    DECLARE @JoiningDate DATE;
    DECLARE @LeavingDate DATE;
    DECLARE @SkipEmployee BIT;

    DECLARE @SalaryPackageId INT;
    DECLARE @PackageCurrency CHAR(3);
    DECLARE @PackageTotal DECIMAL(18, 2);
    DECLARE @EmployeeName NVARCHAR(200);
    DECLARE @EmployeeNationalId NVARCHAR(20);
    DECLARE @PayslipNumber NVARCHAR(30);

    DECLARE @WorkDate DATE;
    DECLARE @PresentDays INT;
    DECLARE @WeekendDays INT;
    DECLARE @HolidayDays INT;
    DECLARE @WDPerWeek TINYINT;
    DECLARE @DailyRate DECIMAL(18, 4);
    DECLARE @PaidDays INT;
    DECLARE @PayableAmount DECIMAL(18, 2);
    DECLARE @ExistingSlipId INT;
    DECLARE @NewSlipId INT;
    DECLARE @EmpErr NVARCHAR(2000);
    DECLARE @ErrMsg NVARCHAR(2000);
    DECLARE @ErrorNumber INT;
    DECLARE @ErrorLine INT;

    SELECT
        @CompanyId = b.[CompanyId],
        @PayrollYear = b.[PayrollYear],
        @PayrollMonth = b.[PayrollMonth],
        @PeriodStart = b.[PeriodStart],
        @PeriodEnd = b.[PeriodEnd],
        @DaysDivisor = b.[DaysDivisor],
        @CurrencyCode = b.[CurrencyCode],
        @BatchStatus = b.[BatchStatus]
    FROM [dbo].[PayrollBatch] b
    WHERE b.[PayrollBatchId] = @PayrollBatchId
      AND b.[DeletedAt] IS NULL;

    IF @CompanyId IS NULL
        THROW 50001, 'Payroll batch not found.', 1;

    IF @BatchStatus <> N'Pending'
        RETURN;

    IF @PayrollRunId IS NULL
        SELECT @PayrollRunId = b.[PayrollRunId]
        FROM [dbo].[PayrollBatch] b
        WHERE b.[PayrollBatchId] = @PayrollBatchId;

    BEGIN TRY
        BEGIN TRAN;

        UPDATE [dbo].[PayrollBatch]
        SET [BatchStatus] = N'Processing',
            [UpdatedAt] = GETDATE()
        WHERE [PayrollBatchId] = @PayrollBatchId;

        DECLARE emp_cursor CURSOR LOCAL FAST_FORWARD FOR
            SELECT ee.[EmploymentId],
                   ee.[EmployeeId],
                   ee.[JoiningDate],
                   ee.[LeavingDate]
            FROM [dbo].[EmployeeEmployment] ee
            INNER JOIN [dbo].[Employee] e ON e.[EmployeeId] = ee.[EmployeeId]
            WHERE ee.[CompanyId] = @CompanyId
              AND ee.[DeletedAt] IS NULL
              AND e.[DeletedAt] IS NULL
              AND ee.[JoiningDate] <= @PeriodEnd
              AND (ee.[LeavingDate] IS NULL OR ee.[LeavingDate] >= @PeriodStart)
            ORDER BY ee.[EmployeeId];

        OPEN emp_cursor;
        FETCH NEXT FROM emp_cursor INTO @EmploymentId, @EmployeeId, @JoiningDate, @LeavingDate;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            SET @SkipEmployee = 0;

            BEGIN TRY
                IF @UpsertMode = 0
                   AND EXISTS (
                        SELECT 1
                        FROM [dbo].[EmployeePayrollSlip] s
                        WHERE s.[CompanyId] = @CompanyId
                          AND s.[EmployeeId] = @EmployeeId
                          AND s.[PayrollYear] = @PayrollYear
                          AND s.[PayrollMonth] = @PayrollMonth
                          AND s.[DeletedAt] IS NULL
                          AND s.[SlipStatus] <> N'Void'
                   )
                BEGIN
                    SET @SkippedCount += 1;
                    SET @SkipEmployee = 1;
                END

                IF @SkipEmployee = 0
                BEGIN
                    SET @SalaryPackageId = NULL;
                    SET @PackageCurrency = NULL;
                    SET @PackageTotal = NULL;

                    SELECT TOP (1)
                        @SalaryPackageId = p.[SalaryPackageId],
                        @PackageCurrency = p.[CurrencyCode],
                        @PackageTotal = ISNULL((
                            SELECT SUM(l.[Amount])
                            FROM [dbo].[EmployeeSalaryPackageLine] l
                            WHERE l.[SalaryPackageId] = p.[SalaryPackageId]
                              AND l.[DeletedAt] IS NULL), 0)
                    FROM [dbo].[EmployeeSalaryPackage] p
                    WHERE p.[EmploymentId] = @EmploymentId
                      AND p.[DeletedAt] IS NULL
                      AND p.[EffectiveFrom] <= @PeriodEnd
                      AND (p.[EffectiveTo] IS NULL OR p.[EffectiveTo] >= @PeriodEnd)
                    ORDER BY p.[EffectiveFrom] DESC;

                    SELECT
                        @EmployeeName = COALESCE(
                            NULLIF(LTRIM(RTRIM(e.[Name])), N''),
                            NULLIF(LTRIM(RTRIM(
                                ISNULL(u.[FirstName], N'') + N' ' + ISNULL(u.[LastName], N''))), N'')),
                        @EmployeeNationalId = e.[NationalId]
                    FROM [dbo].[Employee] e
                    LEFT JOIN [dbo].[User] u ON u.[UserId] = e.[UserId]
                    WHERE e.[EmployeeId] = @EmployeeId;

                    SET @PayslipNumber =
                        N'PS-'
                        + RIGHT(N'0000' + CAST(@PayrollYear AS NVARCHAR(4)), 4)
                        + N'-'
                        + RIGHT(N'00' + CAST(@PayrollMonth AS NVARCHAR(2)), 2)
                        + N'-'
                        + RIGHT(N'00000' + CAST(@EmployeeId AS NVARCHAR(10)), 5);

                    IF @SalaryPackageId IS NULL
                    BEGIN
                        EXEC [dbo].[usp_Payroll_LogError]
                            @PayrollRunId, @PayrollRunCompanyId, @PayrollBatchId,
                            @EmploymentId, @EmployeeId, N'SP', N'No salary package found for this period.';

                        IF @UpsertMode = 1
                           AND EXISTS (
                                SELECT 1
                                FROM [dbo].[EmployeePayrollSlip] s
                                WHERE s.[CompanyId] = @CompanyId
                                  AND s.[EmployeeId] = @EmployeeId
                                  AND s.[PayrollYear] = @PayrollYear
                                  AND s.[PayrollMonth] = @PayrollMonth
                                  AND s.[DeletedAt] IS NULL
                                  AND s.[SlipStatus] NOT IN (N'Approved', N'Void')
                           )
                        BEGIN
                            UPDATE s SET
                                s.[SlipStatus] = N'Skipped',
                                s.[Message] = N'No salary package found for this period.',
                                s.[PackageTotal] = 0,
                                s.[DailyRate] = 0,
                                s.[PayableAmount] = 0,
                                s.[UpdatedAt] = GETDATE()
                            FROM [dbo].[EmployeePayrollSlip] s
                            WHERE s.[CompanyId] = @CompanyId
                              AND s.[EmployeeId] = @EmployeeId
                              AND s.[PayrollYear] = @PayrollYear
                              AND s.[PayrollMonth] = @PayrollMonth
                              AND s.[DeletedAt] IS NULL
                              AND s.[SlipStatus] NOT IN (N'Approved', N'Void');
                        END
                        ELSE IF NOT EXISTS (
                            SELECT 1
                            FROM [dbo].[EmployeePayrollSlip] s
                            WHERE s.[CompanyId] = @CompanyId
                              AND s.[EmployeeId] = @EmployeeId
                              AND s.[PayrollYear] = @PayrollYear
                              AND s.[PayrollMonth] = @PayrollMonth
                              AND s.[DeletedAt] IS NULL
                              AND s.[SlipStatus] <> N'Void'
                        )
                        BEGIN
                            INSERT INTO [dbo].[EmployeePayrollSlip] (
                                [PayrollBatchId], [CompanyId], [EmployeeId], [EmploymentId],
                                [PayslipNumber], [PayslipDate], [PayrollYear], [PayrollMonth], [CurrencyCode],
                                [EmployeeName], [EmployeeNationalId], [PackageTotal], [DailyRate],
                                [PresentDays], [WeekendDays], [HolidayDays], [PayableAmount],
                                [SlipStatus], [Message], [CreatedAt])
                            VALUES (
                                @PayrollBatchId, @CompanyId, @EmployeeId, @EmploymentId,
                                @PayslipNumber, CAST(GETDATE() AS DATE), @PayrollYear, @PayrollMonth, @CurrencyCode,
                                @EmployeeName, @EmployeeNationalId, 0, 0,
                                0, 0, 0, 0,
                                N'Skipped', N'No salary package found for this period.', GETDATE());
                        END

                        SET @SkippedCount += 1;
                        SET @SkipEmployee = 1;
                    END
                END

                IF @SkipEmployee = 0 AND @PackageTotal <= 0
                BEGIN
                    IF @UpsertMode = 1
                       AND EXISTS (
                            SELECT 1
                            FROM [dbo].[EmployeePayrollSlip] s
                            WHERE s.[CompanyId] = @CompanyId
                              AND s.[EmployeeId] = @EmployeeId
                              AND s.[PayrollYear] = @PayrollYear
                              AND s.[PayrollMonth] = @PayrollMonth
                              AND s.[DeletedAt] IS NULL
                              AND s.[SlipStatus] NOT IN (N'Approved', N'Void')
                       )
                    BEGIN
                        UPDATE s SET
                            s.[SlipStatus] = N'Skipped',
                            s.[Message] = N'Salary package total is zero.',
                            s.[SalaryPackageId] = @SalaryPackageId,
                            s.[PackageTotal] = 0,
                            s.[DailyRate] = 0,
                            s.[PayableAmount] = 0,
                            s.[UpdatedAt] = GETDATE()
                        FROM [dbo].[EmployeePayrollSlip] s
                        WHERE s.[CompanyId] = @CompanyId
                          AND s.[EmployeeId] = @EmployeeId
                          AND s.[PayrollYear] = @PayrollYear
                          AND s.[PayrollMonth] = @PayrollMonth
                          AND s.[DeletedAt] IS NULL
                          AND s.[SlipStatus] NOT IN (N'Approved', N'Void');
                    END
                    ELSE IF NOT EXISTS (
                        SELECT 1
                        FROM [dbo].[EmployeePayrollSlip] s
                        WHERE s.[CompanyId] = @CompanyId
                          AND s.[EmployeeId] = @EmployeeId
                          AND s.[PayrollYear] = @PayrollYear
                          AND s.[PayrollMonth] = @PayrollMonth
                          AND s.[DeletedAt] IS NULL
                          AND s.[SlipStatus] <> N'Void'
                    )
                    BEGIN
                        INSERT INTO [dbo].[EmployeePayrollSlip] (
                            [PayrollBatchId], [CompanyId], [EmployeeId], [EmploymentId], [SalaryPackageId],
                            [PayslipNumber], [PayslipDate], [PayrollYear], [PayrollMonth], [CurrencyCode],
                            [EmployeeName], [EmployeeNationalId], [PackageTotal], [DailyRate],
                            [PresentDays], [WeekendDays], [HolidayDays], [PayableAmount],
                            [SlipStatus], [Message], [CreatedAt])
                        VALUES (
                            @PayrollBatchId, @CompanyId, @EmployeeId, @EmploymentId, @SalaryPackageId,
                            @PayslipNumber, CAST(GETDATE() AS DATE), @PayrollYear, @PayrollMonth, @PackageCurrency,
                            @EmployeeName, @EmployeeNationalId, 0, 0,
                            0, 0, 0, 0,
                            N'Skipped', N'Salary package total is zero.', GETDATE());
                    END

                    SET @SkippedCount += 1;
                    SET @SkipEmployee = 1;
                END

                IF @SkipEmployee = 0
                BEGIN
                    SET @WorkDate = @PeriodStart;
                    SET @PresentDays = 0;
                    SET @WeekendDays = 0;
                    SET @HolidayDays = 0;

                    WHILE @WorkDate <= @PeriodEnd
                    BEGIN
                        IF @WorkDate >= @JoiningDate AND (@LeavingDate IS NULL OR @WorkDate <= @LeavingDate)
                        BEGIN
                            SET @WDPerWeek = NULL;

                            SELECT TOP (1) @WDPerWeek = cb.[WorkingDaysPerWeek]
                            FROM [dbo].[EmployeeCompanyBatchHistory] h
                            INNER JOIN [dbo].[CompanyBatch] cb ON cb.[CompanyBatchId] = h.[CompanyBatchId]
                            WHERE h.[EmploymentId] = @EmploymentId
                              AND h.[DeletedAt] IS NULL
                              AND cb.[DeletedAt] IS NULL
                              AND h.[EffectiveFrom] <= @WorkDate
                              AND (h.[EffectiveTo] IS NULL OR h.[EffectiveTo] >= @WorkDate)
                            ORDER BY h.[EffectiveFrom] DESC;

                            IF @WDPerWeek IS NOT NULL
                            BEGIN
                                IF dbo.udf_Payroll_IsBatchWeekend(@WDPerWeek, @WorkDate) = 1
                                    SET @WeekendDays += 1;
                                ELSE IF dbo.udf_Payroll_ResolveDayType(@CompanyId, @WorkDate, @DefaultCountryIso2) = 3
                                    SET @HolidayDays += 1;
                                ELSE IF EXISTS (
                                    SELECT 1
                                    FROM [dbo].[EmployeeAttendance] a
                                    WHERE a.[EmployeeId] = @EmployeeId
                                      AND a.[CompanyId] = @CompanyId
                                      AND a.[WorkDate] = @WorkDate
                                      AND a.[DeletedAt] IS NULL
                                )
                                    SET @PresentDays += 1;
                            END
                        END

                        SET @WorkDate = DATEADD(DAY, 1, @WorkDate);
                    END

                    SET @DailyRate = ROUND(@PackageTotal / NULLIF(@DaysDivisor, 0), 4);
                    SET @PaidDays = @PresentDays + @WeekendDays + @HolidayDays;
                    SET @PayableAmount = ROUND(@DailyRate * @PaidDays, 2);

                    SET @ExistingSlipId = NULL;
                    SELECT @ExistingSlipId = s.[EmployeePayrollSlipId]
                    FROM [dbo].[EmployeePayrollSlip] s
                    WHERE s.[CompanyId] = @CompanyId
                      AND s.[EmployeeId] = @EmployeeId
                      AND s.[PayrollYear] = @PayrollYear
                      AND s.[PayrollMonth] = @PayrollMonth
                      AND s.[DeletedAt] IS NULL
                      AND s.[SlipStatus] <> N'Void';

                    IF @ExistingSlipId IS NOT NULL
                    BEGIN
                        IF @UpsertMode = 0
                           OR EXISTS (
                                SELECT 1
                                FROM [dbo].[EmployeePayrollSlip] s
                                WHERE s.[EmployeePayrollSlipId] = @ExistingSlipId
                                  AND s.[SlipStatus] IN (N'Approved', N'Void')
                           )
                        BEGIN
                            SET @SkippedCount += 1;
                            SET @SkipEmployee = 1;
                        END

                        IF @SkipEmployee = 0
                        BEGIN
                            UPDATE [dbo].[EmployeePayrollSlip]
                            SET [PayrollBatchId] = @PayrollBatchId,
                                [SalaryPackageId] = @SalaryPackageId,
                                [PayslipDate] = CAST(GETDATE() AS DATE),
                                [CurrencyCode] = @PackageCurrency,
                                [EmployeeName] = @EmployeeName,
                                [EmployeeNationalId] = @EmployeeNationalId,
                                [PackageTotal] = @PackageTotal,
                                [DailyRate] = @DailyRate,
                                [PresentDays] = @PresentDays,
                                [WeekendDays] = @WeekendDays,
                                [HolidayDays] = @HolidayDays,
                                [PayableAmount] = @PayableAmount,
                                [SlipStatus] = N'Ready',
                                [Message] = NULL,
                                [UpdatedAt] = GETDATE()
                            WHERE [EmployeePayrollSlipId] = @ExistingSlipId;

                            DELETE FROM [dbo].[EmployeePayrollSlipLine]
                            WHERE [EmployeePayrollSlipId] = @ExistingSlipId;

                            INSERT INTO [dbo].[EmployeePayrollSlipLine] (
                                [EmployeePayrollSlipId], [PayrollComponentId], [Amount], [SortOrder], [CreatedAt])
                            SELECT
                                @ExistingSlipId,
                                l.[PayrollComponentId],
                                l.[Amount],
                                ISNULL(pc.[SortOrder], 0),
                                GETDATE()
                            FROM [dbo].[EmployeeSalaryPackageLine] l
                            LEFT JOIN [dbo].[PayrollComponent] pc ON pc.[PayrollComponentId] = l.[PayrollComponentId]
                            WHERE l.[SalaryPackageId] = @SalaryPackageId
                              AND l.[DeletedAt] IS NULL
                              AND l.[Amount] > 0
                            ORDER BY ISNULL(pc.[SortOrder], 0), l.[SalaryPackageLineId];
                        END
                    END
                    ELSE
                    BEGIN
                        INSERT INTO [dbo].[EmployeePayrollSlip] (
                            [PayrollBatchId], [CompanyId], [EmployeeId], [EmploymentId], [SalaryPackageId],
                            [PayslipNumber], [PayslipDate], [PayrollYear], [PayrollMonth], [CurrencyCode],
                            [EmployeeName], [EmployeeNationalId], [PackageTotal], [DailyRate],
                            [PresentDays], [WeekendDays], [HolidayDays], [PayableAmount],
                            [SlipStatus], [CreatedAt])
                        VALUES (
                            @PayrollBatchId, @CompanyId, @EmployeeId, @EmploymentId, @SalaryPackageId,
                            @PayslipNumber, CAST(GETDATE() AS DATE), @PayrollYear, @PayrollMonth, @PackageCurrency,
                            @EmployeeName, @EmployeeNationalId, @PackageTotal, @DailyRate,
                            @PresentDays, @WeekendDays, @HolidayDays, @PayableAmount,
                            N'Ready', GETDATE());

                        SET @NewSlipId = SCOPE_IDENTITY();

                        INSERT INTO [dbo].[EmployeePayrollSlipLine] (
                            [EmployeePayrollSlipId], [PayrollComponentId], [Amount], [SortOrder], [CreatedAt])
                        SELECT
                            @NewSlipId,
                            l.[PayrollComponentId],
                            l.[Amount],
                            ISNULL(pc.[SortOrder], 0),
                            GETDATE()
                        FROM [dbo].[EmployeeSalaryPackageLine] l
                        LEFT JOIN [dbo].[PayrollComponent] pc ON pc.[PayrollComponentId] = l.[PayrollComponentId]
                        WHERE l.[SalaryPackageId] = @SalaryPackageId
                          AND l.[DeletedAt] IS NULL
                          AND l.[Amount] > 0
                        ORDER BY ISNULL(pc.[SortOrder], 0), l.[SalaryPackageLineId];
                    END

                    IF @SkipEmployee = 0
                        SET @SuccessCount += 1;
                END
            END TRY
            BEGIN CATCH
                SET @FailureCount += 1;
                SET @EmpErr = ERROR_MESSAGE();
                SET @ErrorNumber = ERROR_NUMBER();
                SET @ErrorLine = ERROR_LINE();

                EXEC [dbo].[usp_Payroll_LogError]
                    @PayrollRunId, @PayrollRunCompanyId, @PayrollBatchId,
                    @EmploymentId, @EmployeeId, N'SP', @EmpErr,
                    @ErrorNumber, @ErrorLine;
            END CATCH

            FETCH NEXT FROM emp_cursor INTO @EmploymentId, @EmployeeId, @JoiningDate, @LeavingDate;
        END

        CLOSE emp_cursor;
        DEALLOCATE emp_cursor;

        UPDATE [dbo].[PayrollBatch]
        SET [BatchStatus] = N'Completed',
            [SuccessCount] = @SuccessCount,
            [SkippedCount] = @SkippedCount,
            [FailureCount] = @FailureCount,
            [ProcessedAt] = GETDATE(),
            [UpdatedAt] = GETDATE(),
            [ErrorSummary] = NULL
        WHERE [PayrollBatchId] = @PayrollBatchId;

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRAN;

        SET @ErrMsg = ERROR_MESSAGE();
        SET @ErrorNumber = ERROR_NUMBER();
        SET @ErrorLine = ERROR_LINE();

        UPDATE [dbo].[PayrollBatch]
        SET [BatchStatus] = N'Failed',
            [ErrorSummary] = LEFT(@ErrMsg, 2000),
            [UpdatedAt] = GETDATE()
        WHERE [PayrollBatchId] = @PayrollBatchId;

        EXEC [dbo].[usp_Payroll_LogError]
            @PayrollRunId, @PayrollRunCompanyId, @PayrollBatchId,
            NULL, NULL, N'SP', @ErrMsg,
            @ErrorNumber, @ErrorLine;

        ;THROW 50000, @ErrMsg, 1;
    END CATCH
END
GO
