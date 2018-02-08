# coding=utf-8
# !
# -------------------------------------------------------------------------------
# Description : a public tool for calculating the program/function running time
# Author      : eliu2

# History     :
# DATE        AUTHOR          DESCRIPTION
# ----------  ----------      ----------------------------------------------------
# 01/11/2018  eliu2           initial
# --------------------------------------------------------------------------------
from datetime import datetime

TIMEUSED = 0  # a global variable: the elapsed time of a function calling


def timeinterval(func):
    def _call(*args, **kwargs):
        start = datetime.now()
        t = func(*args, **kwargs)
        end = datetime.now()
        global TIMEUSED
        TIMEUSED = (end - start).seconds
        return t
    return _call
