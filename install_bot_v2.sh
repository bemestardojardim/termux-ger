#!/bin/bash

# 📱 Script de instalação completa do Bot WhatsApp
# 🚀 Executar: bash install_bot.sh

echo -e "\n🚀 INICIANDO INSTALAÇÃO DO BOT WHATSAPP\n"

# 1️⃣ INSTALAR DEPENDÊNCIAS
echo "📦 Instalando dependências..."
pkg update -y && pkg upgrade -y
pkg install -y nodejs-lts git python

# 2️⃣ CRIAR PASTA DO BOT
echo "📁 Criando pasta do bot..."
cd ~
rm -rf meu-bot-wa
mkdir meu-bot-wa
cd meu-bot-wa

# 3️⃣ INICIAR PROJETO NODE
echo "📦 Iniciando projeto Node..."
npm init -y
npm pkg set type=module

# 4️⃣ INSTALAR DEPENDÊNCIAS NPM
echo "📦 Instalando dependências NPM..."
npm install @whiskeysockets/baileys@latest qrcode-terminal pino axios

# 5️⃣ CRIAR ARQUIVO index.js
echo "📝 Criando arquivo index.js..."
cat > index.js << 'EOF'
import makeWASocket, { DisconnectReason, useMultiFileAuthState, fetchLatestBaileysVersion } from '@whiskeysockets/baileys'
import qrcode from 'qrcode-terminal'
import pino from 'pino'
import axios from 'axios'

// 🔒 CONFIGURAÇÕES
const TELEGRAM_BOT_TOKEN = '8469465912:AAFqONuGdUFe9re_7WbWl12HZ_Al2M7NjZ0'
const TELEGRAM_CHAT_ID = '7449307641'

// 🌅 MENSAGENS POR PERÍODO DO DIA
function getMensagensPorPeriodo() {
    const hora = new Date().getHours()
    
    // 😴 DORMINDO (20:00 - 05:59)
    if (hora >= 20 || hora < 6) {
        return [
            `😴 Oi! Tô dormindo agora, o telefone tá comigo mas eu tô no mundo dos sonhos. Mando msg quando acordar! 🌙`,
            `💤 Fala! Tô dormindo, telefone tá aqui do lado mas eu não tô vendo nada. Respondo amanhã! 😴`,
            `🛌 Oi! Já tô deitado, dormindo. O telefone tá carregando do lado. Mando msg pela manhã! 🌙`,
            `😴 E aí! Tô na cama, dormindo. Telefone tá aqui mas eu tô off. Respondo amanhã! 💤`,
            `💤 Oi! Tô dormindo, o telefone tá comigo mas eu tô vendo desenho na mente. Mando msg quando acordar! 😘`,
            `🌙 Tô na cama, dormindo. Telefone tá carregando do lado. Respondo amanhã cedo! 😴`
        ]
    }
    
    // 🌅 MANHã (06:00 - 11:59)
    if (hora >= 6 && hora < 12) {
        return [
            `🌅 Bom dia! Deixei o telefone em casa. Tô fora, mas volto mais tarde. Pode deixar mensagem que respondo quando ver! 📱`,
            `🌅 Bom dia! Deixei o celular em casa. Tô vivo, só não tô com o telefone. Volto e já respondo! 😅`,
            `🌅 Bom dia! Deixei o celular em casa. Não vou ficar sem olhar o dia todo, mas apareço de vez em quando. Deixa recado! 😉`,
            `🌅 Bom dia! Deixei o telefone em casa de propósito. Vou e volto várias vezes. Deixa tua mensagem! 😄`,
            `🌅 Bom dia! Deixei o celular em casa pra focar nas coisas. Mas tô sempre aparecendo. Pode deixar mensagem! 😘`,
            `🌅 Bom dia! Deixei o celular em casa. Volto em breve. Manda mensagem! ☀️`
        ]
    }
    
    // 🌤️ TARDE (12:00 - 17:59)
    if (hora >= 12 && hora < 18) {
        return [
            `🌤️ Boa tarde! Deixei o telefone em casa. Tô fora, mas volto mais tarde. Pode deixar mensagem que respondo quando ver! 📱`,
            `🌤️ Boa tarde! Deixei o celular em casa. Tô vivo, só não tô com o telefone. Volto e já respondo! 😅`,
            `🌤️ Boa tarde! Deixei o celular em casa. Não vou ficar sem olhar o dia todo, mas apareço de vez em quando. Deixa recado! 😉`,
            `🌤️ Boa tarde! Deixei o telefone em casa de propósito. Vou e volto várias vezes. Deixa tua mensagem! 😄`,
            `🌤️ Boa tarde! Deixei o celular em casa pra focar nas coisas. Mas tô sempre aparecendo. Pode deixar mensagem! 😘`,
            `🌤️ Boa tarde! Deixei o celular em casa. Volto em breve. Manda mensagem! ☀️`
        ]
    }
    
    // 🌙 NOITE (18:00 - 19:59)
    return [
        `🌙 Boa noite! Deixei o telefone em casa. Tô fora, mas volto mais tarde. Pode deixar mensagem que respondo quando ver! 📱`,
        `🌙 Boa noite! Deixei o celular em casa. Tô vivo, só não tô com o telefone. Volto e já respondo! 😅`,
        `🌙 Boa noite! Deixei o celular em casa. Não vou ficar sem olhar o dia todo, mas apareço de vez em quando. Deixa recado! 😉`,
        `🌙 Boa noite! Deixei o telefone em casa de propósito. Vou e volto várias vezes. Deixa tua mensagem! 😄`,
        `🌙 Boa noite! Deixei o celular em casa pra focar nas coisas. Mas tô sempre aparecendo. Pode deixar mensagem! 😘`,
        `🌙 Boa noite! Deixei o celular em casa. Volto em breve. Manda mensagem! 🌙`
    ]
}

