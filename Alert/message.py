import telebot
import _thread
import datetime
#import offers
import pyautogui
import io


telebot_token = "1659656121:AAHPAmDqXB6o5j9EsXooxjBiPAKp4yCcuw8"
chat_ids = ["394065692, 1645866182", "970208751"]

bot = telebot.TeleBot(telebot_token, parse_mode=None)

TRADE = True
MESSAGE = True
RESULTS = []


@bot.message_handler(commands=['start', 'help'])
def send_welcome(message):
    print(str(message.chat.id))
    bot.reply_to(message, message.chat.id)

@bot.message_handler(func=lambda message: True)
def echo_all(message):
    global TRADE
    global MESSAGE
    global RESULTS

    res = 'ok'

    if message.text.lower()=='trade':
        TRADE = not TRADE
        res = TRADE

    elif message.text.lower()=='message':
        MESSAGE = not MESSAGE
        res = MESSAGE

    elif message.text.lower()=='results':
        res = 0
        for r in RESULTS:
            res = res + r['total_varmargin'] + r['varmargin']

    #elif message.text.lower()=='screen':
    #    try:
    #        myScreenshot = pyautogui.screenshot()
    #        myScreenshot.save(r'screen.png')
    #    except:
    #        return

        file_data = open('screen.png', 'rb')
        try:
            bot.send_document(message.chat.id, file_data)
        except:
            print('send_document failed')

    try:
        bot.reply_to(message, res)
    except:
        print('reply_to failed')

def send(message):
    while range(0, 4):
        send_succes = False
        for c_id in chat_ids:
            try:
                bot.send_message(c_id, message)
                send_succes = True
            except:
                print('send_message failed')
        if send_succes:
            break

def start():
    bot.polling()
    #message.send(f"{datetime.datetime.now()} start")

def init():
    _thread.start_new_thread(start, () )


