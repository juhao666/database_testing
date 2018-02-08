# coding=utf-8
# !
# -------------------------------------------------------------------------------
# Description : Test Database Connection
# Author      : eliu2

# History     :
# DATE        AUTHOR          DESCRIPTION
# ----------  ----------      ----------------------------------------------------
# 01/02/2018  eliu2           initial
# --------------------------------------------------------------------------------
from PDBC.PyMSSQL import PyMSSQL
from PDBC.table import Table


def output(s, p, t):
    print(s)
    print(p)
    print(t)


def test():
    conn = PyMSSQL.MSSqlConn()
    res_list = conn.select("select top 10 * FROM dbo.DBCodesTestResults")
    print(res_list)
    # for rs in res_list:
    #     print(rs)
    # t = Table("DBCodesTestResults",res_list)
    # print(t.sql_create)
    # print(t.sql_insert)

    # sql = "INSERT INTO TestCase_rpt_CurrentInventoryListing_BY_eliu2(AgentID,InventoryType,OutletID,OutletName,OutletNumber,InventoryID,ItemYear,InventoryItemName,InventoryNumber,ExpirationDate,QtyOnHand,\
    # Serials,Price,IsControlledInventory,Clerk) VALUES(%d,%s,%d,%s,%s,%d,%d,%s,%s,%s,%d,%s,%s,%d,%s)"
    # params = (310001, 'Serialized Inventory', 5487, 'CDFW License and Revenue Branch', '310001-001', 254, 2018, 'Domesticated Game Bird seal (50/book)', '3270', '2018-12-31 00:00:00', 4, '100057-100060', 1.55, 1, 'H, J (jherrera20)')
    # conn.insert(sql,params)