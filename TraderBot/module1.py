

import datetime
from QuikPy import QuikPy
import numpy as np
import pandas as pd
import pandas_datareader as pdr
import matplotlib.pyplot as plt

import pandas as pd 
import matplotlib.pyplot as plt 
import requests
import math
from termcolor import colored as cl 
import numpy as np

plt.style.use('fivethirtyeight')
plt.rcParams['figure.figsize'] = (20, 10)


def get_historic_data():
    date, open, high, low, close = [], [], [], [], []

    qpProvider = QuikPy(Host='localhost')

    data = qpProvider.GetCandles('bb', 2, 0, 100000)
    data = data['data']
    for d in data:
        if datetime.datetime(d['datetime']['year'], d['datetime']['month'], d['datetime']['day'], d['datetime']['hour'], d['datetime']['min'], d['datetime']['sec'])<datetime.datetime(2021, 8, 1, 0,0,0):
            continue

        date.append(datetime.datetime(d['datetime']['year'], d['datetime']['month'], d['datetime']['day'], d['datetime']['hour'], d['datetime']['min'], d['datetime']['sec']).strftime("%Y-%m-%d %H:%M:%S"))
        open.append(d['open'])
        high.append(d['high'])
        low.append(d['low'])
        close.append(d['close'])

    date_df = pd.DataFrame(date).rename(columns = {0:'date'})
    open_df = pd.DataFrame(open).rename(columns = {0:'open'})
    high_df = pd.DataFrame(high).rename(columns = {0:'high'})
    low_df = pd.DataFrame(low).rename(columns = {0:'low'})
    close_df = pd.DataFrame(close).rename(columns = {0:'close'})
    frames = [date_df, open_df, high_df, low_df, close_df]
    df = pd.concat(frames, axis = 1, join = 'inner')

    return df


df = get_historic_data()

tsla = df.set_index('date')
#df = df[df.date >= '2021-08-01 00:00:00']
df.to_csv('tsla.csv')

tsla = pd.read_csv('tsla.csv').set_index('date')
tsla.index = pd.to_datetime(tsla.index)
tsla.tail()


    #res = qpProvider.GetNumCandles('bb')

#def get_sma(prices, rate):
#    return prices.rolling(rate).mean()




#if __name__ == '__main__':
#    qpProvider = QuikPy(Host='localhost')

#    res = qpProvider.GetNumCandles('bb')

#    res = qpProvider.GetCandles('bb', 0,0,0)

#    symbol = 'AAPL'
#df = pdr.DataReader(symbol, 'yahoo', '2014-07-01', '2015-07-01') # <-- Get price data for stock from date range
#df.index = np.arange(df.shape[0]) # Convert the index to array from [0, 1, 2, ...number of rows]
#closing_prices = df['Close'] # Use only closing prices

#sma = get_sma(closing_prices, 20) # Get 20 day SMA

## Plot the data
#plt.title(symbol + ' SMA')
#plt.xlabel('Days')
#plt.ylabel('Closing Prices')
#plt.plot(closing_prices, label='Closing Prices')
#plt.plot(sma, label='20 Day SMA')
#plt.legend()
#plt.show()



#    print(res)


#    #firmId = 'MC0063100000'  # Фирма
#    #classCode = 'TQBR'  # Класс тикера
#    #secCode = 'GAZP'  # Тикер
    
#    ## firmId = 'SPBFUT'  # Фирма
#    ## classCode = 'SPBFUT'  # Класс тикера
#    ## secCode = 'SiH1'  # Для фьючерсов: <Код тикера><Месяц экспирации: 3-H, 6-M, 9-U, 12-Z><Последняя цифра года>

#    ## Данные тикера и его торговый счет
#    #securityInfo = qpProvider.GetSecurityInfo(classCode, secCode)["data"]
#    #print(f'Информация о тикере {classCode}.{secCode} ({securityInfo["short_name"]}):')
#    #print(f'Валюта: {securityInfo["face_unit"]}')
#    #print(f'Кол-во десятичных знаков: {securityInfo["scale"]}')
#    #print(f'Лот: {securityInfo["lot_size"]}')
#    #print(f'Шаг цены: {securityInfo["min_price_step"]}')
#    #print(f'Торговый счет для тикера класса {classCode}: {qpProvider.GetTradeAccount(classCode)["data"]}')

#    ## Свечки
#    #print(f'5-и минутные свечки {classCode}.{secCode}:')
#    #bars = qpProvider.GetCandlesFromDataSource(classCode, secCode, 5, 0)["data"]  # 5 минут, 0 = все свечки
#    #print(bars)

#    ## print(f'Дневные свечки {classCode}.{secCode}:')
#    ## bars = qpProvider.GetCandlesFromDataSource(classCode, secCode, 1440, 0)['data']  # 1440 минут = 1 день, 0 = все свечки
#    ## dtjs = [row['datetime'] for row in bars]  # Получаем исходники даты и времени начала свчки (List comprehensions)
#    ## dts = [datetime(dtj['year'], dtj['month'], dtj['day'], dtj['hour'], dtj['min']) for dtj in dtjs]  # Получаем дату и время
#    ## print(dts)

#    # Выход
#    qpProvider.CloseConnectionAndThread()  # Перед выходом закрываем соединение и поток QuikPy из любого экземпляра
