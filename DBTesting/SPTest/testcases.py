# coding=utf-8
# !
# -------------------------------------------------------------------------------
# Description : Test Cases
# Author      : eliu2

# History     :
# DATE        AUTHOR          DESCRIPTION
# ----------  ----------      ----------------------------------------------------
# 01/09/2018  eliu2           initial
# --------------------------------------------------------------------------------
from SPTest import perftest


def assert_sp(spName1, spName2, params):
    perftest.compare2SPs(spName1, spName2, params)

def assert_var_sp(spName1, spName2, params):
    perftest.compare2SP_var(spName1, spName2, params)

# def rpt_CurrentInventoryListing(spName1, spName2, params):
#     perftest.compare2SPs(spName1, spName2, params)
#
#
# def rpt_EventNoticeForCreditBalance(spName1, spName2, params):
#     perftest.compare2SPs(spName1, spName2, params)
#
#
# def rpt_internetsales(spName1, spName2, params):
#     perftest.compare2SPs(spName1, spName2, params)
#
#
# def rpt_PercentageOfRevenue(spName1, spName2, params):
#     perftest.compare2SPs(spName1, spName2, params)
#
#
# def rpt_StatementDetailTotals(spName1, spName2, params):
#     perftest.compare2SPs(spName1, spName2, params)
#
#
# def rpt_TransactionDetailByAgent(spName1, spName2, params):
#     perftest.compare2SPs(spName1, spName2, params)

