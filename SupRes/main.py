import pandas as pd
import numpy as np
#import yfinance
#from mpl_finance import candlestick_ohlc
import matplotlib.dates as mpl_dates
import matplotlib.pyplot as plt
import time
import price
from QuikPy import QuikPy
import matplotlib.ticker as ticker


def isSupport(df,i):
  support = df['Low'][i] < df['Low'][i-1]  and df['Low'][i] < df['Low'][i+1] and df['Low'][i+1] < df['Low'][i+2] and df['Low'][i-1] < df['Low'][i-2]
  return support
def isResistance(df,i):
  resistance = df['High'][i] > df['High'][i-1]  and df['High'][i] > df['High'][i+1] and df['High'][i+1] > df['High'][i+2] and df['High'][i-1] > df['High'][i-2]
  return resistance

def plot_all():
  fig, ax = plt.subplots()
  candlestick_ohlc(ax,df.values, width=0.01, colorup='green', colordown='red', alpha=0.8)
  date_format = mpl_dates.DateFormatter('%Y-%m-%d %H:%M')
  ax.xaxis.set_major_formatter(date_format)
  fig.autofmt_xdate()
  #ax.xaxis.set_major_locator(mpl_dates.mdates.HourLocator())
  #ax.xaxis.set_major_locator(mdates.MinuteLocator(byminute=[0, 15, 30, 45],
  #                                              interval=1))
  fig.tight_layout()
  for level in levels:
    plt.hlines(level[1],xmin=df['Date'][level[0]], xmax=max(df['Date']),colors=level[2])

  #plt.yticks(range(0, 120000), color="r", size=1000)
  #ax.yaxis.set_major_locator(ticker.MultipleLocator(5000))
  #ax.yaxis.set_minor_locator(ticker.MultipleLocator(1000))

  #  Устанавливаем интервал основных и
#  вспомогательных делений:
  #ax.xaxis.set_major_locator(ticker.MultipleLocator(2))
  #ax.xaxis.set_minor_locator(ticker.MultipleLocator(1))
  ax.yaxis.set_major_locator(ticker.MultipleLocator(5000))
  ax.yaxis.set_minor_locator(ticker.MultipleLocator(1000))


#  Добавляем линии основной сетки:
  ax.grid(which='major', color = 'k')

#  Включаем видимость вспомогательных делений:
  ax.minorticks_on()
#  Теперь можем отдельно задавать внешний вид
#  вспомогательной сетки:
  #ax.grid(which='minor', color = 'gray', linestyle = ':')
  #plt.xlim(1.3, 4.0)
  #ax.margins(x=10000)

  plt.ion()
  plt.pause(10)

  return None
#f1.xaxis_date()
#f1.xaxis.set_major_formatter(mdates.DateFormatter('%y-%m-%d %H:%M:%S'))

def isFarFromLevel(l, levels, s):
   return np.sum([abs(l-x[1]) < s  for x in levels]) == 0


plt.rcParams['figure.figsize'] = [12, 7]
plt.rc('font', size=14)


qpProvider = QuikPy(Host='localhost')

data = price.get_data(qpProvider)

qpProvider.CloseConnectionAndThread()

#name = 'SPY'
#ticker = yfinance.Ticker(name)
#df = ticker.history(interval="1d",start="2020-01-01", end="2024-01-01")
df = pd.DataFrame(data)


#df['Date'] = pd.to_datetime(df.index)
df['Date'] = pd.to_datetime(df['Date'],  format="%Y-%m-%d %H:%M:%S")
df['Date'] = df['Date'].apply(mpl_dates.date2num)
df = df.loc[:,['Date', 'Open', 'High', 'Low', 'Close']]


levels = []
for i in range(2,df.shape[0]-2):
  if isSupport(df,i):
    levels.append((i,df['Low'][i], 'green'))
    #print(f"{df['Low'][i]} isSupport")
  elif isResistance(df,i):
    levels.append((i,df['High'][i], 'red'))
    #print(f"{df['High'][i]} isResistance")

plot_all()

s =  np.mean(df['High'] - df['Low'])


levels = []
for i in range(2,df.shape[0]-2):
  if isSupport(df,i):
    l = df['Low'][i]
    if isFarFromLevel(l, levels, s):
      levels.append((i,l,'green'))
      print(f"{l} isSupport")
  elif isResistance(df,i):
    l = df['High'][i]
    if isFarFromLevel(l, levels, s):
      levels.append((i,l ,'red'))
      print(f"{l} isResistance")


plot_all()

a = input('')


