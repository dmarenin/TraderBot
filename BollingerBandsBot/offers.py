import datetime
import db
import message
import random
import time


def get_offer_by_order_num(order_num):
    res = db.get_offer_by_order_num(order_num)

    return res

def get_offer_by_transact_id(transact_id):
    res = db.get_offer(transact_id)

    return res

def garbage_collect(qpProvider, account, classCode, secCode):
    last_offer = get_last_offer()

    status = last_offer['status']
    if status=='new':
        if (datetime.datetime.now()-last_offer['dt']).seconds>15:
            last_offer['send_res'] = last_offer['send_res']+'; '+'Смена статуса с new на cancel'
            last_offer['status'] ='cancel'

            db.update_offer(last_offer)

    elif status=='accept':
        pass
        #if (datetime.datetime.now()-last_offer['dt']).seconds>15:
        #    last_offer['send_res'] = last_offer['send_res']+'; '+'Смена статуса с accept на cancel'
        #    last_offer['status'] ='cancel'

        #    trans_Id = str(random.randint(1, 100000))
        #    orderNum = str(last_offer['order_num'])

        #    #send_transaction_kill_order(qpProvider, trans_Id, account, classCode, secCode, orderNum)

        #    db.update_offer(last_offer)

    elif status=='close':
        pass

    elif status=='cancel':
        pass

    elif status=='error':
        last_offer['send_res'] = last_offer['send_res']+'; '+'Смена статуса с error на cancel'
        last_offer['status'] ='cancel'

        db.update_offer(last_offer)

    if status!=last_offer['status']:
        print(f"{datetime.datetime.now()} - Смена статуса {status} - {last_offer['status']}")
        message.send(f"{datetime.datetime.now()} - Смена статуса {status} - {last_offer['status']}")

def update_on_trade(data):
    time.sleep(0.1)

    trans_Id = int(data['trans_id'])

    offer = get_offer_by_transact_id(trans_Id)
    if offer is None:
        return

    if offer['order_num']==int(data['order_num']):
        return

    offer['order_num'] = int(data['order_num'])

    db.update_offer(offer)


def update_on_trans_reply(data):
    time.sleep(0.1)

    trans_Id = int(data['trans_id'])

    offer = get_offer_by_transact_id(trans_Id)
    if offer is None:
        return

    if offer['order_num']==int(data['order_num']):
        return

    offer['order_num'] = int(data['order_num'])

    db.update_offer(offer)

def update_on_order(data):
    time.sleep(0.1)

    order_num = int(data['order_num'])

    offer = get_offer_by_order_num(order_num)
    if offer is None:
        return

    if int(data['balance'])==0:
        offer['status'] = 'close'
        db.update_offer(offer)

        print(f"{datetime.datetime.now()} - Заявка выполнена {offer['type']} {offer['price']}")

        message.send(f"{datetime.datetime.now()} - Заявка выполнена {offer['type']} {offer['price']}")



    #if offer['order_num'] is None:
    #    if len(data['data']['order_num'])>0:
    #        offer['order_num'] = int(data['order_num'])
    #        db.update_offer(offer)

    #if offer['type']=='B' and int(data['balance'])==0:
    #    if offer['order_num'] != int(data['order_num']):
    #        print("offer['order_num'] != int(data['data']['order_num'])")

    #    offer['order_num'] = int(data['order_num'])
    #    offer['status'] = 'close'

    #    print(f"{datetime.datetime.now()} - Заявка выполнена {offer['type']} {offer['price']}")

    #    message.send(f"{datetime.datetime.now()} - Заявка выполнена {offer['type']} {offer['price']}")

    #    db.update_offer(offer)

    #elif offer['type']=='S':
    #    print('update')


    #while offers_update!=False:
    #    time.sleep(0.2)
    #offers_update=True

    #for off in offers:
    #    if off['trans_Id']==data['data']['trans_id']:
    #        off['order_num'] = int(data['data']['order_num'])
    #        if  int(data['data']['balance'])==0:
    #            off['status'] = 3
    #            #off['status'] = int(data['data']['ext_order_status'])
    #            #off['result_msg'] = data['data']['result_msg']
    #            message.send(f"{datetime.datetime.now()} заявка выполнена")
    #            break
    #    break

    #offers_update=False

