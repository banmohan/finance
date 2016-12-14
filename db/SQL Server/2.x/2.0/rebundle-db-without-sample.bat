@echo off
bundler\SqlBundler.exe ..\..\..\..\ "db/SQL Server/2.x/2.0" false
copy finance.sql finance-blank.sql
del finance.sql
copy finance-blank.sql ..\..\finance-blank.sql