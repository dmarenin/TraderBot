import datetime
import random
import time


def add_offer(qpProvider, price, type, account, classCode, secCode, multiplicity):
    if multiplicity<=0:
        price = str(int(price))
    else:
        price = str(round(price, multiplicity))

    dt = datetime.datetime.now()

    transact_id = str(round(dt.timestamp()))

    send_res = send_transaction_new_order(qpProvider, price, type, transact_id, account, classCode, secCode)

    if len(send_res)==0:
        return transact_id
    else:
        return 0

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
                   #'EXECUTION_CONDITION':'FILL_OR_KILL',
                   'TYPE': 'L'}

    # L = лимитная заявка (по умолчанию), 
    # M = рыночная заявка

    res = qpProvider.SendTransaction(transaction)

    error = ''
    if not res.get('lua_error') is None:
        error = res['lua_error']

    print(f"{datetime.datetime.now()} - Новая заявка отправлена {operation} {price} статус ошибки: {error}")

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


