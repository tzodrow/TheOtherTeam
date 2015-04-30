__author__ = 'tzodrow'


class Helper:

    def __init__(self):
        pass

    @staticmethod
    def pad(value, length):
        zeros = length - len(value)
        if zeros < 0:
            zeros = -zeros
            value = value[zeros:]
        else:
            for x in range(0, zeros):
                value = '0' + value
        return value