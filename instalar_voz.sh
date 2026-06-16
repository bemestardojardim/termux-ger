#!/bin/bash

echo "========================================"
echo "🎤 INSTALANDO LEITOR DE VOZ (EDGE-TTS)"
echo "========================================"
echo ""

# 1. Atualizar e instalar dependências
echo "📦 Instalando dependências..."
pkg update -y && pkg upgrade -y
pkg install -y python python-pip ffmpeg mpv

# 2. Instalar edge-tts
echo "📦 Instalando edge-tts..."
pip install edge-tts

# 3. Criar pasta para áudios
echo "📁 Criando pasta de áudios..."
mkdir -p ~/audios_gravados

# 4. Criar script principal
echo "🐍 Criando script leitor_auto.py..."
cat > ~/leitor_auto.py << 'EOF'
#!/usr/bin/env python3

import asyncio
import sys
import os
import subprocess
from datetime import datetime

PASTA_AUDIOS = os.path.expanduser("~/audios_gravados")
os.makedirs(PASTA_AUDIOS, exist_ok=True)

async def gerar_e_reproduzir(texto):
    voz = "pt-BR-FranciscaNeural"
    texto = texto.strip().replace('"', "'").replace('\n', ' ')
    texto = ' '.join(texto.split())
    if not texto:
        print("❌ Texto vazio!")
        return
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    nome_arquivo = f"audio_{timestamp}.mp3"
    caminho_local = os.path.join(PASTA_AUDIOS, nome_arquivo)
    print(f"🎤 Gerando áudio: {texto[:50]}..." if len(texto) > 50 else f"🎤 Gerando áudio: {texto}")
    texto_escapado = texto.replace('"', '\\"').replace('$', '\\$').replace('`', '\\`')
    cmd = f'edge-tts --text "{texto_escapado}" --voice {voz} --write-media {caminho_local}'
    process = await asyncio.create_subprocess_shell(cmd, stdout=asyncio.subprocess.PIPE, stderr=asyncio.subprocess.PIPE)
    await process.communicate()
    if os.path.exists(caminho_local) and os.path.getsize(caminho_local) > 0:
        print(f"✅ Áudio gerado! Reproduzindo...")
        subprocess.run(['mpv', caminho_local])
        print("✅ Finalizado!")
    else:
        print("❌ Erro ao gerar áudio. Verifique sua internet.")

if __name__ == "__main__":
    if len(sys.argv) > 1:
        texto = " ".join(sys.argv[1:])
        asyncio.run(gerar_e_reproduzir(texto))
    else:
        print("🎤 Modo interativo")
        texto = input("📝 Digite o texto: ")
        asyncio.run(gerar_e_reproduzir(texto))
EOF

chmod +x ~/leitor_auto.py

# 5. Adicionar aliases ao .bashrc
echo "⚙️ Configurando comandos..."
cat >> ~/.bashrc << 'BASHEOF'

# Comandos de voz personalizados
voz() { 
    if [ -z "$1" ]; then 
        echo "📝 Digite o texto:"; 
        read texto; 
    else 
        texto="$*"; 
    fi; 
    python ~/leitor_auto.py "$texto"; 
}

alias c='clear'
alias ultimo='mpv ~/audios_gravados/$(ls -t ~/audios_gravados/*.mp3 2>/dev/null | head -1)'
alias audios='ls -la ~/audios_gravados/'
BASHEOF

# 6. Recarregar configurações
source ~/.bashrc

echo ""
echo "========================================"
echo "✅ INSTALAÇÃO CONCLUÍDA COM SUCESSO!"
echo "========================================"
echo ""
echo "🎯 COMANDOS DISPONÍVEIS:"
echo "   voz texto aqui     → Gera e toca áudio do texto"
echo "   voz                → Pergunta o texto interativamente"
echo "   c                  → Limpa a tela"
echo "   ultimo             → Toca o último áudio gerado"
echo "   audios             → Lista todos os áudios"
echo ""
echo "📱 Teste rápido:"
echo "   voz Olá, funcionou perfeitamente"
echo ""
echo "========================================"
