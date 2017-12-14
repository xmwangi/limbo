class NullMetrics(object):
    def __init__(self, config={}):
        self._count = 0

    def events(self, count):
        self._count = self._count + count