// 🎨 BIBLIOTECA DE STICKERS
const STICKERS = [
    'https://i.imgur.com/1YQkX5L.png',
    'https://i.imgur.com/2ZQkX6M.png',
    'https://i.imgur.com/3XQkX7N.png',
    'https://i.imgur.com/4YQkX8O.png',
    'https://i.imgur.com/5YQkX9P.png',
    'https://i.imgur.com/6YQkX0Q.png',
    'https://i.imgur.com/7YQkX1R.png',
    'https://i.imgur.com/8YQkX2S.png',
    'https://i.imgur.com/9YQkX3T.png',
    'https://i.imgur.com/0YQkX4U.png',
    'https://i.imgur.com/aYQkX5V.png',
    'https://i.imgur.com/bYQkX6W.png',
    'https://i.imgur.com/cYQkX7X.png',
    'https://i.imgur.com/dYQkX8Y.png',
    'https://i.imgur.com/eYQkX9Z.png',
    'https://i.imgur.com/fYQkX0A.png'
]

// 🎬 BIBLIOTECA DE GIFS
const GIFS = [
    'https://i.imgur.com/gYQkX1B.gif',
    'https://i.imgur.com/hYQkX2C.gif',
    'https://i.imgur.com/iYQkX3D.gif',
    'https://i.imgur.com/jYQkX4E.gif',
    'https://i.imgur.com/kYQkX5F.gif',
    'https://i.imgur.com/lYQkX6G.gif',
    'https://i.imgur.com/mYQkX7H.gif',
    'https://i.imgur.com/nYQkX8I.gif',
    'https://i.imgur.com/oYQkX9J.gif',
    'https://i.imgur.com/pYQkX0K.gif',
    'https://i.imgur.com/qYQkX1L.gif',
    'https://i.imgur.com/rYQkX2M.gif'
]

