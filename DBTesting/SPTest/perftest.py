# coding=utf-8
# !
# -------------------------------------------------------------------------------
# Description : compare two procedures for performance
# Author      : eliu2

# History     :
# DATE        AUTHOR          DESCRIPTION
# ----------  ----------      ----------------------------------------------------
# 01/11/2018  eliu2           initial
# --------------------------------------------------------------------------------
from tc import tcTime
from datetime import datetime
from SPTest import mssqlDao
from PDBC.table import Table


def compare2SPs(spName1, spName2, params):
    """
    The function calls 2 store procedures, and compare whether the 2 result sets are same.
    """
    """Test Program after optimization"""
    print('[INFO]:  Test Case {} is running'.format(spName2))
    rs1 = mssqlDao.callsp(spName1, params)
    interval1 = tcTime.TIMEUSED
    sql = "INSERT INTO DBCodesTestResults(ProgramName1,ElapsedTime1,ParameterValues,CreatedDT) \
           VALUES(%s,%d,%s,%s)"
    # spParams = (spName1, interval1, str(params).replace("'", "''").replace('None', 'NULL'),str(datetime.now())[0:-3])
    spParams = (spName1, interval1, str(params).replace('None', 'NULL'), str(datetime.now())[0:-3])
    newid = mssqlDao.insert(sql, spParams)
    # clear the dataase cache
    mssqlDao.clear_cache()
    """Test Program before optimization"""
    if spName2 is not None:
        rs2 = mssqlDao.callsp(spName2, params)
        interval2 = tcTime.TIMEUSED
        sql = "UPDATE DBCodesTestResults SET ProgramName2='{}',ElapsedTime2 = {} ,ModifiedDT = '{}' WHERE PKID= {}"
        spParams = (spName2, interval2, str(datetime.now())[0:-3], newid)
        mssqlDao.update(sql, spParams)
        if _eq(rs1, rs2):
            str_output = '[INFO]:  Test Case {} completed successfully! [{}s VS {}s]'
        else:
            str_output = '[ERROR]: Test Case {} completed with error!'
    print(str_output.format(spName2, interval1, interval2))


def _eq(list1, list2):
    """
    Convert list to set, if the intersection of 2 set is None, that means the 2 sets(lists) are equal.
    :param list1: a list
    :param list2: a list
    :return:
    """
    if bool(set(list1) - set(list2)):
        is_equal = False
    else:
        is_equal = True
    return is_equal


def _compare2SPs(spName1, spName2, params):
    """
    The function calls 2 store procedures, and stores the result set in database.
    Deprecated.
    """
    """Test Program after optimization"""
    rows1 = mssqlDao.callsp(spName1, params)
    table1 = Table(_table_name(spName1), rows1)
    _prepare_data(table1, rows1)
    interval = tcTime.TIMEUSED
    sql = "INSERT INTO DBCodesTestResults(ProgramName1,ElapsedTime1,ParameterValues,CreatedDT) \
           VALUES(%s,%d,%s,%s)"
    spParams = (spName1, interval, str(params).replace("'", "''").replace('None', 'NULL'),str(datetime.now())[0:-3])
    newid = mssqlDao.insert(sql, spParams)
    """Test Program before optimization"""
    if spName2 is not None:
        rows2 = mssqlDao.callsp(spName2, params)
        table2 = Table(_table_name(spName2), rows2)
        _prepare_data(table2, rows2)
        interval = tcTime.TIMEUSED
        sql = "UPDATE DBCodesTestResults SET ProgramName2='{}',ElapsedTime2 = {} ,ModifiedDT = '{}' WHERE PKID= {}"
        spParams = (spName2, interval, str(datetime.now())[0:-3], newid)
        mssqlDao.update(sql, spParams)
    print('Test Case {} successfully completed!'.format(spName2))


def _prepare_data(table, data):
    """
    persistent records to database.
    :param table: a Table object
    :param data:  a list of dict type, records.
    :return:
    """
    mssqlDao.drop_table_if_exist(table.name)
    mssqlDao.create_table(table.sql_create)
    records = []
    for r in data:
        l_records = [v for k, v in r.items()]

        def data_convert(x):
            data_type = type(x).__name__
            if data_type == "datetime":
                return str(x)
            elif data_type == "bool":
                return 1 if x is True else 0
            elif data_type == "Decimal":
                # assert isinstance(x, object)
                return float(x)
            else:
                return x

        l_records = [(data_convert(l)) for l in l_records]
        params = tuple(l_records)
        records.append(params)
        if len(records) % 500 == 0:
            mssqlDao.insertmany(table.sql_insert, records)
            records = []
    mssqlDao.insertmany(table.sql_insert, records)


def _table_name(name):
    if name[0:4] == "dbo.":
        return "TestCase_" + name[4:]
    else:
        return "TestCase_" + name


def _dict_value_2_tuple(a_dict):
    ld = [v for k,v in a_dict.items()]
    return tuple(ld)


