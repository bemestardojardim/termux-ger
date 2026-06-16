#!/bin/bash
echo "=================================================="
echo "     🤖 INSTALADOR AUTOMÁTICO DO BOT"
echo "=================================================="
pkg update -y && pkg upgrade -y
pkg install python ffmpeg flac git -y
pip install python-telegram-bot pydub SpeechRecognition
cat > ~/bot.py << 'BOTEOF'
from telegram import Update
from telegram.error import TelegramError
from telegram.ext import Application, MessageHandler, filters, ContextTypes
import os
import tempfile
import logging
from pydub import AudioSegment
import speech_recognition as sr

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

TOKEN = "8019734133:AAH94x6SRF_4YnsMIX8MXv3nV2Gh663K-H4"
PALAVRA_ATIVAR = "ativar"
ativo = True

async def transcrever(update: Update, context: ContextTypes.DEFAULT_TYPE):
    global ativo
    if not ativo:
        await update.message.reply_text("⏸️ Bot desativado. Envie 'ativar' em áudio para ligar.")
        return
    try:
        await update.message.reply_text("🎤 Processando áudio...")
        voice = await update.message.voice.get_file()
        with tempfile.NamedTemporaryFile(suffix=".ogg", delete=False) as ogg:
            await voice.download_to_drive(ogg.name)
            ogg_path = ogg.name
        wav_path = ogg_path.replace(".ogg", ".wav")
        audio = AudioSegment.from_ogg(ogg_path)
        audio.export(wav_path, format="wav")
        recognizer = sr.Recognizer()
        with sr.AudioFile(wav_path) as source:
            audio_data = recognizer.record(source)
        texto = recognizer.recognize_google(audio_data, language="pt-BR")
        if PALAVRA_ATIVAR in texto.lower():
            global ativo
            ativo = True
            await update.message.reply_text(f"✅ Bot ativado! Você disse: '{texto}'")
        else:
            await update.message.reply_text(f"📝 Transcrição: {texto}")
        os.remove(ogg_path)
        os.remove(wav_path)
    except Exception as e:
        await update.message.reply_text(f"❌ Erro: {str(e)[:100]}")

async def comando_texto(update: Update, context: ContextTypes.DEFAULT_TYPE):
    global ativo
    texto = update.message.text.lower()
    if texto == "/start":
        await update.message.reply_text("🤖 Bot de transcrição ativo!\n/on - Ligar\n/off - Desligar\n/status - Ver estado")
    elif texto == "/on":
        ativo = True
        await update.message.reply_text("✅ Bot ligado!")
    elif texto == "/off":
        ativo = False
        await update.message.reply_text("⏸️ Bot desligado!")
    elif texto == "/status":
        status = "✅ ATIVO" if ativo else "⏸️ DESATIVADO"
        await update.message.reply_text(f"Status: {status}")

def main():
    app = Application.builder().token(TOKEN).build()
    app.add_handler(MessageHandler(filters.VOICE, transcrever))
    app.add_handler(MessageHandler(filters.TEXT & ~filters.COMMAND, comando_texto))
    print("\n🤖 BOT ATIVO!\n📌 Palavra: 'ativar'\n📌 Comandos: /on, /off, /status, /start\n")
    app.run_polling()

if __name__ == "__main__":
    main()
BOTEOF
mkdir -p ~/audios_gravados
cat >> ~/.bashrc << 'BASHEOF'

alias bot="cd ~ && python bot.py"
alias audios="ls -la ~/audios_gravados/"
alias c="clear"
alias ouvir="mpv ~/audios_gravados/\$(ls -t ~/audios_gravados/*.mp3 2>/dev/null | head -1)"
alias ultimo="mpv ~/audios_gravados/\$(ls -t ~/audios_gravados/*.mp3 2>/dev/null | head -1)"
comandos() {
    echo -e "\n\033[1;34m==================================================\033[0m"
    echo -e "\033[1;33m        📋 SEUS COMANDOS PERSONALIZADOS\033[0m"
    echo -e "\033[1;34m==================================================\033[0m"
    echo -e "\n\033[1;32m► ALIASES:\033[0m"
    echo -e "  \033[0;36mbot\033[0m      → Iniciar bot"
    echo -e "  \033[0;36maudios\033[0m   → Listar áudios"
    echo -e "  \033[0;36mc\033[0m        → Limpar tela"
    echo -e "  \033[0;36mouvir\033[0m   → Tocar último áudio"
    echo -e "\n\033[1;32m► COMANDOS DO BOT:\033[0m"
    echo -e "  \033[0;33m/on\033[0m      → Ligar"
    echo -e "  \033[0;33m/off\033[0m     → Desligar"
    echo -e "  \033[0;33m/status\033[0m  → Ver status"
    echo -e "\n\033[1;34m==================================================\033[0m"
    echo -e "\033[1;35m💡 Digite 'bot' para iniciar\033[0m\n"
}
export PS1='\033[1;32m\w\033[0m \$ '
BASHEOF
source ~/.bashrc
echo "✅ INSTALAÇÃO CONCLUÍDA! Digite 'bot' para iniciar"
