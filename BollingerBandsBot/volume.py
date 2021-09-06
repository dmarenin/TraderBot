import time
import datetime


tag = 'volume'
num_candles_req = 5


def get_data(qpProvider):
    data = qpProvider.GetNumCandles(tag)

    num_candles = data['data']

    start_candles = num_candles - num_candles_req

    candles = []

    data = qpProvider.GetCandles(tag, 0, start_candles, 0)

    data = data['data']
    for x in data:
        x['datetime'] = datetime.datetime(x['datetime']['year'],
                                          x['datetime']['month'],
                                          x['datetime']['day'],
                                          x['datetime']['hour'],
                                          x['datetime']['min'],
                                          x['datetime']['sec'])

        x['close'] = int(x['close'])
        x['high'] = int(x['high'])
        x['low'] = int(x['low'])
        x['open'] = int(x['open'])
        x['volume'] = int(x['volume'])

        candles.append(x)

    return candles


