import _thread
import price
from QuikPy import QuikPy
import datetime
import bb
import time
import message
import uuid
import random


#bid покупка
#offer предложение

firmId = 'SPBFUT'
classCode = 'SPBFUT'
secCode = 'RIU1'
quotes = []
offers = []
account = 'SPBFUT12wA8' #L01-00000F0010UNRF
offers_update = False


def on_trans_reply(data):
    print('OnTransReply')
    print(data['data'])

def on_order(data):
    global offers
    global offers_update

    print('OnOrder')
    print(data['data'])

    while offers_update!=False:
        time.sleep(0.2)
    offers_update=True

    for off in offers:
        if off['trans_Id']==data['data']['trans_id']:
            off['order_num'] = int(data['data']['order_num'])
            if  int(data['data']['balance'])==0:
                off['status'] = 3
                #off['status'] = int(data['data']['ext_order_status'])
                #off['result_msg'] = data['data']['result_msg']
                message.send(f"{datetime.datetime.now()} заявка выполнена")
                break
        break

    offers_update=False
def on_trade(data):
    print('OnTrade')
    print(data['data'])

def on_futures_client_holding(data):
    #print('OnFuturesClientHolding')
    #print(data['data'])

    real_varmargin = data['data']['real_varmargin']

    print(f"{datetime.datetime.now()} real_varmargin: {real_varmargin}")

    #if int(data['data']['real_varmargin'])<(-200):
    #    message.send(f"{datetime.datetime.now()} real_varmargin: {real_varmargin}")

def on_depo_limit(data):
    print('OnDepoLimit')
    print(data['data'])
    
    message.send(f"{datetime.datetime.now()} OnDepoLimit")

def on_depo_limit_delete(data):
    print('OnDepoLimitDelete')
    print(data['data'])

    message.send(f"{datetime.datetime.now()} OnDepoLimitDelete")

def set_quotes(data):
    global quotes

    quotes = data['data']

def add_offer(qpProvider, price, price2, type, bb_data, price_data, _quotes):
    global offers
    global offers_update

    if len(offers)>0:
        if type=='B':
            if offers[-1]['type']=='B':
                #print('exist active order')
                return
        elif type=='S':
            if offers[-1]['type']=='S':
                #print('exist active order')
                return

    else:
        if type=='S':
            return

    if len(offers)>0:
        if offers[-1]['status']!=3:
            return

    print(f"{datetime.datetime.now()} {type} {price} {price2}")

    message.send(f"{datetime.datetime.now()} {type} {price} {price2}")

    offer = {}
    offer['datetime'] = datetime.datetime.now()
    offer['type'] = type
    offer['price'] = price
    offer['price2'] = price2

    offer['bb_data'] = bb_data
    offer['price_data'] = price_data
    offer['_quotes'] = _quotes

    trans_Id = random.randint(1, 100000)

    send_res = send_transaction_new_order(qpProvider, price, type, trans_Id)

    offer['trans_Id'] = trans_Id
    offer['order_num'] = None
    offer['send_res'] = send_res

    offer['status'] = '-1'

    while offers_update!=False:
        time.sleep(0.2)
    offers_update=True

    offers.append(offer)
    
    offers_update=False

    #print(offers)

