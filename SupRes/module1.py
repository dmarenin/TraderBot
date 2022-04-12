## -*- coding: utf-8 -*-

#import matplotlib.pyplot as plt

#import numpy as np


#if __name__ == '__main__':
#    # Интервал изменения переменной по оси X
#    xmin = -20.0
#    xmax = 20.0
#    count = 200

#    # Создадим список координат по оиси X на отрезке [xmin; xmax]
#    x = np.linspace(xmin, xmax, count)

#    # Вычислим значение функции в заданных точках
#    y = np.sinc(x / np.pi)

#    plt.figure(figsize=(8, 8))

#    # !!! Две строки, три столбца.
#    # !!! Текущая ячейка - 1
#    plt.subplot(2, 3, 1)
#    plt.plot(x, y)
#    plt.title("1")

#    # !!! Две строки, три столбца.
#    # !!! Текущая ячейка - 2
#    plt.subplot(2, 3, 2)
#    plt.plot(x, y)
#    plt.title("2")

#    # !!! Две строки, три столбца.
#    # !!! Текущая ячейка - 4
#    plt.subplot(2, 3, 4)
#    plt.plot(x, y)
#    plt.title("4")

#    # !!! Две строки, три столбца.
#    # !!! Текущая ячейка - 5
#    plt.subplot(2, 3, 5)
#    plt.plot(x, y)
#    plt.title("5")

#    # !!! Одна строка, три столбца.
#    # !!! Текущая ячейка - 3
#    plt.subplot(1, 3, 3)
#    plt.plot(x, y)
#    plt.title("3")

#    # Покажем окно с нарисованным графиком
#    plt.show()


import matplotlib.pyplot as plt
import numpy as np

N = 5
menMeans = (20, 35, 30, 35, -27)
womenMeans = (25, 32, 34, 20, -25)
menStd = (2, 3, 4, 1, 2)
womenStd = (3, 5, 2, 3, 3)
ind = np.arange(N)    # the x locations for the groups
width = 0.35       # the width of the bars: can also be len(x) sequence


fig, ax = plt.subplots()

p1 = ax.bar(ind, menMeans, width, yerr=menStd, label='Men')
p2 = ax.bar(ind, womenMeans, width,
            bottom=menMeans, yerr=womenStd, label='Women')

ax.axhline(0, color='grey', linewidth=0.8)
ax.set_ylabel('Scores')
ax.set_title('Scores by group and gender')
#ax.set_xticks(ind, labels=['G1', 'G2', 'G3', 'G4', 'G5'])
ax.legend()

# Label with label_type 'center' instead of the default 'edge'
#ax.bar_label(p1, label_type='center')
#ax.bar_label(p2, label_type='center')
#ax.bar_label(p2)

plt.show()