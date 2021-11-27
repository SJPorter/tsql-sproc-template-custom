SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE <Schema_Name, sysname, Schema_Name>.<Procedure_Name, sysname, Procedure_Name>
	-- Add the parameters for the stored procedure here
	<@param1, sysname, @p1> <datatype_for_param1, , int> = <default_value_for_param1, , 0>, 
	<@param2, sysname, @p2> <datatype_for_param2, , int> = <default_value_for_param2, , 0>
	
	-- Add return outputs here
	<@param1, sysname, @p1> <datatype_for_param1, , int> = <default_value_for_param1, , 0> OUTPUT,

	-- Keep these for error handling
	@isValid bit output,
	@failureReason varchar(Max) OUTPUT
AS
BEGIN
	SET NOCOUNT ON 

					-- Same schema and sproc name as above, within single quotes
	Declare @source varchar(50) = <Schema_Name, sysname, Schema_Name>.<Procedure_Name, sysname, Procedure_Name>
	Declare @area varchar(50) = 'Exception' 
	Declare @errorType varchar(50) = 'UNKNOWNEXCEPTION'
	Declare @inTransaction bit = 0

	BEGIN TRY
		if (@tagsJson is not null and isJson(@tagsJson) = 0)
		Begin
			set @failureReason = 'The tags are not formatted as valid json'
			return
		End
	
		if (@notes is not null and isJson(@notes) = 0)
		Begin
			set @failureReason = 'The notes are not formatted as valid json'
			return
		End

		BEGIN TRAN
		set @inTransaction = 1

----------- PARAMETER VALIDATION HERE
		set @failureReason = 'All parameters are required to be provided' -- something like that etc
		if (<@param1> is null) return
		if (<@param2> is null) return

		--- SIMILAR TO THIS
		--if (not exists(select 1 from abacusAccounts.AccountTypes where AccountTypeName = @accountType))
		--Begin
		--	set @failureReason = 'Account Type is invalid'  -- something like that etc
		--	return
		--End



---------- REAL CODE BEGINS HERE








-- TRANSACTION RELATED CODE ENDS HERE.  
-- IF TRANSACTION NOT NEEDED, REMOVE.  
-- DO NOT FORGET ABOUT THE ROLLBACK IN THE CATCH
			set @isValid = 1
			set @failureReason = ''
		COMMIT
	END TRY
	BEGIN CATCH
		if (@inTransaction = 1) ROLLBACK

		set @isValid = 0
		set @failureReason = Concat('Sql Error (', ERROR_NUMBER(), '): ', ERROR_MESSAGE())
		
		exec [abacusUsers].[usp__InsertErrorLogEntry] 
			@area = @area, 
			@errorType = @errorType,     
			@sourceJSON = @source, 
			@errorJSON = @failureReason
		return 
	END CATCH
END
