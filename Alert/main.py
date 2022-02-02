import time
from QuikPy import QuikPy
#import price
#import bb
import message
#import db
#import offers
import datetime
#import volume
#import macd
import datetime


#bid покупка
#offer предложение

is_short = False

firmId = 'SPBFUT'
classCode = 'SPBFUT'
secCode = 'RIH2'
secCode2 = 'BRG2'
account = 'SPBFUT12wA8'
multiplicity = -1

QUOTES = []
QUOTES2 = []

def set_quotes(data):
    #if data['data']['sec_code']!=secCode:
    #    return

    global QUOTES

    QUOTES = data['data']

    #print(data['data']['sec_code'])

def set_quotes2(data):
    if data['data']['sec_code']!=secCode2:
        return

    global QUOTES2

    QUOTES2 = data['data']

def do_loop(qpProvider):
    global QUOTES
    global QUOTES2

    while True:
        time.sleep(0.250)

        try:
            _quotes = QUOTES.copy()
        except:
            continue
        #try:
        #    _quotes2 = QUOTES2.copy()
        #except:
        #    continue

        if len(_quotes)>0:

            if _quotes.get('offer') is None:
                continue

            for num, val in enumerate(_quotes['offer']):
                if int(val['quantity'])>=1000 and _quotes['sec_code']==secCode:
                    pass
                    message.send(f"RIH2 offer: {val['price']} - {val['quantity']} - {num+1}")
                elif int(val['quantity'])>=4000 and _quotes['sec_code']==secCode2:
                    pass
                    message.send(f"BRG2 offer: {val['price']} - {val['quantity']} - {num+1}")

            for num, val in enumerate(_quotes['bid']):
                if int(val['quantity'])>=1000 and _quotes['sec_code']==secCode:
                    pass
                    message.send(f"RIH2 bid: {val['price']} - {val['quantity']} - {50-num-1}")
                elif int(val['quantity'])>=4000 and _quotes['sec_code']==secCode2:
                    pass
                    message.send(f"BRG2 bid: {val['price']} - {val['quantity']} - {50-num-1}")

        #if len(_quotes2)>0:
        #    for num, val in enumerate(_quotes2['offer']):
        #        if int(val['quantity'])>=4000:
        #            pass
        #            message.send(f"BRG2 offer: {val['price']} - {val['quantity']} - {num}")

        #    for num, val in enumerate(_quotes2['bid']):
        #        if int(val['quantity'])>=4000:
        #            pass
        #            message.send(f"BRG2 bid: {val['price']} - {val['quantity']} - {num}")

def main():

    message.init()

    qpProvider = QuikPy(Host='localhost')

    qpProvider.GetQuoteLevel2(classCode, secCode)
    qpProvider.OnQuote = set_quotes
    qpProvider.SubscribeLevel2Quotes(classCode, secCode)

    #qpProvider.GetQuoteLevel2(classCode, secCode2)
    #qpProvider.OnQuote = set_quotes2
    #qpProvider.SubscribeLevel2Quotes(classCode, secCode2)

    #qpProvider.OnTransReply = on_trans_reply
    #qpProvider.OnOrder = on_order
    #qpProvider.OnTrade = on_trade
    #qpProvider.OnFuturesClientHolding = on_futures_client_holding
    #qpProvider.OnDepoLimit = on_depo_limit
    #qpProvider.OnDepoLimitDelete = on_depo_limit_delete

    time.sleep(5)

    do_loop(qpProvider)


if __name__ == "__main__":
    main()


