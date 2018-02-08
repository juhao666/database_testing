# coding=utf-8
# !
# -------------------------------------------------------------------------------
# Description :column handler
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
from PDBC.datatypemapping import database_data_type
from PDBC.datatypemapping import data_type_format


class Column():
    """
    The obj should be a tuple, which contains column name and data type
    """

    def __init__(self, obj=None, db_type=db.MSSQL):
        self.obj = obj
        self.db_type = db_type
        self.name = self._name()
        self.data_type = self._type()
        self.data_type_format = self._py_format()

    def _name(self):
        return self.obj[0]

    def _type(self):
        return database_data_type(py_type=self.obj[1], db_type=self.db_type)

    def _py_format(self):
        return data_type_format(py_type=self.obj[1])