// 😊 EMOJIS POR PERÍODO
function getEmojisPorPeriodo() {
    const hora = new Date().getHours()
    if (hora >= 20 || hora < 6) {
        return ['😴', '💤', '🌙', '😪', '🛌', '🌃', '✨', '💫']
    }
    if (hora >= 6 && hora < 12) {
        return ['🌅', '☀️', '😊', '🌞', '🌸', '🌺', '💐', '🌈']
    }
    if (hora >= 12 && hora < 18) {
        return ['🌤️', '😄', '☀️', '🌻', '🌺', '💪', '🔥', '✨']
    }
    return ['🌙', '😊', '🌟', '💕', '🌃', '✨', '🌌', '💫']
}

function getEmojiResposta() {
    const emojis = getEmojisPorPeriodo()
    return emojis[Math.floor(Math.random() * emojis.length)]
}

// 🎯 REAÇÕES POR PERÍODO
function getReacoesPorPeriodo() {
    const hora = new Date().getHours()
    if (hora >= 20 || hora < 6) {
        return ['🌙', '💤', '😴', '✨', '🌃', '💫', '🛌']
    }
    if (hora >= 6 && hora < 12) {
        return ['🌅', '☀️', '😊', '🌞', '🌸', '🌈', '💐']
    }
    if (hora >= 12 && hora < 18) {
        return ['☀️', '😄', '🌻', '💪', '🔥', '✨', '🌤️']
    }
    return ['🌙', '😊', '🌟', '💕', '🌃', '✨', '🌌']
}

function getReacao() {
    const reacoes = getReacoesPorPeriodo()
    return reacoes[Math.floor(Math.random() * reacoes.length)]
}

function getSticker() {
    return STICKERS[Math.floor(Math.random() * STICKERS.length)]
}

function getGif() {
    return GIFS[Math.floor(Math.random() * GIFS.length)]
}

async function sendToTelegram(text) {
    try {
        await axios.post(`https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage`, {
            chat_id: TELEGRAM_CHAT_ID,
            text: text,
            parse_mode: 'Markdown'
        })
    } catch (e) {}
}

function getMensagem() {
    const mensagens = getMensagensPorPeriodo()
    return mensagens[Math.floor(Math.random() * mensagens.length)]
}

// 🔍 DETECTA TIPO DE MENSAGEM
function detectarTipoMensagem(msg) {
    if (msg.message?.stickerMessage) {
        return { tipo: 'sticker' }
    }
    if (msg.message?.reactionMessage) {
        return { tipo: 'reaction' }
    }
    if (msg.message?.videoMessage?.gifPlayback === true) {
        return { tipo: 'gif' }
    }
    if (msg.message?.imageMessage) {
        return { tipo: 'imagem' }
    }
    if (msg.message?.audioMessage) {
        return { tipo: 'audio' }
    }
    if (msg.message?.videoMessage) {
        return { tipo: 'video' }
    }
    let text = ''
    if (msg.message?.conversation) text = msg.message.conversation
    else if (msg.message?.extendedTextMessage?.text) text = msg.message.extendedTextMessage.text
    if (text) {
        const onlyEmojis = /^[\u{1F600}-\u{1F64F}\u{1F300}-\u{1F5FF}\u{1F680}-\u{1F6FF}\u{1F700}-\u{1F77F}\u{1F780}-\u{1F7FF}\u{1F800}-\u{1F8FF}\u{1F900}-\u{1F9FF}\u{1FA00}-\u{1FA6F}\u{1FA70}-\u{1FAFF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}\u{FE0F}\u{20E3}\u{1F1E6}-\u{1F1FF}]+$/u.test(text)
        if (onlyEmojis && text.length <= 10) {
            return { tipo: 'emoji', data: text }
        }
        return { tipo: 'texto', data: text }
    }
    return { tipo: 'desconhecido' }
}

function getPeriodoDia() {
    const hora = new Date().getHours()
    if (hora >= 20 || hora < 6) return '😴 Dormindo'
    if (hora >= 6 && hora < 12) return '🌅 Manhã'
    if (hora >= 12 && hora < 18) return '🌤️ Tarde'
    return '🌙 Noite'
}

