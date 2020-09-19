
IF EXISTS(SELECT [name] FROM tempdb.sys.tables WHERE [name] like '#FileSizes%') 
BEGIN
   DROP TABLE #FileSizes;
END;
create  table #FileSizes (DBName sysname, [File Name] varchar(max), [Physical Name] varchar(max),
Size decimal(12,2))
declare @SQL nvarchar(max)
set @SQL = ''
select @SQL = @SQL + 'USE'  + QUOTENAME(name) + '
insert into #FileSizes
select ' + QUOTENAME(name,'''') + ', Name, Physical_Name, size/1024.0 from sys.database_files ' 
from sys.databases
--where name NOT IN ('master','tempdb','model','msdb','SSISDB')
--where name IN ('<someDBName')
Select @SQL
execute (@SQL)
select * from #FileSizes order by DBName, [File Name]

DECLARE @DBName varchar(256)
DECLARE @LogicalName varchar(max)
DECLARE @PhysicalName varchar(max)
DECLARE @Command nvarchar(200)

DECLARE Test CURSOR LOCAL FAST_FORWARD FOR
select DBName, [File Name], [Physical Name] from #FileSizes2 order by DBName, [File Name]
OPEN Test

FETCH NEXT FROM Test INTO @DBName, @LogicalName, @PhysicalName

WHILE @@FETCH_STATUS = 0
BEGIN
	SELECT @Command = N'USE master' +
                     ' EXEC sp_executesql N''ALTER DATABASE' + QUOTENAME(@DBName) + ' SET EMERGENCY; ' + ' PRINT ''''Set Emergency'''' '''
  SELECT @Command
  EXEC sp_executesql @Command
  SELECT @Command = N'USE master' +
                     ' EXEC sp_executesql N''ALTER DATABASE' + QUOTENAME(@DBName) + ' SET SINGLE_USER; ' + ' PRINT ''''Set Single User'''' '''
  SELECT @Command
  EXEC sp_executesql @Command
  SELECT @Command = N'USE master' +
                     ' EXEC sp_executesql N''ALTER DATABASE' + QUOTENAME(@DBName) + ' SET MULTI_USER; ' + ' PRINT ''''Set Multi-user'''' '''
  SELECT @Command
  EXEC sp_executesql @Command
  SELECT @Command = N'USE master' +
                     ' EXEC sp_executesql N''ALTER DATABASE' + QUOTENAME(@DBName) + ' SET ONLINE; ' + ' PRINT ''''Set Online'''' '''
  SELECT @Command
  EXEC sp_executesql @Command
FETCH NEXT FROM Test INTO @DBName, @LogicalName, @PhysicalName
END

CLOSE test
DEALLOCATE test