def get_last_offer():
    return db.get_last_offer()

def close_all():
    print('close_all')

def get_offers():
    return db.get_offers()

def profits():
    res = 0

    list_offers = db.get_offers()
    for o in list_offers:
        #if not o['status']=='close':
        #    continue

        if o['type']=='B':
            res += -(o['price'])
        else:
            res += o['price']

    if len(list_offers)>0:
        if list_offers[-1]['type']=='B':
            res += list_offers[-1]['price']

    return res

def get_take(type):
    res = get_last_offer()

    if res is None:
        return 0

    if type=='long':
        return res['price']+200
    else:
        return res['price']-100

def add_offer(qpProvider, price, price2, type, bb_data, price_data, quotes, account, classCode, secCode, balance, branch):
    last_offer = get_last_offer()

    status_close = ['close', 'cancel']

    if not last_offer is None:
        if not last_offer['status'] in status_close:
            return

        if type==last_offer['type'] and balance!=0: #проверка на конечный остаток и заявка выполнена, если 0 то можно делать sbb, bss
            return

    #else:
    #    if type=='S':
    #        return

    if type=='S':
        if last_offer['type']=='B':
            if last_offer['status']=='cancel':
                return
    else:
        if last_offer['type']=='S':
            if last_offer['status']=='cancel':
                return

    offer = {}
    offer['dt'] = datetime.datetime.now()
    offer['type'] = type
    offer['price'] = price
    offer['price2'] = price2
    offer['add_data'] = {'bb_data':bb_data,
                         'price_data':price_data,
                         'price_data':price_data,
                         'quotes':quotes}
    offer['order_num'] = None
    offer['send_res'] = ''
    offer['transact_id'] = None
    offer['status'] = 'new'
    offer['rowid'] = None

    transact_id = db.add_offer(offer)
    if transact_id is None:
        print(f"{datetime.datetime.now()} - Не удалось получить row id")
        offer['status'] = 'error'

    else:
        offer['rowid'] = transact_id
        offer['transact_id'] = transact_id

        db.update_offer(offer)

        price = str(round(int(price), -1))
        transact_id = str(transact_id)
        offer['status'] = 'accept'

        send_res = send_transaction_new_order(qpProvider, price, type, transact_id, account, classCode, secCode)

        offer['send_res'] = send_res
        if len(send_res)>0:
           offer['status'] = 'error'

        las_status_offer = get_offer_by_transact_id(offer['rowid'])
        if not las_status_offer['status']=='close':
            db.update_offer(offer)

def send_transaction_new_order(qpProvider, price, operation, trans_Id, account, classCode, secCode):
    transaction = {'TRANS_ID': trans_Id,
                   'CLIENT_CODE': '',
                   'ACCOUNT': account,
                   'ACTION': 'NEW_ORDER',
                   'CLASSCODE': classCode,
                   'SECCODE': secCode,
                   'OPERATION': operation,
                   'PRICE': price,
                   'QUANTITY': '1',
                   'TYPE': 'L'}

    # L = лимитная заявка (по умолчанию), 
    # M = рыночная заявка

    res = qpProvider.SendTransaction(transaction)

    error = ''
    if not res.get('lua_error') is None:
        error = res['lua_error']

    print(f"{datetime.datetime.now()} - Новая заявка отправлена {operation} {price} статус ошибки: {error}")

    message.send(f"{datetime.datetime.now()} - Новая заявка отправлена {operation} {price} статус ошибки: {error}")

    return error

def send_transaction_kill_order(qpProvider, trans_Id, account, classCode, secCode, orderNum):
    transaction = {'TRANS_ID': trans_Id,
                   'ACTION': 'KILL_ORDER',
                   'CLASSCODE': classCode,
                   'SECCODE': secCode,
                   'ORDER_KEY': orderNum}

    res = qpProvider.SendTransaction(transaction)

    error = ''
    if not res.get('lua_error') is None:
        error = res['lua_error']

    print(f"{datetime.datetime.now()} - Удаление заявки отправлено статус ошибки: {error}")

    message.send(f"{datetime.datetime.now()} - Удаление заявки отправлено статус ошибки: {error}")

    return error



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


