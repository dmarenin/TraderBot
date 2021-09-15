import time
import datetime


tag = 'bb'
lower_line = 2
upper_line = 1
medium_line = 0
num_candles_req = 5

def get_data(qpProvider):
    bb_candles = []

    data = qpProvider.GetNumCandles(tag)

    num_candles = data['data']

    start_candles = num_candles - num_candles_req

    bb_candles = []

    data = qpProvider.GetCandles(tag, lower_line, start_candles, 0)

    data = data['data']
    for x in data:
        d = {}

        d['datetime'] = datetime.datetime(x['datetime']['year'],
                                          x['datetime']['month'],
                                          x['datetime']['day'],
                                          x['datetime']['hour'],
                                          x['datetime']['min'],
                                          x['datetime']['sec'])

        d['lower_line'] = int(x['open'])

        bb_candles.append(d)

    data = qpProvider.GetCandles(tag, upper_line, start_candles, 0)
    data = data['data']
    for i, x in enumerate(data):
        bb_candles[i]['upper_line'] = x['open']

    data = qpProvider.GetCandles(tag, medium_line, start_candles, 0)
    data = data['data']
    for i, x in enumerate(data):
        bb_candles[i]['medium_line'] = x['open']

    return bb_candles