def send_transaction_new_order(qpProvider, price, operation, trans_Id):
    transaction = {'TRANS_ID': str(trans_Id),
                   'CLIENT_CODE': '',
                   'ACCOUNT': account,
                   'ACTION': 'NEW_ORDER',
                   'CLASSCODE': classCode,
                   'SECCODE': secCode,
                   'OPERATION': operation,
                   'PRICE': str(round(int(price), -1)),
                   'QUANTITY': '1',
                   'TYPE': 'L'}# L = лимитная заявка (по умолчанию), M = рыночная заявка

    res = qpProvider.SendTransaction(transaction)

    error = ''
    if not res.get('lua_error') is None:
        error = res['lua_error']

    print(f"Новая лимитная/рыночная заявка отправлена на рынок статус ошибки: {error}")

    message.send(f"Новая лимитная/рыночная заявка отправлена на рынок статус ошибки: {error}")

    return error



    # Удаление существующей лимитной заявки
    # orderNum = 1234567890123456789  # 19-и значный номер заявки
    # transaction = {
    #     'TRANS_ID': str(TransId),  # Номер транзакции задается клиентом
    #     'ACTION': 'KILL_ORDER',  # Тип заявки: Удаление существующей заявки
    #     'CLASSCODE': classCode,  # Код площадки
    #     'SECCODE': secCode,  # Код тикера
    #     'ORDER_KEY': str(orderNum)}  # Номер заявки
    # print(f'Удаление заявки отправлено на рынок: {qpProvider.SendTransaction(transaction)["data"]}')

    # Новая стоп заявка
    #StopSteps = 10  # Размер проскальзывания в шагах цены
    #slippage = float(qpProvider.GetSecurityInfo(classCode, secCode)['data']['min_price_step']) * StopSteps  # Размер проскальзывания в деньгах
    #if slippage.is_integer():  # Целое значение проскальзывания мы должны отправлять без десятичных знаков
    #    slippage = int(slippage)  # поэтому, приводим такое проскальзывание к целому числу
    #transaction = {  # Все значения должны передаваться в виде строк
    #    'TRANS_ID': str(TransId),  # Номер транзакции задается клиентом
    #    'CLIENT_CODE': '',  # Код клиента. Для фьючерсов его нет
    #    'ACCOUNT': 'SPBFUT00PST',  # Счет
    #    'ACTION': 'NEW_STOP_ORDER',  # Тип заявки: Новая стоп заявка
    #    'CLASSCODE': classCode,  # Код площадки
    #    'SECCODE': secCode,  # Код тикера
    #    'OPERATION': 'B',  # B = покупка, S = продажа
    #    'PRICE': str(price),  # Цена исполнения
    #    'QUANTITY': str(quantity),  # Кол-во в лотах
    #    'STOPPRICE': str(price + slippage),  # Стоп цена исполнения
    #    'EXPIRY_DATE': 'GTC'}  # Срок действия до отмены
    #print(f'Новая стоп заявка отправлена на рынок: {qpProvider.SendTransaction(transaction)["data"]}')

    # Удаление существующей стоп заявки
    # orderNum = 1234567  # Номер заявки
    # transaction = {
    #     'TRANS_ID': str(TransId),  # Номер транзакции задается клиентом
    #     'ACTION': 'KILL_STOP_ORDER',  # Тип заявки: Удаление существующей заявки
    #     'CLASSCODE': classCode,  # Код площадки
    #     'SECCODE': secCode,  # Код тикера
    #     'STOP_ORDER_KEY': str(orderNum)}  # Номер заявки
    # print(f'Удаление стоп заявки отправлено на рынок: {qpProvider.SendTransaction(transaction)["data"]}')

def main():
    global quotes

    qpProvider = QuikPy(Host='localhost')

    qpProvider.GetQuoteLevel2(classCode, secCode)
    qpProvider.OnQuote = set_quotes
    qpProvider.SubscribeLevel2Quotes(classCode, secCode)

    qpProvider.OnTransReply = on_trans_reply
    qpProvider.OnOrder = on_order
    qpProvider.OnTrade = on_trade
    qpProvider.OnFuturesClientHolding = on_futures_client_holding
    qpProvider.OnDepoLimit = on_depo_limit
    qpProvider.OnDepoLimitDelete = on_depo_limit_delete

    time.sleep(5)

    message.init()

    message.send(f"{datetime.datetime.now()} start")

    while True:
        time.sleep(1.5)

        bb_data = bb.get_data(qpProvider)
        #print(bb_data)

        price_data = price.get_data(qpProvider)
        #print(price_data)

        last_bb_data = bb_data[-1]
        last_price_data = price_data[-1]

        last_bb_data_close = bb_data[-2]
        last_price_data_close = price_data[-2]

        try:
            _quotes = quotes.copy()
        except:
            continue

        if len(_quotes)==0:
            continue

        if _quotes.get('bid') is None:
            continue

        last_bid = _quotes['bid'][-1]['price']
        #print(f'first_bid - {first_bid}')

        first_offer = _quotes['offer'][0]['price']
        #print(f'first_offer - {first_offer}')

        #print(f"lower_line - {last_bb_data['lower_line']}")
        #print(f"upper_line - {last_bb_data['upper_line']}")
        #print(f"lower_line_close - {last_bb_data_close['lower_line']}")
        #print(f"upper_line_close - {last_bb_data_close['upper_line']}")

        take = None
        if len(offers)>0:
            if offers[-1]['type']=='B':
                take = offers[-1]['price']+200

        if last_bb_data_close['lower_line']>=int(first_offer):
            add_offer(qpProvider, last_bb_data['lower_line'], first_offer, 'B', bb_data, price_data, _quotes)

        elif not take is None:
            if take<=int(last_bid):
                add_offer(qpProvider, last_bid, take, 'S', bb_data, price_data, _quotes)

        #elif last_bb_data_close['upper_line']<=int(last_bid):
        #    add_offer(qpProvider, last_bb_data['upper_line'], first_bid, 'S', bb_data, price_data, _quotes)
    pass


if __name__ == "__main__":
    main()


