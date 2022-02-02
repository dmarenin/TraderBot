import time
from QuikPy import QuikPy
import price
#import bb
#import message
#import db
import offers
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
account = 'SPBFUT12wA8'
multiplicity = -1

QUOTES = []


def on_trans_reply(data):
    pass 

def on_order(data):
    pass

def on_trade(data):
    pass

def on_futures_client_holding(data):
    pass

def on_depo_limit(data):
    pass

def on_depo_limit_delete(data):
    pass

def set_quotes(data):
    if data['data']['sec_code']!=secCode:
        return

    global QUOTES

    QUOTES = data['data']

def do_loop(qpProvider):
    global QUOTES

    data = qpProvider.GetFuturesLimit(firmId, account, 0, "SUR")

    last_type_order = None #0-B, 1-S
    take_profit = 150
    stop_loss = 100

    while True:
        time.sleep(0.5)

        futures_holdings = qpProvider.GetFuturesHoldings()

        try:
            _quotes = QUOTES.copy()
        except:
            continue

        if len(_quotes)==0:
            continue

        if _quotes.get('bid') is None:
            continue

        #futures_holdings = qpProvider.GetFuturesHoldings()

        orders = qpProvider.GetAllOrders()['data']

        if orders[len(orders)-1]['flags'] in [29, 25]:
            x = orders[len(orders)-1]
            if x['flags'] in [29, 25]:
                dt = datetime.datetime(x['datetime']['year'],
                                          x['datetime']['month'],
                                          x['datetime']['day'],
                                          x['datetime']['hour'],
                                          x['datetime']['min'],
                                          x['datetime']['sec'])

                dt = dt + datetime.timedelta(hours=2)

                if (datetime.datetime.now()-dt).seconds>5:
                    offers.send_transaction_kill_order(qpProvider, str(x['trans_id']), account, classCode, secCode, str(x['order_num']))

                    #if last_type_order==0:
                    #    last_type_order = 1
                    #else:
                    #    last_type_order = 0

            continue

        last_price = 0

        for i in reversed(orders):
            if not i['flags'] in [28, 24]:
                continue

            last_price = i['price']
            break

        #if orders[len(orders)-1]['flags'] in [29, 25]:
        for x in orders:
            if x['flags'] in [29, 25]:
                dt = datetime.datetime(x['datetime']['year'],
                                          x['datetime']['month'],
                                          x['datetime']['day'],
                                          x['datetime']['hour'],
                                          x['datetime']['min'],
                                          x['datetime']['sec'])

                dt = dt + datetime.timedelta(hours=2)

                if (datetime.datetime.now()-dt).seconds>15:
                    offers.send_transaction_kill_order(qpProvider, str(x['trans_id']), account, classCode, secCode, str(x['order_num']))

        balance = 0

        futures_holdings = qpProvider.GetFuturesHoldings()
        if not futures_holdings is None:
            futures_holdings = futures_holdings['data']
            for f in futures_holdings:
                if f['sec_code']!=secCode:
                    continue
                balance = f['todaybuy']-f['todaysell']+f['startbuy']-f['startsell']
                break

        best_bid = float(_quotes['bid'][-1]['price'])
        best_offer = float(_quotes['offer'][0]['price'])

        best_offer = round(best_offer, multiplicity)
        best_bid = round(best_bid, multiplicity)

        if balance>0:
             take = last_price + take_profit
             take = round(take, 2)

             stop= last_price - stop_loss
             stop = round(stop, 2)

             if take<=best_bid:
                 offers.add_offer(qpProvider, best_bid, 'S', account, classCode, secCode, multiplicity)

                 last_type_order =  0

             elif stop>=best_bid:
                 offers.add_offer(qpProvider, best_bid, 'S', account, classCode, secCode, multiplicity)

                 last_type_order =  0

        elif balance<0:
             take = last_price - take_profit
             take = round(take, 2)

             stop = last_price + stop_loss
             stop = round(stop, 2)

             if take>=best_offer:
                 offers.add_offer(qpProvider, best_offer, 'B', account, classCode, secCode, multiplicity)

                 last_type_order = 1

             elif stop<=best_offer:
                 offers.add_offer(qpProvider, best_offer, 'B', account, classCode, secCode, multiplicity)

                 last_type_order = 1

        else:
            if last_type_order is None:
                offers.add_offer(qpProvider, best_bid, 'B', account, classCode, secCode, multiplicity)

            elif last_type_order==0:
                offers.add_offer(qpProvider, best_offer, 'S', account, classCode, secCode, multiplicity)
                last_type_order = 1

            elif last_type_order==1:
                offers.add_offer(qpProvider, best_bid, 'B', account, classCode, secCode, multiplicity)
                last_type_order = 0


def main():
    qpProvider = QuikPy(Host='localhost')

    qpProvider.GetQuoteLevel2(classCode, secCode)
    qpProvider.OnQuote = set_quotes
    qpProvider.SubscribeLevel2Quotes(classCode, secCode)

    qpProvider.OnTransReply = on_trans_reply
    qpProvider.OnOrder = on_order
    #qpProvider.OnTrade = on_trade
    #qpProvider.OnFuturesClientHolding = on_futures_client_holding
    #qpProvider.OnDepoLimit = on_depo_limit
    #qpProvider.OnDepoLimitDelete = on_depo_limit_delete

    time.sleep(5)

    do_loop(qpProvider)


if __name__ == "__main__":
    main()


