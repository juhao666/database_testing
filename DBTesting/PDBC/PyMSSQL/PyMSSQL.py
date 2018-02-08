# coding=utf-8
# !
# -------------------------------------------------------------------------------
# Description :Python Database Connection for MS-SQL
#
# Pre-requests: json
# History     :
# DATE        AUTHOR          DESCRIPTION
# ----------  ----------      ----------------------------------------------------
# 01/03/2018  - eliu2         - created
#
# @CopyRight  :
# -------------------------------------------------------------------------------
import pymssql
from PDBC import DBParser


class MSSqlConn:
    """
    MS SQL Server database operation, including SQL DML, SP calling, etc...
    """
    host = ""

    def __init__(self):
        self.host = DBParser.ms_hostname
        self.port = DBParser.ms_port
        self.user = DBParser.ms_username
        self.pwd = DBParser.ms_password
        self.db = DBParser.ms_databasename

    def select(self, sql):
        if not self.db:
            raise (NameError, "no database name specified")
        with pymssql.connect(host=self.host, port=self.port, user=self.user, password=self.pwd, database=self.db,
                             charset="utf8") as conn:
            with conn.cursor() as cursor:
                cursor.execute(sql)
                result = cursor.fetchall()
                return result

    def insert(self, sql):
        if not self.db:
            raise (NameError, "no database name specified")
        with pymssql.connect(host=self.host, port=self.port, user=self.user, password=self.pwd, database=self.db,
                             charset="utf8") as conn:
            with conn.cursor(as_dict=True) as cursor:
                cursor.execute(sql)
                conn.commit()
                return cursor.lastrowid

    def insert(self, sql, params):
        if not self.db:
            raise (NameError, "no database name specified")
        with pymssql.connect(host=self.host, port=self.port, user=self.user, password=self.pwd, database=self.db,
                             charset="utf8") as conn:
            with conn.cursor(as_dict=True) as cursor:
                cursor.execute(sql, params)
                conn.commit()
                return cursor.lastrowid

    def insertmany(self, sql, params):
        """
        :param sql:
        :param params: a list of tuple contains data
        :return: True: succeed
        """
        if not self.db:
            raise (NameError, "no database name specified")
        with pymssql.connect(host=self.host, port=self.port, user=self.user, password=self.pwd, database=self.db,
                             charset="utf8") as conn:
            with conn.cursor(as_dict=True) as cursor:
                cursor.executemany(sql, params)
                conn.commit()
                return True

    def update(self, sql):
        if not self.db:
            raise (NameError, "no database name specified")
        with pymssql.connect(host=self.host, port=self.port, user=self.user, password=self.pwd, database=self.db,
                             charset="utf8") as conn:
            with conn.cursor(as_dict=True) as cursor:
                cursor.execute(sql)
                conn.commit()

    def callsp(self, sp_name, params):
        if not self.db:
            raise (NameError, "no database name specified")
        with pymssql.connect(host=self.host, port=self.port, user=self.user, password=self.pwd, database=self.db,
                             charset="utf8") as conn:
            # with conn.cursor(as_dict=True) as cursor:
            with conn.cursor() as cursor:
                cursor.callproc(sp_name, params)
                # for row in cursor:
                # print(row)
                rs = [row for row in cursor]
                return rs
                # return cursor.fetchall()

    def exec(self, sql):
        with pymssql.connect(host=self.host, port=self.port, user=self.user, password=self.pwd, database=self.db,
                             charset="utf8") as conn:
            with conn.cursor(as_dict=True) as cursor:
                cursor.execute(sql)
                conn.commit()

    if __name__ == '__main__':
        print(host)
