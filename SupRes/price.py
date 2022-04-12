import time
import datetime


tag = 'price'
num_candles_req = 500


def get_data(qpProvider):
    data = qpProvider.GetNumCandles(tag)

    num_candles = data['data']

    start_candles = num_candles - num_candles_req

    price_candles = []

    data = qpProvider.GetCandles(tag, 0, start_candles, 0)

    data = data['data']
    for x in data:
        x['Date'] = datetime.datetime(x['datetime']['year'],
                                          x['datetime']['month'],
                                          x['datetime']['day'],
                                          x['datetime']['hour'],
                                          x['datetime']['min'],
                                          x['datetime']['sec'])

        x['Date'] = x['Date'].strftime("%Y-%m-%d %H:%M:%S") 

        x['Close'] = x['close']
        x['High'] = x['high']
        x['Low'] = x['low']
        x['Open'] = x['open']
        x['Volume'] = x['volume']

        price_candles.append(x)

    return price_candles

