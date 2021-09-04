import telebot
import _thread
import datetime


telebot_token = "1659656121:AAHPAmDqXB6o5j9EsXooxjBiPAKp4yCcuw8"
chat_ids = ["394065692", "1645866182"]

bot = telebot.TeleBot(telebot_token, parse_mode=None)


@bot.message_handler(commands=['start', 'help'])
def send_welcome(message):
    bot.reply_to(message, message.chat.id)

@bot.message_handler(func=lambda message: True)
def echo_all(message):
    bot.reply_to(message, 'buy')

def send(message):
    for c_id in chat_ids:
        pass
        bot.send_message(c_id, message)

def start():
    bot.polling()
    message.send(f"{datetime.datetime.now()} start")

def init():
    _thread.start_new_thread(start, () )