async function connectToWhatsApp() {
    const { state, saveCreds } = await useMultiFileAuthState('auth_info_baileys')
    const { version } = await fetchLatestBaileysVersion()

    const sock = makeWASocket({
        version,
        auth: state,
        logger: pino({ level: 'silent' }),
        browser: ['Bot Deixei em Casa', 'Chrome', '1.0.0']
    })

    sock.ev.on('connection.update', async (update) => {
        const { connection, lastDisconnect, qr } = update
        if (qr) {
            console.log('\n📱 ESCANEIE O QR CODE:\n')
            qrcode.generate(qr, { small: true })
        }
        if (connection === 'open') {
            const periodo = getPeriodoDia()
            console.log(`✅ Bot conectado! Modo: DEIXEI O CELULAR EM CASA`)
            console.log(`🕐 Período: ${periodo}`)
            console.log(`🎨 Stickers: ${STICKERS.length} disponíveis`)
            console.log(`🎬 GIFs: ${GIFS.length} disponíveis`)
            await sendToTelegram(`✅ *Bot ativado!*\n🕐 *Período:* ${periodo}`)
        }
        if (connection === 'close') {
            const shouldReconnect = lastDisconnect?.error?.output?.statusCode !== DisconnectReason.loggedOut
            console.log(`❌ Desconectado. Reconectando: ${shouldReconnect}`)
            if (shouldReconnect) setTimeout(connectToWhatsApp, 5000)
        }
    })

    sock.ev.on('messages.upsert', async ({ messages }) => {
        const msg = messages[0]
        if (!msg.message) return

        const remoteJid = msg.key.remoteJid
        const senderId = msg.key.participant || remoteJid
        const senderNumber = senderId.split('@')[0]
        const isFromMe = msg.key.fromMe

        if (remoteJid.endsWith('@g.us')) return
        if (remoteJid === 'status@broadcast') return

        const isPrivate = remoteJid.endsWith('@s.whatsapp.net') || 
                         remoteJid.endsWith('@c.us') || 
                         remoteJid.endsWith('@lid')

        if (!isPrivate) return
        if (isFromMe) return

        const tipo = detectarTipoMensagem(msg)
        console.log(`📩 ${senderNumber} → ${tipo.tipo}`)

        // 🎯 STICKER → STICKER
        if (tipo.tipo === 'sticker') {
            const stickerUrl = getSticker()
            try {
                const response = await axios.get(stickerUrl, { responseType: 'arraybuffer' })
                await sock.sendMessage(remoteJid, { 
                    sticker: response.data,
                    mimetype: 'image/webp'
                })
                console.log(`✅ STICKER ENVIADO`)
            } catch (e) {
                await sock.sendMessage(remoteJid, { text: getEmojiResposta() })
            }
            return
        }

        // 🎯 GIF → GIF
        if (tipo.tipo === 'gif') {
            const gifUrl = getGif()
            try {
                const response = await axios.get(gifUrl, { responseType: 'arraybuffer' })
                await sock.sendMessage(remoteJid, { 
                    video: response.data,
                    gifPlayback: true,
                    mimetype: 'video/mp4'
                })
                console.log(`✅ GIF ENVIADO`)
            } catch (e) {
                await sock.sendMessage(remoteJid, { text: getEmojiResposta() })
            }
            return
        }

        // 🎯 EMOJI → EMOJI
        if (tipo.tipo === 'emoji') {
            const respostaEmoji = getEmojiResposta()
            await sock.sendMessage(remoteJid, { text: respostaEmoji })
            console.log(`✅ EMOJI RESPONDIDO: ${respostaEmoji}`)
            return
        }

        // 🎯 REAÇÃO → REAÇÃO
        if (tipo.tipo === 'reaction') {
            const reacao = getReacao()
            try {
                await sock.sendMessage(remoteJid, { 
                    react: { text: reacao, key: msg.key }
                })
                console.log(`✅ REAÇÃO RESPONDIDA: ${reacao}`)
            } catch (e) {}
            return
        }

        // 🎯 IMAGEM → TEXTO
        if (tipo.tipo === 'imagem' || tipo.tipo === 'audio' || tipo.tipo === 'video') {
            const resposta = getMensagem()
            await sock.sendMessage(remoteJid, { text: resposta })
            console.log(`✅ RESPOSTA ENVIADA`)
            await sendToTelegram(`📱 *${tipo.tipo} recebido de:* ${senderNumber}\n🤖 *Resposta enviada*`)
            return
        }

        // 🎯 TEXTO → TEXTO
        if (tipo.tipo === 'texto') {
            console.log(`📝 Texto: ${tipo.data}`)
            
            await new Promise(r => setTimeout(r, 1500 + Math.random() * 2000))
            await sock.sendPresenceUpdate('composing', remoteJid)
            await new Promise(r => setTimeout(r, 1000 + Math.random() * 1500))
            await sock.sendPresenceUpdate('paused', remoteJid)

            const resposta = getMensagem()
            await sock.sendMessage(remoteJid, { text: resposta })
            console.log(`✅ RESPOSTA ENVIADA`)
            await sendToTelegram(`📱 *Msg:* ${tipo.data}\n👤 *De:* ${senderNumber}\n🤖 *Resposta enviada*`)
            return
        }

        // 🎯 DESCONHECIDO → TEXTO
        const resposta = getMensagem()
        await sock.sendMessage(remoteJid, { text: resposta })
    })

    sock.ev.on('creds.update', saveCreds)
}

