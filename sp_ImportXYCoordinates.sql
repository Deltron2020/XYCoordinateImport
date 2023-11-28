IF OBJECT_ID('dbo.sp_ImportXYCoordinates') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.sp_ImportXYCoordinates
END
GO

CREATE PROCEDURE dbo.sp_ImportXYCoordinates (@filePath NVARCHAR(256), @emailAddress NVARCHAR(128))
AS
BEGIN

/*=======================  
Created on 5/15/23 to batch import X/Y Values  - Tyler T

Modified on 9/13/23 - added exception handling - TT
========================*/
--DECLARE @emailAddress NVARCHAR(128) = 'example@gmail.com';
--DECLARE @date NVARCHAR(10) = (SELECT CAST(GETDATE() AS DATE));
--DECLARE @filePath NVARCHAR(256) = '\\network_path'+@date+'_xy_results.csv';

SET NOCOUNT ON;

DECLARE @tran_count_on_entry INT = @@TRANCOUNT,
	@return_value INT = @@ERROR,
	@YearID SMALLINT = (SELECT YearID FROM dbo.xrYearColor WHERE IsCurrentFlag = 1 GROUP BY YearID),
	@sql NVARCHAR(1000),
	@body NVARCHAR(512);

IF OBJECT_ID('tempdb..#xy_LoadLegal') IS NOT NULL
BEGIN;
 DROP TABLE IF EXISTS #xy_LoadLegal
END;

IF OBJECT_ID('tempdb..#Legal_Holding') IS NOT NULL
BEGIN;
 DROP TABLE IF EXISTS #Legal_Holding
END;

