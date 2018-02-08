# coding=utf-8
# !
# -------------------------------------------------------------------------------
# Description : Test Case for rpt_TransactionDetailByAgent
# Author      : eliu2

# History     :
# DATE        AUTHOR          DESCRIPTION
# ----------  ----------      ----------------------------------------------------
# 01/02/2018  eliu2           initial
# --------------------------------------------------------------------------------
from SPTest import perftest


def rpt_TransactionDetailByAgent(spName1, spName2, params):
    perftest.compare2SPs(spName1, spName2, params)


