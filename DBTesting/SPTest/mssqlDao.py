# coding=utf-8
# !
# -------------------------------------------------------------------------------
# Description : MSSQL DAO module
# Author      : eliu2

# History     :
# DATE        AUTHOR          DESCRIPTION
# ----------  ----------      ----------------------------------------------------
# 01/02/2018  eliu2           initial
# --------------------------------------------------------------------------------
from PDBC.PyMSSQL import PyMSSQL
from tc import tcTime


@tcTime.timeinterval
def callsp(sp, paras):
    conn = PyMSSQL.MSSqlConn()
    rs = conn.callsp(sp, paras)
    return rs


def insert(sql, params):
    conn = PyMSSQL.MSSqlConn()
    # spname = params[0]
    # interval = params[1]
    # val = params[2]
    # dt = params[3]
    # newid = conn.insert(sql.format(spname, interval, val, dt))
    newid = conn.insert(sql, params)
    return newid


def insertmany(sql, params):
    dao = PyMSSQL.MSSqlConn()
    newid = dao.insertmany(sql, params)
    return newid


def update(sql, params):
    conn = PyMSSQL.MSSqlConn()
    spname = params[0]
    interval = params[1]
    dt = params[2]
    pk = params[3]
    conn.update(sql.format(spname, interval, dt, pk))


def exist(o, o_type):
    """
     Object type:
     AF = Aggregate function (CLR)
     C = CHECK constraint
     D = DEFAULT (constraint or stand-alone)
     F = FOREIGN KEY constraint
     FN = SQL scalar function
     FS = Assembly (CLR) scalar-function
     FT = Assembly (CLR) table-valued function
     IF = SQL inline table-valued function
     IT = Internal table
     P = SQL Stored Procedure
     PC = Assembly (CLR) stored-procedure
     PG = Plan guide
     PK = PRIMARY KEY constraint
     R = Rule (old-style, stand-alone)
     RF = Replication-filter-procedure
     S = System base table
     SN = Synonym
     SO = Sequence object
     U = Table (user-defined)
     V = View
    :param o:
    :param o_type:
    :return:
    """
    conn = PyMSSQL.MSSqlConn()
    rs = conn.select("select name from sys.objects where name = '{}' and type ='{}'".format(o, o_type))
    # if rs is not None and len(rs) > 0:
    if rs:
        return True
    else:
        return False


def drop_table_if_exist(name):
    if not exist(name, 'U'):
        return
    conn = PyMSSQL.MSSqlConn()
    conn.exec('drop table ' + name)


def create_table(sql):
    conn = PyMSSQL.MSSqlConn()
    conn.exec(sql)


def clear_cache():
    ddl = """DECLARE @DBID INT =DB_ID()
    DBCC FLUSHPROCINDB (@DBID)"""
    conn = PyMSSQL.MSSqlConn()
    conn.exec(ddl)