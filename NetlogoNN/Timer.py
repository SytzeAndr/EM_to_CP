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



if __name__ == "__main__":
    # example usage
    with Timer():
        # insert code here
        s = 0
        for i in range(int(10e7)):
            s += 1
