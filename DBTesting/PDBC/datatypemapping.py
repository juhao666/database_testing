# coding=utf-8
# !
# -------------------------------------------------------------------------------
# Description :Data type mapping between python and RDBMS (MSSQL,MySQL,Oracle,etc...)
#
# Pre-requests: json
# History     :
# DATE        AUTHOR          DESCRIPTION
# ----------  ----------      ----------------------------------------------------
# 01/17/2018  - eliu2         - created
#
# @CopyRight  :
# -------------------------------------------------------------------------------
from PDBC import db

python_mssql = {"int": "INT",
                "Decimal": "MONEY",
                "str": "VARCHAR(MAX)",
                "datetime": "DATETIME",
                "bool": "bit"
                }

python_mysql = None

python_oracle = {"int": "NUMBER",
                 "str": "VARCHAR2(2000)",
                 "datetime": "DATE"
                 }

python_format = {"int": "%d",
                 "Decimal": "%s",
                 "str": "%s",
                 "datetime": "%s",
                 "bool": "%d"
                 }


def database_data_type(py_type, db_type):
    if db_type == db.MSSQL:
        return python_mssql[py_type]
    elif db_type == db.ORACLE:
        return python_oracle[py_type]
    elif db_type == db.MYSQL:
        return None
    else:
        return None


def data_type_format(py_type):
    return python_format[py_type]