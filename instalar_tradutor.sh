#!/bin/bash

# ============================================
# INSTALADOR COMPLETO - Tradutor de Vídeos
# ============================================

echo "=========================================="
echo "🎬 INSTALANDO TRADUTOR DE VÍDEOS"
echo "=========================================="
echo ""

# 1. Atualizar pacotes
echo "[1/7] Atualizando Termux..."
pkg update -y && pkg upgrade -y

# 2. Instalar dependências
echo "[2/7] Instalando dependências..."
pkg install -y git ffmpeg python clang cmake make ninja

# 3. Instalar Python e pip
echo "[3/7] Configurando Python..."
pip install --upgrade pip

# 4. Instalar deep-translator
echo "[4/7] Instalando tradutor..."
pip install deep-translator

# 5. Instalar Whisper.cpp
echo "[5/7] Instalando Whisper.cpp (pode levar alguns minutos)..."
cd ~
git clone https://github.com/ggerganov/whisper.cpp
cd whisper.cpp
make -j4

# 6. Baixar modelo small
echo "[6/7] Baixando modelo de tradução (small)..."
./models/download-ggml-model.sh small

# 7. Criar scripts
echo "[7/7] Criando scripts..."
cd ~

# Script de tradução Python
cat > ~/traduzir_srt.py << 'EOF'
import sys
import os
import re
import time

try:
    from deep_translator import GoogleTranslator
    translator = GoogleTranslator(source='es', target='pt')
except ImportError:
    print("Instalando deep-translator...")
    os.system("pip install deep-translator -q")
    from deep_translator import GoogleTranslator
    translator = GoogleTranslator(source='es', target='pt')

if len(sys.argv) < 2:
    print("Uso: python traduzir_srt.py /caminho/arquivo.srt")
    sys.exit(1)

input_file = sys.argv[1]
output_file = input_file.replace('.srt', '_PT.srt')

print(f"📄 Traduzindo: {input_file}")
print("⏳ Aguarde...")

def translate_text(text):
    try:
        return translator.translate(text)
    except Exception as e:
        print(f"Erro ao traduzir: {e}")
        return text

with open(input_file, 'r', encoding='utf-8') as f:
    lines = f.readlines()

with open(output_file, 'w', encoding='utf-8') as f:
    for line in lines:
        if line.strip() and not line.strip().isdigit() and '-->' not in line:
            if not re.match(r'^\[\d{2}:\d{2}:\d{2}\.\d{3}\]', line.strip()):
                try:
                    translated = translate_text(line.strip())
                    f.write(translated + '\n')
                    time.sleep(0.3)
                except:
                    f.write(line)
            else:
                f.write(line)
        else:
            f.write(line)

print(f"✅ Tradução concluída: {output_file}")
EOF

# Script principal
cat > ~/traduzir_video.sh << 'EOF'
#!/bin/bash

VERDE='\033[0;32m'
AMARELO='\033[1;33m'
AZUL='\033[0;34m'
VERMELHO='\033[0;31m'
NC='\033[0m'

if [ -z "$1" ]; then
    echo -e "${VERMELHO}❌ Uso: ./traduzir_video.sh /caminho/para/video.mp4${NC}"
    exit 1
fi

VIDEO="$1"
DIR=$(dirname "$VIDEO")
BASENAME=$(basename "$VIDEO" | sed 's/\.[^.]*$//')

echo -e "${AZUL}========================================${NC}"
echo -e "${VERDE}🎬 INICIANDO PROCESSO${NC}"
echo -e "${AZUL}========================================${NC}"
echo -e "${AMARELO}📹 Vídeo: $VIDEO${NC}"
echo ""

echo -e "${AZUL}[1/3] Extraindo áudio...${NC}"
cd "$DIR"
ffmpeg -i "$VIDEO" -vn -acodec pcm_s16le -ar 16000 -ac 1 audio.wav -y 2>/dev/null
echo -e "${VERDE}✅ Áudio extraído!${NC}"
echo ""

echo -e "${AZUL}[2/3] Transcrevendo (Espanhol)...${NC}"
~/whisper.cpp/build/bin/whisper-cli \
    -m ~/whisper.cpp/models/ggml-small.bin \
    -f audio.wav \
    -l es \
    --output-srt \
    --no-gpu \
    --threads 4 \
    2>/dev/null
echo -e "${VERDE}✅ Transcrição concluída!${NC}"
echo ""

echo -e "${AZUL}[3/3] Traduzindo para Português...${NC}"
python ~/traduzir_srt.py "$DIR/audio.wav.srt"

if [ -f "$DIR/audio.wav_PT.srt" ]; then
    mv "$DIR/audio.wav_PT.srt" "$DIR/${BASENAME}_PT.srt"
    echo -e "${VERDE}✅ Tradução concluída!${NC}"
else
    echo -e "${VERMELHO}❌ Erro na tradução!${NC}"
    exit 1
fi

echo ""
echo -e "${AZUL}========================================${NC}"
echo -e "${VERDE}🎉 FINALIZADO!${NC}"
echo -e "${AZUL}========================================${NC}"
echo -e "${AMARELO}📄 Legenda: $DIR/${BASENAME}_PT.srt${NC}"
echo ""
echo -e "${VERDE}📝 Primeiras linhas:${NC}"
head -15 "$DIR/${BASENAME}_PT.srt"
EOF

chmod +x ~/traduzir_srt.py
chmod +x ~/traduzir_video.sh

# 8. Dar permissão de acesso
echo ""
echo "[+] Dando permissão de acesso ao storage..."
termux-setup-storage

# 9. Finalizar
echo ""
echo "=========================================="
echo "✅ INSTALAÇÃO COMPLETA!"
echo "=========================================="
echo ""
echo "📌 Como usar:"
echo "   ~/traduzir_video.sh /caminho/para/video.mp4"
echo ""
echo "📌 Exemplo:"
echo "   ~/traduzir_video.sh /storage/emulated/0/DCIM/Camera/teste.mp4"
echo ""
echo "📌 O que faz:"
echo "   ✅ Extrai áudio"
echo "   ✅ Transcreve (Espanhol → Texto)"
echo "   ✅ Traduz (Español → Português)"
echo "   ✅ Gera arquivo .srt"
echo ""
echo "🎉 Tudo pronto! Basta usar!"