BEGIN TRY

	DECLARE @fileExists BIT = (SELECT dbo.doesFileExist (@filePath) as IsExists);

	IF @fileExists = 1
	BEGIN;

		PRINT 'Beginning Bulk Insert'
		CREATE TABLE #xy_LoadLegal (PropertyID INT PRIMARY KEY, X_Coord VARCHAR(50), Y_Coord VARCHAR(50));

		SET @sql = '
		BULK INSERT #xy_LoadLegal
		FROM '''+@filePath+'''   
		WITH (FIELDTERMINATOR = ''|'', ROWTERMINATOR = ''\n'');'

		BEGIN TRY
			EXEC (@sql);
		END TRY

		BEGIN CATCH
			THROW;
		END CATCH
  
	 	IF EXISTS (SELECT * FROM #xy_LoadLegal)
		BEGIN;
			PRINT 'Beginning Trimming Data'
			UPDATE #xy_LoadLegal
			SET PropertyID = LTRIM(RTRIM(PropertyID)),
			X_Coord = LTRIM(RTRIM(X_Coord)),
			Y_Coord = LTRIM(RTRIM(Y_Coord))

			IF (SELECT MIN(ISNUMERIC(PropertyID)) FROM #xy_LoadLegal) = 0
			BEGIN;
				SET @body = 'Data Issue with PropertyID Field - Did Not Pass IsNumeric Check.';
				PRINT @body
				EXEC msdb.dbo.sp_send_dbmail
						@profile_name = 'SQL Alerts',
						@recipients = @emailAddress,
						@body = @body,
						@importance = 'High',
						@subject = 'XY Coordinates Import';
				RETURN;
			END;
			ELSE IF (SELECT MIN(ISNUMERIC(X_Coord)) FROM #xy_LoadLegal) = 0
			BEGIN;
				SET @body = 'Data Issue with X_Coord Field - Did Not Pass IsNumeric Check.';
				PRINT @body
				EXEC msdb.dbo.sp_send_dbmail
					@profile_name = 'SQL Alerts',
					@recipients = @emailAddress,
					@body = @body,
					@importance = 'High',
					@subject = 'XY Coordinates Import';
				RETURN;
			END;
			ELSE IF (SELECT MIN(ISNUMERIC(Y_Coord)) FROM #xy_LoadLegal) = 0
			BEGIN;
				SET @body = 'Data Issue with Y_Coord Field - Did Not Pass IsNumeric Check.';
				PRINT @body
				EXEC msdb.dbo.sp_send_dbmail
					@profile_name = 'SQL Alerts',
					@recipients = @emailAddress,
					@body = @body,
					@importance = 'High',
					@subject = 'XY Coordinates Import';
				RETURN;
			END;
	 	END;

	 	--SELECT * FROM #xy_LoadLegal

	 	IF EXISTS (SELECT * FROM #xy_LoadLegal)
	 	BEGIN;  
			SELECT
				[PropertyID]
			 	,[YearID]
			 	,[ActiveFlag]
			 	,[LegalID]
				,[GISCoordinate1]
				,[GISCoordinate2]
				,[GEOPin]
				,[xrGEONeighborhoodID]
				,[XCoordinate]
				,[YCoordinate]
				,[ZCoordinate]
				,[CensusTract]
				,[AssessorMap]
				,[xrTopographyID]
				,[xrStreetConditionID]
				,[xrTrafficID]
				,[xrHighestAndBestUseID]
				,[DistrictGroupAnnexDate]
				,[PreviousOwnerYear]
				,[PreviousOwnerPercent]
				,[MapBook]
				,[Block]
				,[Lot]
				,[xrSubdivisionID]
				,[Section]
				,[Township]
				,[Range]
				,[xrFloodPlainID]
				,[DeedSize]
				,[xrDeedSizeUOMID]
				,[GISSize]
				,[xrGISSizeUOMID]
				,[ResexPerc]
				,[xrOwnerOccupiedID]
				,[OverrideMixedUseFlag]
				,[CreateUser]
				,[CreateDate]
		 	INTO
		 		#Legal_Holding
		  	FROM
		   		dbo.GetLegalTable(@YearID,1) l
		  	JOIN
		   		(SELECT PropertyID [AIN], X_Coord, Y_Coord FROM #xy_LoadLegal) xy ON xy.AIN = l.PropertyID
	 	END;
  
	 	--SELECT * FROM #Legal_Holding

	 	IF EXISTS (SELECT * FROM #Legal_Holding)
	 	PRINT 'Updating X & Y Values'
	 	BEGIN;
			UPDATE #Legal_Holding
		  	SET XCoordinate = X_Coord,
		   	YCoordinate = Y_Coord,
		   	CreateUser = 'SQLJOB_XY-Import',
		   	CreateDate = GETDATE()
		  	FROM #Legal_Holding lh
		  	JOIN #xy_LoadLegal xy ON xy.PropertyID = lh.PropertyID
	 	END;

	 	--SELECT * FROM #Legal_Holding
  
		PRINT 'Beginning Insert into Legal Table'
		BEGIN TRY
			IF @tran_count_on_entry = 0 BEGIN TRAN;  
  
		  	INSERT INTO dbo.Legal
		  			( 
		  			PropertyID, YearID, ActiveFlag, LegalID, GISCoordinate1, GISCoordinate2, GEOPin, xrGEONeighborhoodID,
					XCoordinate, YCoordinate, ZCoordinate, CensusTract, AssessorMap, xrTopographyID, xrStreetConditionID,
					xrTrafficID, xrHighestAndBestUseID, DistrictGroupAnnexDate, PreviousOwnerYear, PreviousOwnerPercent,
					MapBook, Block, Lot, xrSubdivisionID, Section, Township, Range, xrFloodPlainID, DeedSize, xrDeedSizeUOMID,
					GISSize, xrGISSizeUOMID, ResexPerc, xrOwnerOccupiedID, OverrideMixedUseFlag, CreateUser, CreateDate
					)
  
			SELECT
		   		PropertyID, YearID, ActiveFlag, LegalID, GISCoordinate1, GISCoordinate2, GEOPin, xrGEONeighborhoodID,
		   		XCoordinate, YCoordinate, ZCoordinate, CensusTract, AssessorMap, xrTopographyID, xrStreetConditionID,
		   		xrTrafficID, xrHighestAndBestUseID, DistrictGroupAnnexDate, PreviousOwnerYear, PreviousOwnerPercent,
		   		MapBook, Block, Lot, xrSubdivisionID, Section, Township, Range, xrFloodPlainID, DeedSize, xrDeedSizeUOMID,  
		   		GISSize, xrGISSizeUOMID, ResexPerc, xrOwnerOccupiedID, OverrideMixedUseFlag, CreateUser, CreateDate
		  	FROM
		   		#Legal_Holding
 
		END TRY
		BEGIN CATCH
			PRINT 'Beginning Catch'
			IF @@TRANCOUNT > 0 AND @tran_count_on_entry = 0 ROLLBACK TRAN;

			THROW; -- raise error to the client
		END CATCH

		IF @@TRANCOUNT > 0 AND @tran_count_on_entry = 0 COMMIT TRAN;

		PRINT 'Sending Email'
		SET @body = ('XY Coordinates were successfully imported into ' + CAST((SELECT COUNT(*) FROM #Legal_Holding) AS NVARCHAR(8)) + ' accounts on ' + CAST(GETDATE() AS NVARCHAR));
  
		EXEC msdb.dbo.sp_send_dbmail
		  	@profile_name = 'SQL Alerts',
		  	@recipients = @emailAddress,
		  	@body = @body,
		  	@importance = 'High',
		  	@subject = 'XY Coordinates Import';


		PRINT 'Finished'

		IF OBJECT_ID('tempdb..#xy_LoadLegal') IS NOT NULL
		BEGIN;
	 		DROP TABLE IF EXISTS #xy_LoadLegal
		END;

		IF OBJECT_ID('tempdb..#Legal_Holding') IS NOT NULL
		BEGIN;
	 		DROP TABLE IF EXISTS #Legal_Holding
		END;

	END;
	ELSE

	BEGIN;
		PRINT 'There was no xy coordinates file - Finished'
		RETURN;
	END;

END TRY
BEGIN CATCH

	DECLARE @param_values NVARCHAR(512) =
				(
					SELECT	
						@filePath  AS [file_path],
						@emailAddress AS [email_address],
						@tran_count_on_entry AS [tran_count_on_entry]
					FOR JSON PATH
				);

	EXEC @return_value = dbo.sp_handle_exception
						@client_id = 1, 
						@source_procedure_id = @@PROCID, 
						@additional_info = @param_values;

END CATCH

RETURN @return_value;

END
