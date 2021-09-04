import time
from QuikPy import QuikPy
import price
import bb
import message
import db
import offers


#bid покупка
#offer предложение


firmId = 'SPBFUT'
classCode = 'SPBFUT'
secCode = 'RIU1'
account = 'SPBFUT12wA8'

QUOTES = []


def on_trans_reply(data):
    db.log('OnTransReply', data['data'])

def on_order(data):
    db.log('OnOrder', data['data'])

    offers.update(data['data'])

def on_trade(data):
    db.log('OnTrade', data['data'])

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
        time.sleep(1)
        while message.STOP_TRADE:
            time.sleep(15)

        start_time = time.time()

        bb_data = bb.get_data(qpProvider)
        db.log('bb_data', bb_data)

        price_data = price.get_data(qpProvider)
        db.log('price_data', price_data)

        last_bb_data = bb_data[-1]
        last_price_data = price_data[-1]

        last_bb_data_close = bb_data[-2]
        last_price_data_close = price_data[-2]

        try:
            _quotes = QUOTES.copy()
        except:
            continue

        db.log('quotes', _quotes)

        #if len(_quotes)==0:
        #    continue

        #if _quotes.get('bid') is None:
        #    continue

        #last_bid = int(_quotes['bid'][-1]['price'])
        #db.log('last_bid', last_bid)

        #first_offer = int(_quotes['offer'][0]['price'])
        #db.log('first_offer', first_offer)

        take = offers.get_take()

        ####
        first_offer = 180000+200

        offers.add_offer(qpProvider, last_bb_data['lower_line'], first_offer, 'B', bb_data, price_data, _quotes, account, classCode, secCode)

        offers.add_offer(qpProvider, take, take, 'S', bb_data, price_data, _quotes, account, classCode, secCode)

        offers.garbage_collect(qpProvider, account, classCode, secCode)

        #if message.CLOSE_ALL:
        #    offers.close_all()
        #    message.CLOSE_ALL = False

        #offers.get_offers()

        print("--- %s seconds step1 ---" % round((time.time() - start_time), 4))
        print('')

        continue
        ####

        if last_bb_data_close['lower_line']>=first_offer:
            offers.add_offer(qpProvider, last_bb_data['lower_line'], first_offer, 'B', bb_data, price_data, _quotes, account, classCode, secCode)

        elif take > 0:
            if take<=last_bid:
                offers.add_offer(qpProvider, last_bid, take, 'S', bb_data, price_data, _quotes, account, classCode, secCode)

        offers.garbage_collect()

        #if message.CLOSE_ALL:
        #    offers.close_all()
        #    message.CLOSE_ALL = False

        print("--- %s seconds step2 ---" % round((time.time() - start_time), 4))

    pass

def main():
    qpProvider = QuikPy(Host='localhost')

    #qpProvider.GetQuoteLevel2(classCode, secCode)
    #qpProvider.OnQuote = set_quotes
    #qpProvider.SubscribeLevel2Quotes(classCode, secCode)

    #qpProvider.OnTransReply = on_trans_reply
    #qpProvider.OnOrder = on_order
    #qpProvider.OnTrade = on_trade
    qpProvider.OnFuturesClientHolding = on_futures_client_holding
    #qpProvider.OnDepoLimit = on_depo_limit
    #qpProvider.OnDepoLimitDelete = on_depo_limit_delete

    #time.sleep(5)

    message.init()

    do_loop(qpProvider)


if __name__ == "__main__":
    main()


