@echo off
bundler\SqlBundler.exe ..\..\..\..\ "db/SQL Server/2.x/2.0" true
copy finance.sql finance-sample.sql
del finance.sql
copy finance-sample.sql ..\..\finance-sample.sql