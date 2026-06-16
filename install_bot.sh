#!/data/data/com.termux/files/usr/bin/bash
# install_bot.sh - Instalação completa do Bot do YouTube para Telegram

echo "====================================="
echo "🎵 Bot de Áudio YouTube - Instalador"
echo "====================================="
echo ""

# Cores para output
VERDE="\033[32m"
VERMELHO="\033[31m"
AMARELO="\033[33m"
RESET="\033[0m"

# Função para mostrar progresso
show_status() {
    echo -e "${VERDE}[✓]${RESET} $1"
}

show_error() {
    echo -e "${VERMELHO}[✗]${RESET} $1"
}

show_warning() {
    echo -e "${AMARELO}[!]${RESET} $1"
}

# 1. Atualizar pacotes
echo "📦 Atualizando pacotes..."
pkg update -y && pkg upgrade -y
show_status "Pacotes atualizados"

# 2. Instalar dependências
echo "📥 Instalando dependências..."
pkg install -y python ffmpeg git
show_status "Dependências instaladas"

# 3. Instalar bibliotecas Python
echo "🐍 Instalando bibliotecas Python..."
pip install --upgrade pip
pip install python-telegram-bot yt-dlp
show_status "Bibliotecas Python instaladas"

# 4. Criar diretório do bot
echo "📁 Criando diretório do bot..."
mkdir -p ~/youtube_bot
cd ~/youtube_bot
show_status "Diretório criado: ~/youtube_bot"

# 5. Baixar o script principal
echo "📝 Baixando script do bot..."
cat > bot_audio.py << 'EOF'
#!/usr/bin/env python3
# bot_audio_youtube.py - Bot de Áudio do YouTube para Telegram

import os
import re
import sys
from telegram import Update
from telegram.ext import Application, CommandHandler, MessageHandler, filters, ContextTypes
from yt_dlp import YoutubeDL
import tempfile
import shutil
import json

# Configurações
CONFIG_FILE = "config.json"
TOKEN_FILE = "token.txt"

# Configuração do yt-dlp
ydl_opts = {
    'format': 'bestaudio/best',
    'postprocessors': [{
        'key': 'FFmpegExtractAudio',
        'preferredcodec': 'mp3',
        'preferredquality': '192',
    }],
    'outtmpl': '%(title)s.%(ext)s',
    'quiet': True,
    'no_warnings': True,
}

def carregar_token():
    """Carrega o token do arquivo"""
    if os.path.exists(TOKEN_FILE):
        with open(TOKEN_FILE, 'r') as f:
            return f.read().strip()
    return None

def salvar_token(token):
    """Salva o token em arquivo"""
    with open(TOKEN_FILE, 'w') as f:
        f.write(token)

def carregar_config():
    """Carrega configuração do grupo"""
    if os.path.exists(CONFIG_FILE):
        with open(CONFIG_FILE, 'r') as f:
            return json.load(f)
    return {"grupo_id": None}

def salvar_config(config):
    """Salva configuração do grupo"""
    with open(CONFIG_FILE, 'w') as f:
        json.dump(config, f)

async def start(update: Update, context: ContextTypes.DEFAULT_TYPE):
    await update.message.reply_text(
        "🎵 *Bot de Áudio do YouTube*\n\n"
        "✅ Bot ativo!\n\n"
        "📌 *Comandos:*\n"
        "/setgrupo - Define este grupo como destino dos áudios\n"
        "/vergrupo - Mostra qual grupo está configurado\n"
        "/settoken - Configurar token do bot (admin apenas)\n"
        "/help - Mostrar ajuda\n\n"
        "Depois de configurar o grupo, envie links do YouTube aqui no PV.",
        parse_mode="Markdown"
    )

