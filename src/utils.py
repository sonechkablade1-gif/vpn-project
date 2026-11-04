import telebot


def main_keyboard():
    """Reply-клавиатура: кнопки внизу экрана, при нажатии отправляют текст."""
    markup = telebot.types.ReplyKeyboardMarkup(resize_keyboard=True)
    markup.add(
        telebot.types.KeyboardButton("⚡️ Подключиться"),
        telebot.types.KeyboardButton("📱 Приложение"),
    )
    return markup


def make_subscription_status_markup(is_active: bool) -> telebot.types.InlineKeyboardMarkup:
    markup = telebot.types.InlineKeyboardMarkup()
    back = telebot.types.InlineKeyboardButton("◀️ Назад", callback_data="menu")
    markup.add(back)
    return markup


def make_no_sub_markup():
    return main_keyboard()


def make_help_markup() -> telebot.types.InlineKeyboardMarkup:
    markup = telebot.types.InlineKeyboardMarkup()
    iphone_ipad = telebot.types.InlineKeyboardButton("iPhone/iPad", url="https://telegra.ph/Podklyuchenie-iPhone--iPad-10-18")
    android = telebot.types.InlineKeyboardButton("Android", url="https://telegra.ph/Podklyuchenie-Android-ustrojstva-10-18")
    windows = telebot.types.InlineKeyboardButton("Windows", url="https://telegra.ph/Podklyuchenie-Windows-PK-10-18")
    macos = telebot.types.InlineKeyboardButton("MacOS", url="https://telegra.ph/Podklyuchenie-Apple-MacBook-10-18")
    ru_services = telebot.types.InlineKeyboardButton("Настроить Ру-сервисы", url="https://telegra.ph/Instrukciya-kak-sdelat-ru-servisy-rabochimi-11-26")
    itembtn_str = telebot.types.InlineKeyboardButton("Назад", callback_data="back")
    markup.add(iphone_ipad, android)
    markup.add(windows, macos)
    markup.add(ru_services)
    markup.add(itembtn_str)
    return markup


