@echo off
bundler\SqlBundler.exe ..\..\..\ "db/PostgreSQL/2.1.update" false
copy finance-blank-2.1.update.sql ..\finance-blank-2.1.update.sql