# coding=utf-8
# !
# -------------------------------------------------------------------------------
# Description :Test cases configuration
#
# Pre-requests: json
# History     :
# DATE        AUTHOR          DESCRIPTION
# ----------  ----------      ----------------------------------------------------
# 01/16/2018  - eliu2         - created
#
# @CopyRight  :
# -------------------------------------------------------------------------------
from SPTest.testcases import assert_sp

"""
name:a function name
timeout:time out
args:a tuple, function parameters
"""
t = [dict(name=assert_sp, timeout=None, args=('dbo.rpt_CurrentInventoryListing_BY_eliu2','dbo.rpt_CurrentInventoryListing', (310001, None,))),
     dict(name=assert_sp, timeout=25, args=('dbo.rpt_EventNoticeForCreditBalance_BY_eliu2','dbo.rpt_EventNoticeForCreditBalance', ())),
     dict(name=assert_sp, timeout=None, args=('dbo.rpt_PercentageOfRevenue_BY_eliu2', 'dbo.rpt_PercentageOfRevenue', ('01/01/2017', '01/31/2017', 20,))),
     dict(name=assert_sp, timeout=None, args=('dbo.rpt_StatementDetailTotals_BY_eliu2', 'dbo.rpt_StatementDetailTotals', (200003, '200003-089', '10/06/2015', 84,))),
     dict(name=assert_sp, timeout=None, args=('dbo.rpt_TransactionDetailByAgent_BY_eliu2', 'dbo.rpt_TransactionDetailByAgent', ('200003-089', 200003, None, '01/01/2016', '09/30/2016', None,))),
     dict(name=assert_sp, timeout=100, args=('dbo.rpt_internetsales_BY_eliu2', 'dbo.rpt_internetsales', (None, 2017,))),
     ]


def test_cases():
    return t