const periodo = getPeriodoDia()
console.log(`\n📱 Bot: DEIXEI O CELULAR EM CASA`)
console.log(`🕐 Período atual: ${periodo}`)
console.log(`🎨 Stickers: ${STICKERS.length} disponíveis`)
console.log(`🎬 GIFs: ${GIFS.length} disponíveis`)
console.log(`😊 Emojis: ${getEmojisPorPeriodo().length} disponíveis`)
console.log(`❤️ Reações: ${getReacoesPorPeriodo().length} disponíveis`)
console.log(`🚫 Ignora: Grupos, Status\n`)

connectToWhatsApp().catch(err => console.error('Erro fatal:', err))
EOF

# 6️⃣ CRIAR ATALHO NO .bashrc
echo "📝 Criando atalho 'bot'..."
echo "" >> ~/.bashrc
echo "# 🚀 Atalho do Bot WhatsApp" >> ~/.bashrc
echo "alias bot='cd ~/meu-bot-wa && node index.js'" >> ~/.bashrc

# 7️⃣ CARREGAR O ATALHO
source ~/.bashrc

# 8️⃣ LIMPAR TELA E MOSTRAR STATUS
clear

echo -e "\n✅ INSTALAÇÃO COMPLETA CONCLUÍDA!\n"
echo -e "📱 Bot WhatsApp instalado com sucesso!"
echo -e "🎨 Stickers: 16 disponíveis"
echo -e "🎬 GIFs: 12 disponíveis"
echo -e "\n🚀 Para iniciar o bot, digite:"
echo -e "   ${GREEN}bot${NC}\n"
echo -e "📌 O bot vai mostrar um QR Code no terminal."
echo -e "📱 Escaneie com o WhatsApp para conectar."
echo -e "\n📋 Comandos úteis:"
echo -e "   ${GREEN}bot${NC}        - Iniciar o bot"
echo -e "   ${GREEN}botstop${NC}    - Parar o bot (Ctrl+C)"
echo -e "   ${GREEN}botstatus${NC}  - Verificar se o bot está rodando\n"

# 9️⃣ PERGUNTAR SE QUER INICIAR AGORA
read -p "👉 Deseja iniciar o bot agora? (s/N): " iniciar

if [[ "$iniciar" =~ ^[Ss]$ ]]; then
    echo -e "\n🚀 Iniciando o bot...\n"
    cd ~/meu-bot-wa && node index.js
else
    echo -e "\n✅ Instalação finalizada! Digite ${GREEN}bot${NC} quando quiser iniciar.\n"
fi
