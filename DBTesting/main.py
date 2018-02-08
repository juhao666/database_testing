# coding=utf-8
# !
# -------------------------------------------------------------------------------
# Description :main python
#
# Pre-requests: json
# History     :
# DATE        AUTHOR          DESCRIPTION
# ----------  ----------      ----------------------------------------------------
# 01/12/2018  - eliu2         - created
#
# @CopyRight  :
# -------------------------------------------------------------------------------
import os, sys, multiprocessing
from tcs import test_cases


def process(f, timeout, name, args=None):
    flag = False
    try:
        child_process = multiprocessing.Process(target=f, args=args)
        child_process.start()
        # print('[INFO]:  Test Case {} is running'.format(name))
        child_process.join(timeout)
        if child_process.is_alive():
            child_process.terminate()
            child_process.join()
            flag = True
    except:
        pass
    return flag


def work(test_cases):
    for tc in test_cases:
        f = tc['name']
        timeout = tc['timeout']
        f_name = f.__name__
        args = tc['args']
        terminate = process(f, timeout, f_name,args)
        if terminate:
            print('[WARN]:  Test Case {} is timed out and {} ({} seconds limitation)...\
                  '.format(args[1], 'terminated', timeout))


def output():
    # print(sys.path)
    print('#--------------------------------------------------------------------------------------------#')
    print('#                            Begin running the Test Cases now!!!                             #')
    print('#--------------------------------------------------------------------------------------------#')


if __name__ == '__main__':
    output()
    tcs = test_cases()
    work(tcs)

