#!/usr/bin/python3.8

import datetime
import sys
import os
import re
import calendar

home = "/home/ubuntu/"
mysql_user = "ubuntu"
mysql_password = "password"
days = ["Saturday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November",
          "December"]
is_month_numeric = int(datetime.datetime.now().strftime("%m").lstrip("0").replace(" 0", " "))
is_month = months[is_month_numeric]
is_day = int(datetime.datetime.now().strftime("%d").lstrip("0").replace(" 0", " "))
is_year = int(datetime.datetime.now().strftime("%Y").lstrip("0").replace(" 0", " "))
is_day_literal = datetime.datetime.today().strftime("%A")
is_last_day_of_month = calendar.monthrange(is_year, is_month_numeric)[1]
cntr = 0


if len(sys.argv) <= 0:
    print(is_day_literal)
    print(f"Running in auto mode - using backup mysql settings for {is_day_literal} at ", datetime.datetime.now())
    print("")
else:

    print(is_day_literal)
    print(f"Running in Manual mode - using backup mysql settings for {is_day_literal} at ", datetime.datetime.now())
    print("")

cntr = 0

dbs = "psql -c ';SELECT datname FROM pg_database WHERE datistemplate = false;'"

result = os.popen(dbs).read().split("\n")

for today_is in days:
    print(today_is)
    print(is_day_literal)    
    if today_is == is_day_literal:
        syntax_ok = 1

        backup_day = is_day_literal

        print(backup_day)

        backup_level = cntr

        print(f"Backup Mysql day selected is ${backup_day}, using level {backup_level}")

        print(" ")

    cntr += 1

last_day_of_month = calendar.monthrange(2019, 8)[1]
if not (os.path.isdir(f"{home}/{is_year}/")):
    is_previous_year = is_year - 1
    if (os.path.isdir(f"{home}/{is_previous_year}/")):
        os.system(f"gzip -f {is_previous_year}")

if not (os.path.isdir(f"{home}/{is_year}")):
    os.mkdir(f"{home}/{is_year}")

if not (os.path.isdir(f"{home}/{is_year}/{is_month}")):
    os.mkdir(f"{home}/{is_year}/{is_month}")

if not (os.path.isdir(f"{home}/{is_year}/{is_month}/{is_day}")):
    os.mkdir(f"{home}/{is_year}/{is_month}/{is_day}")

is_full_path = f"{home}/{is_year}/{is_month}/{is_day}"
for db in result:
    print(db)

    database = db
    database = database.strip()

    if database != "datname" and bool(re.match("^[1-9 a-z A-Z]", database)):

        backup_file = f"{is_full_path}/{database.strip()}.sql"

        if backup_level == "0":
            print("Rotating previous backup files & Compressing ...")

            if os.path.exists(f"{backup_file}.3.gz"):
                print("Backing up 4rd file")
                os.system(f"mv {backup_file}.3.gz {backup_file}.4.gz")
                os.system(f"mv {backup_file}.2.gz {backup_file}.3.gz")
                os.system(f"mv {backup_file}.1.gz {backup_file}.2.gz")
                os.system(f"mv {backup_file} {backup_file}.1")
                os.system(f"gzip -f {backup_file}.1")

            elif os.path.exists(f"{backup_file}.2.gz"):
                print("Backing up 3rd file")
                os.system(f"mv {backup_file}.2.gz {backup_file}.3.gz")
                os.system(f"mv {backup_file}.1.gz {backup_file}.2.gz")
                os.system(f"mv {backup_file} {backup_file}.1")
                os.system(f"gzip -f {backup_file}.1")

            elif os.path.exists(f"{backup_file}.1.gz"):
                print("Backing up 2nd file")
                os.system(f"mv {backup_file}.1.gz {backup_file}.2.gz")
                os.system(f"mv {backup_file} {backup_file}.1")
                os.system(f"gzip -f {backup_file}.1")

            elif os.path.exists(backup_file):
                print("Backing up 1st file")
                os.system(f"mv {backup_file} {backup_file}.1")
                os.system(f"gzip -f {backup_file}.1")

        print("")
        print(f"Backing up Mysql {database} on host marapp1 ...")
        print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
        print(database)
        print(backup_file)
        os.system(f"pg_dump {database} > {backup_file}")





