import time
import datetime


class Timer(object):
    def __init__(self, name=None):
        self.name = name
        self.tstart = time.time()

    def elapsed(self):
        return str(datetime.timedelta(seconds=round(self.elapsed_seconds())))

    def elapsed_seconds(self):
        return time.time() - self.tstart

    def __enter__(self):
        self.tstart = time.time()

    def __exit__(self, type, value, traceback):
        if self.name:
            print('[%s]' % self.name,)
        print("Elapsed: {}".format(self.elapsed()))
