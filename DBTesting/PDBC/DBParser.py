# coding=utf-8
# !
# -------------------------------------------------------------------------------
# Description :web xml parsing for database info
#
# Pre-requests: json
# History     :
# DATE        AUTHOR          DESCRIPTION
# ----------  ----------      ----------------------------------------------------
# 01/03/2018  - eliu2         - created
#
# @CopyRight  :
# -------------------------------------------------------------------------------
import os
import json

path = os.path.dirname(__file__)
filename = path + '/conf/db.json'
with open(filename, "r") as json_file:
    doc = json.load(json_file)
    ms_database = doc['mssql']
    ms_type = ms_database['type']
    ms_version = ms_database['version']
    ms_hostname = ms_database['hostname']
    ms_port = ms_database['port']
    ms_username = ms_database['username']
    ms_password = ms_database['password']
    ms_databasename = ms_database['databasename']
    # print(ms_type,ms_version,ms_hostname,ms_port,ms_username,ms_password,ms_databasename)

