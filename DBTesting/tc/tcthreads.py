# coding=utf-8
# !
# -------------------------------------------------------------------------------
# Description : my threading
# Author      : eliu2

# History     :
# DATE        AUTHOR          DESCRIPTION
# ----------  ----------      ----------------------------------------------------
# 01/17/2018  eliu2           initial
# --------------------------------------------------------------------------------
import threading


class TcThread(threading.Thread):
    def __init__(self, f=None, timeout=120, name=None):
        super(TcThread, self).__init__()
        self.stopped = False
        self.timeout = timeout
        self.f = f
        self.name = name

    def run(self):
        child_thread = threading.Thread(target=self.f, args=())
        child_thread.setDaemon(True)
        child_thread.start()
        print('Test Case {} is running'.format(self.name))
        while not self.stopped:
            child_thread.join(self.timeout)

    def stop(self):
        self.stopped = True


def run(test_cases):
    for tc in test_cases:
        f = tc['name']
        timeout = tc['timeout']
        f_name = f.__name__
        thread = TcThread(f, timeout, f_name)
        thread.start()
        if timeout:
            thread.join(timeout)
            thread.stop()
            if thread.isAlive:
                print('Test Case {} is timed out ({} seconds limitation)...'.format(f_name, timeout))
