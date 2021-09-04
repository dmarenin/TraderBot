import telebot
import _thread
import datetime
import offers


telebot_token = "1659656121:AAHPAmDqXB6o5j9EsXooxjBiPAKp4yCcuw8"
chat_ids = ["394065692"] #, "1645866182"]

bot = telebot.TeleBot(telebot_token, parse_mode=None)

TRADE = True
MESSAGE = True


@bot.message_handler(commands=['start', 'help'])
def send_welcome(message):
    bot.reply_to(message, message.chat.id)

@bot.message_handler(func=lambda message: True)
def echo_all(message):
    global TRADE
    global MESSAGE

    res = 'ok'

    if message.text.lower()=='trade':
        TRADE = not TRADE
        res = TRADE

    elif message.text.lower()=='message':
        MESSAGE = not MESSAGE
        res = MESSAGE

    elif message.text.lower()=='profits':
        res = offers.profits()

    bot.reply_to(message, res)

def send(message):
    global MESSAGE

    if not MESSAGE:
        return

    for c_id in chat_ids:
        bot.send_message(c_id, message)

def start():
    bot.polling()
    message.send(f"{datetime.datetime.now()} start")

def init():
    _thread.start_new_thread(start, () )


