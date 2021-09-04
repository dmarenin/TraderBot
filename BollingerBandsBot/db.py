import sqlite3
import json
import datetime


def dict_factory(cursor, row):
    d = {}
    for idx, col in enumerate(cursor.description):
        d[col[0]] = row[idx]
    return d


con = sqlite3.connect('db.db')

con.row_factory = dict_factory

con.execute('pragma journal_mode = WAL')
con.execute('pragma synchronous = normal')
con.execute('pragma synchronous = normal')
con.execute('pragma temp_store = memory')
con.execute('pragma mmap_size = 30000000000')
con.execute('pragma page_size = 32768')
con.execute('pragma vacuum')
con.execute('pragma optimize')
con.execute('pragma auto_vacuum = incremental')
con.execute('pragma incremental_vacuum')


def dt_to_sql(dt):
    return int(dt.timestamp()*1000000)

def sql_to_dt(dt):
    return datetime.datetime.fromtimestamp(dt/1000000)

def log(event, data=None, dt=None):
    if dt is None:
        dt = datetime.datetime.now()

    dt = dt_to_sql(dt)

    if data is None:
        data = ''
    else:
        try:
            data = json.dumps(data, default=json_serial)
        except:
            data = str(data)

    cur = con.cursor()

    cur.execute("insert into logs values (?, ?, ?)", (dt, event, data))

    con.commit()

    return cur.lastrowid

def add_offer(offer):
    dt = dt_to_sql(offer['dt'])
    type = offer['type']
    price = offer['price']
    price2 = offer['price2']
    add_data = json.dumps(offer['add_data'], default=json_serial)
    order_num = offer['order_num']
    send_res = offer['send_res']
    status = offer['status']
    transact_id = offer['transact_id']

    cur = con.cursor()

    cur.execute("insert into offers values (?, ?, ?, ?, ?, ?, ?, ?, ?)", (dt, type, price, price2, add_data, order_num, send_res, status, transact_id))

    try:
        con.commit()
    except:
        return None

    return cur.lastrowid

def update_offer(offer):
    if offer['rowid'] is None:
        return

    dt = dt_to_sql(offer['dt'])
    type = offer['type']
    price = offer['price']
    price2 = offer['price2']
    add_data = json.dumps(offer['add_data'], default=json_serial)
    order_num = offer['order_num']
    send_res = offer['send_res']
    status = offer['status']
    transact_id = offer['transact_id']
    rowid = offer['rowid']

    cur = con.cursor()

    cur.execute("update offers set dt=?, type=?, price=?, price2=?, add_data=?, order_num=?, send_res=?, status=?, transact_id=? where rowid = ?", (dt, type, price, price2, add_data, order_num, send_res, status, transact_id, rowid))

    try:
        con.commit()
    except:
        return None

    return cur.lastrowid

def get_offer(transact_id):
    cur = con.cursor()

    cur.execute("select *, rowid from offers WHERE rowid=?", (transact_id,))

    res = cur.fetchone()
    if not res is None:
        res['dt'] = sql_to_dt(res['dt'])
        res['add_data'] = json.loads(res['add_data'])

    return res

def get_last_offer(status=None):
    cur = con.cursor()

    if status is None:
        cur.execute("select *, rowid from offers order by rowid desc limit 1")
    else:
        cur.execute("select *, rowid from offers WHERE status=? order by rowid desc limit 1", (status,))

    res = cur.fetchone()
    if not res is None:
        res['dt'] = sql_to_dt(res['dt'])
        res['add_data'] = json.loads(res['add_data'])

    return res

def json_serial(obj):
    from datetime import datetime, date
    import decimal
    if isinstance(obj, (datetime, date)):
       return obj.isoformat()

    if isinstance(obj, decimal.Decimal):
       return float(obj)
    pass

