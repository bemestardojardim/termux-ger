#!/bin/bash

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# Ícones
ICON_SCRIPT="📜"
ICON_INSTALL="🚀"
ICON_FOLDER="📁"
ICON_CHECK="✅"
ICON_GITHUB="🐙"
ICON_DOWNLOAD="⬇️"

# URL do repositório
REPO_URL="https://github.com/bemestardojardim/termux-ger"
RAW_URL="https://raw.githubusercontent.com/bemestardojardim/termux-ger/main"

# Função para obter descrição do script
get_description() {
    local script="$1"
    case "$script" in
        "install_bot.sh")
            echo "🤖 Bot de Áudio YouTube para Telegram - Baixa e reproduz áudio do YouTube"
            ;;
        "instalar_android_env.sh")
            echo "📱 Ambiente Android + App Ponto Eletrônico - Configura desenvolvimento Android"
            ;;
        "instalar_voz.sh")
            echo "🎙️ Leitor de voz com Edge-TTS - Voz neural para Termux"
            ;;
        "rotina.sh")
            echo "⏰ Sistema de rotinas com voz masculina neural e suporte a YouTube"
            ;;
        "listar_scripts.sh")
            echo "📋 Lista todos os scripts disponíveis no repositório"
            ;;
        *)
            echo "📝 Script sem descrição específica"
            ;;
    esac
}

# Função para obter tamanho do arquivo
get_file_size() {
    local script="$1"
    if [ -f "$script" ]; then
        ls -lh "$script" | awk '{print $5}'
    else
        echo "?"
    fi
}

# Cabeçalho
clear
echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${WHITE}${BOLD}          ${ICON_GITHUB} SCRIPTS DISPONÍVEIS - TERMUX GER ${ICON_GITHUB}               ${NC}${CYAN}║${NC}"
echo -e "${CYAN}║${DIM}                    Bem Estar do Jardim                          ${NC}${CYAN}║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Listar scripts
echo -e "${YELLOW}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}${BOLD}           ${ICON_SCRIPT} SCRIPTS NO REPOSITÓRIO ${ICON_SCRIPT}${NC}"
echo -e "${YELLOW}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

count=1
total=$(ls -1 *.sh 2>/dev/null | wc -l)

for script in $(ls -1 *.sh 2>/dev/null | sort); do
    size=$(get_file_size "$script")
    description=$(get_description "$script")
    
    echo -e "${GREEN}${BOLD}[$count]${NC} ${CYAN}${BOLD}$script${NC} ${DIM}($size)${NC}"
    echo -e "    ${DIM}└─${NC} $description"
    echo -e "    ${BLUE}${ICON_INSTALL}${NC} ${DIM}Instalar:${NC} ${GREEN}bash $script${NC}"
    echo ""
    ((count++))
done

if [ $total -eq 0 ]; then
    echo -e "  ${YELLOW}⚠️ Nenhum script encontrado no diretório atual${NC}"
    echo -e "  ${DIM}Certifique-se de estar em: ~/termux-ger${NC}\n"
fi

# Estatísticas
echo -e "${YELLOW}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}📊 TOTAL: ${GREEN}${BOLD}$total${NC} ${CYAN}script(s) disponível(is)${NC}"
echo -e "${YELLOW}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

# Menu interativo
echo -e "${WHITE}${BOLD}┌────────────────────────────────────────────────────────────┐${NC}"
echo -e "${WHITE}│  ${GREEN}1${WHITE}) Instalar script específico                               │${NC}"
echo -e "${WHITE}│  ${GREEN}2${WHITE}) Instalar TODOS os scripts                               │${NC}"
echo -e "${WHITE}│  ${GREEN}3${WHITE}) Abrir repositório no GitHub                            │${NC}"
echo -e "${WHITE}│  ${GREEN}0${WHITE}) Sair                                                   │${NC}"
echo -e "${WHITE}└────────────────────────────────────────────────────────────┘${NC}"
echo ""

read -p "$(echo -e ${CYAN}"👉 Escolha uma opção [0-3]: "${NC})" option

case $option in
    1)
        echo ""
        read -p "$(echo -e ${CYAN}"📝 Nome do script (ex: rotina.sh): "${NC})" script_name
        if [ -f "$script_name" ]; then
            echo -e "\n${GREEN}${ICON_CHECK} Executando: bash $script_name${NC}\n"
            sleep 1
            bash "$script_name"
        else
            echo -e "\n${RED}❌ Script '$script_name' não encontrado!${NC}\n"
        fi
        ;;
    2)
        echo -e "\n${YELLOW}⚠️ Atenção: Isso instalará TODOS os scripts!${NC}"
        read -p "$(echo -e ${CYAN}"Confirmar? (s/N): "${NC})" confirm
        if [[ "$confirm" =~ ^[Ss]$ ]]; then
            echo -e "\n${GREEN}${ICON_INSTALL} Instalando todos os scripts...${NC}\n"
            for script in $(ls -1 *.sh 2>/dev/null | sort); do
                echo -e "${CYAN}▶ Instalando: $script${NC}"
                bash "$script"
                echo -e "${GREEN}✅ $script instalado!${NC}\n"
                sleep 1
            done
            echo -e "${GREEN}${BOLD}${ICON_CHECK} Todos os scripts foram instalados!${NC}\n"
        else
            echo -e "\n${YELLOW}❌ Instalação cancelada.${NC}\n"
        fi
        ;;
    3)
        echo -e "\n${GREEN}${ICON_GITHUB} Abrindo repositório no navegador...${NC}"
        termux-open "$REPO_URL" 2>/dev/null || echo -e "${YELLOW}⚠️ Comando termux-open não disponível. Acesse: $REPO_URL${NC}\n"
        ;;
    0)
        echo -e "\n${GREEN}Até logo! 👋${NC}\n"
        exit 0
        ;;
    *)
        echo -e "\n${RED}❌ Opção inválida!${NC}\n"
        ;;
esac
