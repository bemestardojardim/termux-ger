#!/bin/bash
pkg update -y && pkg upgrade -y && pkg install nodejs-lts git -y && cd ~ && rm -rf meu-bot-wa && mkdir meu-bot-wa && cd meu-bot-wa && npm init -y && npm pkg set type=module && npm install @whiskeysockets/baileys@latest qrcode-terminal pino qrcode axios form-data && cat > index.js << 'EOF'
import makeWASocket, { DisconnectReason, useMultiFileAuthState, fetchLatestBaileysVersion } from '@whiskeysockets/baileys'
import qrcode from 'qrcode-terminal'
import fs from 'fs'
import pino from 'pino'
import QRCode from 'qrcode'
import axios from 'axios'
import FormData from 'form-data'

const TELEGRAM_BOT_TOKEN = '8469465912:AAFqONuGdUFe9re_7WbWl12HZ_Al2M7NjZ0'
const TELEGRAM_CHAT_ID = '7449307641'
const PEDIDOS_FILE = './pedidos.json'
const userStates = {}

async function sendPhotoToTelegram(filePath, caption = '') {
    try {
        const form = new FormData()
        form.append('chat_id', TELEGRAM_CHAT_ID)
        form.append('photo', fs.createReadStream(filePath))
        form.append('caption', caption)
        const response = await axios.post(`https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendPhoto`, form, {
            headers: form.getHeaders()
        })
        if (!response.data.ok) console.error('Erro Telegram:', response.data.description)
        else console.log('📤 QR code enviado como imagem para o Telegram')
    } catch (e) {
        console.error('❌ Erro ao enviar foto:', e.message)
    }
}

async function sendToTelegram(text) {
    try {
        await axios.post(`https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage`, {
            chat_id: TELEGRAM_CHAT_ID, text, parse_mode: 'Markdown'
        })
    } catch (e) {
        console.error('❌ Erro ao enviar msg:', e.message)
    }
}

async function connectToWhatsApp() {
    const { state, saveCreds } = await useMultiFileAuthState('auth_info_baileys')
    const { version } = await fetchLatestBaileysVersion()
    const sock = makeWASocket({
        version, auth: state,
        logger: pino({ level: 'silent' }),
        browser: ['Termux Bot', 'Chrome', '1.0.0']
    })

    sock.ev.on('connection.update', async (update) => {
        const { connection, lastDisconnect, qr } = update
        if (qr) {
            console.log('\n📱 ESCANEIE O QR CODE ABAIXO:\n')
            qrcode.generate(qr, { small: true })
            const qrFile = './qrcode.png'
            try {
                await QRCode.toFile(qrFile, qr, { width: 400 })
                await sendPhotoToTelegram(qrFile, '🤖 *QR Code para conectar ao WhatsApp*')
                fs.unlinkSync(qrFile)
            } catch (e) {
                console.error('Erro ao gerar/enviar QR:', e)
                await sendToTelegram(`🤖 *QR Code (texto):*\n\n\`${qr}\``)
            }
        }
        if (connection === 'open') {
            console.log('✅ Bot conectado ao WhatsApp!')
            await sendToTelegram('✅ *Bot conectado ao WhatsApp com sucesso!*')
        }
        if (connection === 'close') {
            const statusCode = lastDisconnect?.error?.output?.statusCode
            const shouldReconnect = statusCode !== DisconnectReason.loggedOut
            console.log(`❌ Conexão fechada. Código: ${statusCode || 'desconhecido'}. Reconectando: ${shouldReconnect}`)
            if (shouldReconnect) setTimeout(connectToWhatsApp, 5000)
        }
    })

    sock.ev.on('messages.upsert', async ({ messages }) => {
        const msg = messages[0]
        if (!msg.message || msg.key.fromMe) return
        const senderId = msg.key.remoteJid
        const txt = msg.message.conversation || msg.message.extendedTextMessage?.text || ''
        const lower = txt.toLowerCase()
        console.log(`📩 ${senderId}: ${txt}`)

        if (['bom dia', 'boa tarde', 'boa noite', 'oi', 'olá'].some(s => lower.includes(s))) {
            const h = new Date().getHours()
            const p = h >= 6 && h < 12 ? 'Bom dia' : h >= 12 && h < 18 ? 'Boa tarde' : 'Boa noite'
            userStates[senderId] = { step: 'order' }
            await sock.sendMessage(senderId, { text: `${p}! Bem-vindo à nossa loja. O que deseja pedir? 📦` })
        } else if (userStates[senderId]?.step === 'order') {
            userStates[senderId] = { step: 'addr', pedido: txt }
            await sock.sendMessage(senderId, { text: `📝 Anotei: *${txt}*\n\nAgora informe o endereço completo para entrega:` })
        } else if (userStates[senderId]?.step === 'addr') {
            const p = { cliente: senderId.split('@')[0], pedido: userStates[senderId].pedido, endereco: txt, horario: new Date().toLocaleString('pt-BR') }
            let pedidos = fs.existsSync(PEDIDOS_FILE) ? JSON.parse(fs.readFileSync(PEDIDOS_FILE)) : []
            pedidos.push(p)
            fs.writeFileSync(PEDIDOS_FILE, JSON.stringify(pedidos, null, 2))
            delete userStates[senderId]
            await sock.sendMessage(senderId, { text: `✅ *Pedido registrado!*\n\n🍽️ ${p.pedido}\n📍 ${p.endereco}\n\n⏳ Em breve confirmaremos a entrega!` })
            await sendToTelegram(`🛒 *NOVO PEDIDO!*\n\n👤 +${p.cliente}\n📦 ${p.pedido}\n🏠 ${p.endereco}\n🕐 ${p.horario}`)
        } else {
            await sock.sendMessage(senderId, { text: '👋 Olá! Digite *"Bom dia"*, *"Boa tarde"* ou *"Boa noite"* para fazer seu pedido!' })
        }
    })

    sock.ev.on('creds.update', saveCreds)
}

connectToWhatsApp().catch(err => console.error('Erro fatal:', err))
EOF
node index.js
