import time
import datetime


tag = 'macd'
signal_line = 1
avarange_line = 0
num_candles_req = 5

def get_data(qpProvider):
    bb_candles = []

    data = qpProvider.GetNumCandles(tag)

    num_candles = data['data']

    start_candles = num_candles - num_candles_req

    macd_candles = []

    data = qpProvider.GetCandles(tag, signal_line, start_candles, 0)

    data = data['data']
    for x in data:
        d = {}

        d['datetime'] = datetime.datetime(x['datetime']['year'],
                                          x['datetime']['month'],
                                          x['datetime']['day'],
                                          x['datetime']['hour'],
                                          x['datetime']['min'],
                                          x['datetime']['sec'])

        d['signal_line'] = x['open']

        macd_candles.append(d)

    data = qpProvider.GetCandles(tag, avarange_line, start_candles, 0)
    data = data['data']
    for i, x in enumerate(data):
        macd_candles[i]['avarange_line'] = x['open']

    return macd_candles


