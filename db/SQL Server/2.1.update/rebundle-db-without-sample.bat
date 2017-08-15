@echo off
bundler\SqlBundler.exe ..\..\..\ "db/SQL Server/2.1.update" false
copy finance-blank-2.1.update.sql ..\finance-blank-2.1.update.sql