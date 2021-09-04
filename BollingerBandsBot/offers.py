import datetime
import db
import message


take = 200


def get_offer_by_transact_id(transact_id):
    res = db.get_offer(transact_id)

def garbage_collect(qpProvider, account, classCode, secCode):
    last_offer = get_last_offer()

    status = last_offer['status']
    if status=='new':
        if (datetime.datetime.now()-last_offer['dt']).seconds>30:
            last_offer['send_res'] = last_offer['send_res']+'\n'+'Смена статуса с new на cancel'
            last_offer['status'] ='cancel'

            db.update_offer(last_offer)

    elif status=='accept':
        if (datetime.datetime.now()-last_offer['dt']).seconds>30:
            last_offer['send_res'] = last_offer['send_res']+'\n'+'Смена статуса с accept на cancel'
            last_offer['status'] ='cancel'

            trans_Id = str(random.randint(1, 100000))
            orderNum = str(last_offer['order_num'])

            send_transaction_kill_order(qpProvider, trans_Id, account, classCode, secCode, orderNum)

            db.update_offer(last_offer)

    elif status=='close':
        pass

    elif status=='cancel':
        pass

    elif status=='error':
        last_offer['send_res'] = last_offer['send_res']+'\n'+'Смена статуса с error на cancel'
        last_offer['status'] ='cancel'

        db.update_offer(last_offer)

    print(f"{datetime.datetime.now()} - Смена статуса {status} - {last_offer['status']}")

    message.send(f"{datetime.datetime.now()} - Смена статуса {status} - {last_offer['status']}")

def update(data):
    trans_Id = data['data']['trans_id']

    offer = get_offer_by_transact_id(trans_Id)

    if offer['order_num'] is None:
        if len(data['data']['order_num'])>0:
            offer['order_num'] = int(data['data']['order_num'])
            db.update_offer(offer)

    if offer['type']=='B' and int(data['data']['balance'])==0:
        if offer['order_num'] != int(data['data']['order_num']):
            print("offer['order_num'] != int(data['data']['order_num'])")

        offer['order_num'] = int(data['data']['order_num'])
        offer['status'] = 'close'

        print(f"{datetime.datetime.now()} - Заявка выполнена {offer['type']} {offer['price']}")

        message.send(f"{datetime.datetime.now()} - Заявка выполнена {offer['type']} {offer['price']}")

        db.update_offer(offer)


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

def get_take():
    res = get_last_offer()

    if res is None:
        return 0

    return res['price']+take

def add_offer(qpProvider, price, price2, type, bb_data, price_data, quotes, account, classCode, secCode):
    last_offer = get_last_offer()

    status_close = ['close', 'cancel']

    if not last_offer is None:
        if not last_offer['status'] in status_close:
            return

        if type=='B':
            if last_offer['type']=='B':
                return

        elif type=='S':
            if last_offer['type']=='S':
                return

    else:
        if type=='S':
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

        price = str(round(int(price), -1))
        transact_id = str(transact_id)

        send_res = send_transaction_new_order(qpProvider, price, type, transact_id, account, classCode, secCode)

        offer['status'] = 'accept'
        offer['send_res'] = send_res
        if len(send_res)>0:
           offer['status'] = 'error'

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