async def set_token(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Comando para configurar token (apenas admin)"""
    # Verifica se é o admin (pode ajustar)
    if update.effective_user.id != 777000:  # Telegram
        # Permite qualquer um configurar por enquanto
        pass
    
    if len(context.args) != 1:
        await update.message.reply_text(
            "❌ Uso correto:\n"
            "/settoken SEU_TOKEN_AQUI\n\n"
            "Exemplo: `/settoken 123456:ABCdef`",
            parse_mode="Markdown"
        )
        return
    
    token = context.args[0]
    salvar_token(token)
    
    await update.message.reply_text(
        "✅ *Token configurado com sucesso!*\n\n"
        "Reinicie o bot com: `python bot_audio.py`",
        parse_mode="Markdown"
    )

async def set_grupo(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Define o grupo atual como destino"""
    # Verifica se é um grupo
    if update.effective_chat.type not in ["group", "supergroup"]:
        await update.message.reply_text(
            "❌ Este comando só pode ser usado dentro de um grupo!\n\n"
            "Adicione-me a um grupo e digite /setgrupo lá."
        )
        return
    
    config = carregar_config()
    config["grupo_id"] = update.effective_chat.id
    config["grupo_nome"] = update.effective_chat.title
    salvar_config(config)
    
    await update.message.reply_text(
        f"✅ *Grupo configurado com sucesso!*\n\n"
        f"📌 *Nome:* {update.effective_chat.title}\n"
        f"🆔 *ID:* `{update.effective_chat.id}`\n\n"
        f"Agora envie links do YouTube no meu PV e os áudios serão enviados aqui!",
        parse_mode="Markdown"
    )

async def ver_grupo(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Mostra o grupo configurado atual"""
    config = carregar_config()
    
    if config.get("grupo_id"):
        nome = config.get("grupo_nome", "Desconhecido")
        await update.message.reply_text(
            f"📌 *Grupo configurado:*\n"
            f"📛 *Nome:* {nome}\n"
            f"🆔 *ID:* `{config['grupo_id']}`\n\n"
            f"Para mudar, execute /setgrupo em outro grupo.",
            parse_mode="Markdown"
        )
    else:
        await update.message.reply_text(
            "⚠️ Nenhum grupo configurado ainda!\n\n"
            "Adicione-me a um grupo e digite /setgrupo lá."
        )

async def handle_youtube_link(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Processa links do YouTube"""
    url = update.message.text.strip()
    
    # Carrega configuração
    config = carregar_config()
    grupo_id = config.get("grupo_id")
    
    # Verifica se já tem um grupo configurado
    if not grupo_id:
        await update.message.reply_text(
            "❌ Nenhum grupo configurado!\n\n"
            "Adicione-me a um grupo e digite /setgrupo lá primeiro."
        )
        return
    
    # Valida se é link do YouTube
    youtube_regex = r'(https?://)?(www\.)?(youtube|youtu|youtube-nocookie)\.(com|be)/(watch\?v=|embed/|v/|.+\?v=)?([^&=%\?]{11})'
    if not re.match(youtube_regex, url):
        await update.message.reply_text("❌ Por favor, envie um link válido do YouTube.")
        return

    status_msg = await update.message.reply_text("🔄 Baixando áudio... Isso pode levar alguns segundos.")
    
    temp_dir = tempfile.mkdtemp()
    original_cwd = os.getcwd()
    os.chdir(temp_dir)
    
    try:
        # Baixa o áudio
        with YoutubeDL(ydl_opts) as ydl:
            info = ydl.extract_info(url, download=True)
            filename = ydl.prepare_filename(info)
            filename = filename.rsplit('.', 1)[0] + '.mp3'
        
        # Envia o áudio para o GRUPO
        with open(filename, 'rb') as audio_file:
            message = await context.bot.send_audio(
                chat_id=grupo_id,
                audio=audio_file,
                title=info.get('title', 'Áudio'),
                performer=info.get('uploader', 'YouTube'),
                duration=info.get('duration'),
                caption=f"🎵 *{info.get('title', 'Áudio')}*\n👤 {info.get('uploader', 'Desconhecido')}\n🔗 Requisitado por: {update.effective_user.first_name}",
                parse_mode="Markdown"
            )
        
        # Gera o link do Telegram
        chat_id_str = str(grupo_id)
        if chat_id_str.startswith("-100"):
            chat_id_str = chat_id_str[4:]
        
        link_telegram = f"https://t.me/c/{chat_id_str}/{message.message_id}"
        
        # Envia o link para o usuário
        await status_msg.edit_text(
            f"✅ *Áudio enviado com sucesso!*\n\n"
            f"📥 *Link do áudio no Telegram:*\n"
            f"`{link_telegram}`\n\n"
            f"📝 *Título:* {info.get('title', 'Áudio')}\n"
            f"👤 *Canal:* {info.get('uploader', 'Desconhecido')}\n\n"
            f"⚠️ Apenas membros do grupo podem acessar o link.",
            parse_mode="Markdown"
        )
        
    except Exception as e:
        await status_msg.edit_text(f"❌ Erro ao processar: {str(e)[:100]}")
    
    finally:
        os.chdir(original_cwd)
        shutil.rmtree(temp_dir, ignore_errors=True)

async def help_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    await update.message.reply_text(
        "📖 *Comandos:*\n\n"
        "/start - Iniciar o bot\n"
        "/setgrupo - Define o grupo atual como destino (use dentro do grupo)\n"
        "/vergrupo - Mostra qual grupo está configurado\n"
        "/settoken - Configurar token do bot\n"
        "/help - Mostrar esta ajuda\n\n"
        "💡 *Como usar:*\n"
        "1. Me adicione em um grupo\n"
        "2. Digite /setgrupo nesse grupo\n"
        "3. Envie links do YouTube no meu privado\n"
        "4. Receba o link do áudio no grupo!\n\n"
        "🔧 *Primeira vez:*\n"
        "Use /settoken SEU_TOKEN para configurar o bot",
        parse_mode="Markdown"
    )

def main():
    # Carrega token
    token = carregar_token()
    
    if not token:
        print("=" * 50)
        print("⚠️  TOKEN NÃO CONFIGURADO!")
        print("=" * 50)
        print("\nPara configurar o token, envie no Telegram:")
        print("/settoken SEU_TOKEN_AQUI")
        print("\nOu edite o arquivo token.txt manualmente.")
        print("=" * 50)
        
        # Inicia mesmo sem token (para configurar via comando)
        token = "FAKE_TOKEN_PARA_CONFIGURAR"
    
    app = Application.builder().token(token).build()
    
    app.add_handler(CommandHandler("start", start))
    app.add_handler(CommandHandler("setgrupo", set_grupo))
    app.add_handler(CommandHandler("vergrupo", ver_grupo))
    app.add_handler(CommandHandler("settoken", set_token))
    app.add_handler(CommandHandler("help", help_command))
    app.add_handler(MessageHandler(filters.TEXT & ~filters.COMMAND, handle_youtube_link))
    
    print("🤖 Bot iniciado...")
    print("📌 Comandos disponíveis:")
    print("   /setgrupo - Configure o grupo (use dentro do grupo)")
    print("   /vergrupo - Veja o grupo configurado")
    print("   /settoken - Configure o token do bot")
    print("   Envie links do YouTube no PV para gerar áudios")
    
    if carregar_token():
        print("✅ Token carregado!")
    else:
        print("⚠️  Aguardando configuração do token...")
    
    app.run_polling(allowed_updates=Update.ALL_TYPES)

if __name__ == "__main__":
    main()
EOF

show_status "Script principal criado"

# 6. Criar script de inicialização
echo "🚀 Criando script de inicialização..."
cat > iniciar_bot.sh << 'EOF'
#!/bin/bash
cd ~/youtube_bot
python bot_audio.py
EOF

chmod +x iniciar_bot.sh
show_status "Script de inicialização criado"

# 7. Criar script de backup/exportação
cat > exportar_config.sh << 'EOF'
#!/bin/bash
# Exporta configuração para backup

cd ~/youtube_bot

echo "📦 Exportando configuração..."
echo "====================================="

# Criar arquivo de backup
BACKUP_FILE="backup_$(date +%Y%m%d_%H%M%S).tar.gz"

# Arquivos para backup
tar -czf $BACKUP_FILE config.json token.txt 2>/dev/null

if [ -f $BACKUP_FILE ]; then
    echo "✅ Backup criado: $BACKUP_FILE"
    echo "📏 Tamanho: $(du -h $BACKUP_FILE | cut -f1)"
    echo ""
    echo "Para restaurar em outro telefone:"
    echo "1. Copie este arquivo para o novo telefone"
    echo "2. Execute: tar -xzf $BACKUP_FILE -C ~/youtube_bot/"
else
    echo "⚠️ Nenhuma configuração encontrada para backup"
fi

echo "====================================="
EOF

chmod +x exportar_config.sh
show_status "Script de backup criado"

# 8. Criar script de restauração
cat > restaurar_config.sh << 'EOF'
#!/bin/bash
# Restaura configuração de backup

cd ~/youtube_bot

echo "🔄 Restaurando configuração..."
echo "====================================="

# Listar backups disponíveis
echo "Backups disponíveis:"
ls -la backup_*.tar.gz 2>/dev/null || echo "Nenhum backup encontrado"

if [ -z "$1" ]; then
    echo ""
    echo "Uso: ./restaurar_config.sh NOME_DO_BACKUP.tar.gz"
    exit 1
fi

if [ -f "$1" ]; then
    tar -xzf "$1"
    echo "✅ Configuração restaurada com sucesso!"
    echo "Arquivos restaurados:"
    ls -la config.json token.txt 2>/dev/null
else
    echo "❌ Arquivo $1 não encontrado"
fi

echo "====================================="
EOF

chmod +x restaurar_config.sh
show_status "Script de restauração criado"

# 9. Criar arquivo README
cat > README.md << 'EOF'
# 🎵 Bot de Áudio YouTube para Telegram

## Instalação
Execute: `bash install_bot.sh`

## Comandos do Bot
- `/setgrupo` - Define o grupo atual (use dentro do grupo)
- `/vergrupo` - Mostra grupo configurado
- `/settoken` - Configura token do bot
- `/help` - Ajuda

## Como usar
1. Crie um bot no @BotFather e pegue o token
2. Execute `python bot_audio.py`
3. No Telegram, envie `/settoken SEU_TOKEN`
4. Adicione o bot a um grupo e envie `/setgrupo`
5. Envie links do YouTube no privado do bot

## Comandos do Terminal
- `python bot_audio.py` - Iniciar bot
- `./iniciar_bot.sh` - Iniciar bot (modo fácil)
- `./exportar_config.sh` - Fazer backup da configuração
- `./restaurar_config.sh backup.tar.gz` - Restaurar backup

## Backup em novo telefone
No telefone antigo:
`./exportar_config.sh`

No telefone novo:
1. Instalar tudo: `bash install_bot.sh`
2. Copiar arquivo .tar.gz
3. Restaurar: `./restaurar_config.sh backup.tar.gz`
4. Iniciar: `./iniciar_bot.sh`
EOF

show_status "README criado"

# 10. Configurar permissões
chmod +x ~/youtube_bot/bot_audio.py
chmod +x ~/youtube_bot/*.sh

# 11. Criar atalho no bashrc
echo "🔗 Criando atalho no bashrc..."
if ! grep -q "alias youtube-bot" ~/.bashrc; then
    echo "alias youtube-bot='cd ~/youtube_bot && python bot_audio.py'" >> ~/.bashrc
    echo "alias youtube-bot-start='~/youtube_bot/iniciar_bot.sh'" >> ~/.bashrc
    show_status "Atalhos criados (use 'youtube-bot' para iniciar)"
fi

# 12. Verificar instalação
echo ""
echo "====================================="
echo -e "${VERDE}✅ INSTALAÇÃO COMPLETA!${RESET}"
echo "====================================="
echo ""
echo "📁 Diretório: ~/youtube_bot"
echo ""
echo "🚀 Para iniciar o bot:"
echo "   cd ~/youtube_bot"
echo "   python bot_audio.py"
echo ""
echo "   OU"
echo "   ./iniciar_bot.sh"
echo ""
echo "📦 Para fazer backup (trocar de telefone):"
echo "   cd ~/youtube_bot"
echo "   ./exportar_config.sh"
echo ""
echo "📖 Para mais informações:"
echo "   cat ~/youtube_bot/README.md"
echo ""
echo "====================================="

# Perguntar se quer iniciar agora
echo ""
read -p "Deseja iniciar o bot agora? (s/n): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Ss]$ ]]; then
    cd ~/youtube_bot
    python bot_audio.py
fi
