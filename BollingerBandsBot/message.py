import telebot
import _thread
import datetime


telebot_token = "1659656121:AAHPAmDqXB6o5j9EsXooxjBiPAKp4yCcuw8"
chat_ids = ["394065692", "1645866182"]

bot = telebot.TeleBot(telebot_token, parse_mode=None)

STOP_TRADE = False
CLOSE_ALL = False
TAKE = False
MESSAGE = True


@bot.message_handler(commands=['start', 'help'])
def send_welcome(message):
    bot.reply_to(message, message.chat.id)

@bot.message_handler(func=lambda message: True)
def echo_all(message):
    global STOP_TRADE
    global CLOSE_ALL
    global MESSAGE

    if message.text.lower()=='stop_trade':
        STOP_TRADE = True

    elif message.text.lower()=='start_trade':
        STOP_TRADE = False

    elif message.text.lower()=='take':
        TAKE = True
    elif message.text.lower()=='message':
        MESSAGE = not MESSAGE

    bot.reply_to(message, 'ok')

def send(message):
    global MESSAGE

    if MESSAGE:
        return

    for c_id in chat_ids:
        pass
        bot.send_message(c_id, message)

def start():
    bot.polling()
    message.send(f"{datetime.datetime.now()} start")

def init():
    _thread.start_new_thread(start, () )


