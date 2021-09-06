import time
from QuikPy import QuikPy
import price
import bb
import message
import db
import offers
import datetime
import volume


#bid покупка
#offer предложение


firmId = 'SPBFUT'
classCode = 'SPBFUT'
secCode = 'RIU1'
account = 'SPBFUT12wA8'

QUOTES = []


def on_trans_reply(data):
    db.log('OnTransReply', data['data'])

    offers.update_on_trans_reply(data['data'])

def on_order(data):
    db.log('OnOrder', data['data'])

    offers.update_on_order(data['data'])

def on_trade(data):
    db.log('OnTrade', data['data'])

    offers.update_on_trade(data['data'])

def on_futures_client_holding(data):
    db.log('OnFuturesClientHolding', data['data'])

def on_depo_limit(data):
    db.log('OnDepoLimit', data['data'])

def on_depo_limit_delete(data):
    db.log('OnDepoLimitDelete', data['data'])


def set_quotes(data):
    global QUOTES

    QUOTES = data['data']

def do_loop(qpProvider):
    global QUOTES

    while True:
        time.sleep(2)
        while not message.TRADE:
            time.sleep(5)

        start_time = time.time()
        try:
            _quotes = QUOTES.copy()
        except:
            continue

        #orders = qpProvider.GetAllOrders()['data']

        balance = 0

        futures_holdings = qpProvider.GetFuturesHoldings()
        if not futures_holdings is None:
            futures_holdings = futures_holdings['data']
            for f in futures_holdings:
                if f['sec_code']!=secCode:
                    continue
                balance = f['todaybuy']-f['todaysell']
                break

        db.log('quotes', _quotes)

        if len(_quotes)==0:
            continue

        if _quotes.get('bid') is None:
            continue

        bb_data = bb.get_data(qpProvider)
        db.log('bb_data', bb_data)

        price_data = price.get_data(qpProvider)
        db.log('price_data', price_data)

        #volume_data = volume.get_data(qpProvider)
        #db.log('volume_data', volume_data)

        last_bb_data = bb_data[-1]
        last_price_data = price_data[-1]

        last_bb_data_close = bb_data[-2]
        last_price_data_close = price_data[-2]

        last_bid = int(_quotes['bid'][-1]['price'])
        db.log('last_bid', last_bid)

        first_offer = int(_quotes['offer'][0]['price'])
        db.log('first_offer', first_offer)

        step1 = round((time.time() - start_time), 4)

        db.log('step1', step1)

        if balance<0:
            #Открыт шорт
            pass
        elif balance>0:
            #Открыт лонг
            pass
        else:
            #Нет открытых позиций
            pass


        if first_offer>last_bb_data_close['medium_line']:
            take = offers.get_take('short')
            if last_bb_data_close['upper_line']<=last_bid and balance==0:
                offers.add_offer(qpProvider, last_bb_data['upper_line'], last_bid, 'S', bb_data, price_data, _quotes, account, classCode, secCode, balance, 'short')

            elif take>0 and balance!=0:
                if take>=first_offer:
                    offers.add_offer(qpProvider, take, first_offer, 'B', bb_data, price_data, _quotes, account, classCode, secCode, balance, 'short')

        else:
            take = offers.get_take('long')

            if last_bb_data_close['lower_line']>=first_offer and balance==0:
                offers.add_offer(qpProvider, last_bb_data['lower_line'], first_offer, 'B', bb_data, price_data, _quotes, account, classCode, secCode, balance, 'long')

            elif take>0 and balance!=0:
                if take<=last_bid:
                    offers.add_offer(qpProvider, take, last_bid, 'S', bb_data, price_data, _quotes, account, classCode, secCode, balance, 'long')

        offers.garbage_collect(qpProvider, account, classCode, secCode)

        #if message.CLOSE_ALL:
        #    offers.close_all()
        #    message.CLOSE_ALL = False

        step2 = round((time.time() - start_time), 4)

        db.log('step2', step2)

    pass

def main():
    qpProvider = QuikPy(Host='localhost')

    qpProvider.GetQuoteLevel2(classCode, secCode)
    qpProvider.OnQuote = set_quotes
    qpProvider.SubscribeLevel2Quotes(classCode, secCode)

    qpProvider.OnTransReply = on_trans_reply
    qpProvider.OnOrder = on_order
    qpProvider.OnTrade = on_trade
    #qpProvider.OnFuturesClientHolding = on_futures_client_holding
    qpProvider.OnDepoLimit = on_depo_limit
    qpProvider.OnDepoLimitDelete = on_depo_limit_delete

    time.sleep(5)

    message.init()

    do_loop(qpProvider)


if __name__ == "__main__":
    main()


