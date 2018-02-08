# coding=utf-8
# !
# -------------------------------------------------------------------------------
# Description :Table handler
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
from PDBC.column import Column


class Table():
    """
    The rs should be dict, normally, which is a result set from cursor.fetchAll
    """
    def __init__(self, name, rs=None, db_type=db.MSSQL):
        self.name = name
        self.rs = rs
        self.db_type = db_type
        self.sql_create = None
        self.sql_insert = None
        self._parse()

    def columns(self):
        """
        return a list of object Column, Column cantains column name and data type.
        """
        if self.rs is None:
            raise (NameError, 'No table column found')
        rs_row_1 = self.rs[0]
        keys = list(rs_row_1.keys())
        cols = []  # list of object Column
        for key in keys:
            key_type = type(rs_row_1[key]).__name__
            t = (key, key_type)
            cols.append(Column(t))
        return cols

    # @property
    # def sql_create(self):
    #     """
    #     Return the create DDL
    #     """
    #     table_columns = self.columns()
    #     col_clause = ""
    #     for table_column in table_columns:
    #         col_clause += "," + table_column.name + "  " + table_column.data_type
    #     if col_clause!= "":
    #         return "CREATE TABLE " + self.name + "(" + col_clause[1:] + ")"

    def _parse(self):
        """
        parse the Column list, generate sql for
        CREATE TABLE
        INSERT INTO
        """
        table_columns = self.columns()
        _sql_create = ""
        _sql_insertinto = ""
        _sql_values = ""
        for table_column in table_columns:
            _sql_create += "," + table_column.name + "  " + table_column.data_type
            _sql_insertinto += "," + table_column.name
            _sql_values += "," + table_column.data_type_format

        if _sql_create != "":
            self.sql_create = "CREATE TABLE " + self.name + "(" + _sql_create[1:] + ")"
        if _sql_insertinto != "" and _sql_values != "":
            self.sql_insert = "INSERT INTO " + self.name + "(" + _sql_insertinto[1:] + ")" + \
                "VALUES(" + _sql_values[1:] + ")"


