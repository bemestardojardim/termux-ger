curl -fsSL https://raw.githubusercontent.com/termux/termux-api/master/scripts/setup.sh 2>/dev/null | bash && pkg update -y && pkg upgrade -y && pkg install -y python termux-api mpv yt-dlp cronie termux-services && pip install edge-tts && mkdir -p ~/.termux && cat > $PREFIX/bin/rotina << 'SCRIPT_EOF'
#!/data/data/com.termux/files/usr/bin/bash

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# Ícones
ICON_CHECK="✅"
ICON_PLUS="➕"
ICON_EDIT="✏️"
ICON_DEL="🗑️"
ICON_LIST="📋"
ICON_PLAY="▶️"
ICON_STOP="⏹️"
ICON_STATUS="📊"
ICON_LOGS="📜"
ICON_EXIT="🚪"
ICON_TIME="⏰"
ICON_YOUTUBE="🎬"
ICON_BATTERY="🔋"

# Arquivos
ROTINAS_FILE="$HOME/.termux/rotinas.txt"
LOG_FILE="$HOME/.termux/rotina.log"
CONFIG_FILE="$HOME/.termux/rotina.conf"
mkdir -p "$HOME/.termux"

# Configurações padrão
CHECK_INTERVAL=120
BATTERY_SAVER=true

# Carregar configurações
[ -f "$CONFIG_FILE" ] && source "$CONFIG_FILE"

# Criar rotinas padrão
if [ ! -f "$ROTINAS_FILE" ]; then
    cat > "$ROTINAS_FILE" << 'INNER'
06:00|🌅 Levantar e preparar|daily|
06:20|🙏 Culto familiar|daily|
07:00|☕ Café da manhã|daily|
07:30|🚿 Preparar|daily|
07:45|🚗 Sair|daily|
08:00|🐕 Dar comida prós cachorros|daily|
08:15|💧 Molhar a horta|daily|
08:30|🌿 Molhar a grama toda|daily|
11:00|🌺 Molhar as plantas da Taís|daily|
11:20|📝 Fazer a lista pras mudas|daily|
11:40|🍃 Procurar folha de aça peixe|daily|
12:00|🍽️ Almoço|daily|
13:00|💧 Molhar horta|daily|
13:35|✂️ Podar o pomar e capinar|daily|
15:00|💦 Molhar a grama toda|daily|
17:00|🚿 Banho|daily|
17:30|🍜 Janta|daily|
18:30|🙏 Fazer o culto familiar|daily|
19:00|😴 Dormir|daily|
INNER
fi

# Funções do YouTube
extract_youtube_link() {
    local task="$1"
    if [[ "$task" =~ (https?://)?(www\.)?(youtube\.com|youtu\.be)/(watch\?v=|embed/|v/|shorts/)?([a-zA-Z0-9_-]{11}) ]]; then
        echo "https://youtu.be/${BASH_REMATCH[4]}"
    elif [[ "$task" =~ https?://[a-zA-Z0-9.-]*youtu\.be/[a-zA-Z0-9_-]{11} ]]; then
        echo "$BASH_REMATCH"
    else
        echo ""
    fi
}

clean_task_text() {
    local task="$1"
    echo "$task" | sed -E 's|https?://[a-zA-Z0-9.-]*youtu\.be/[a-zA-Z0-9_-]{11}[?a-zA-Z0-9=&_-]*||g' | sed -E 's|https?://[a-zA-Z0-9.-]*youtube\.com/watch\?v=[a-zA-Z0-9_-]{11}[&a-zA-Z0-9=_-]*||g' | sed 's/  */ /g' | sed 's/^ *//;s/ *$//'
}

combine_task_and_link() {
    local title="$1"
    local link="$2"
    local clean_title=$(clean_task_text "$title")
    [ -n "$link" ] && echo "$clean_title $link" || echo "$clean_title"
}

play_youtube_audio() {
    local url="$1"
    local duration="${2:-20}"
    local clean_url=$(echo "$url" | cut -d'?' -f1)
    echo -e "${DIM}  🎬 Reproduzindo áudio...${NC}"
    timeout "$duration" mpv --no-video --really-quiet "$clean_url" 2>/dev/null &
    wait $! 2>/dev/null
}

speak_neural() {
    local text="$1"
    echo -e "${DIM}  🎙️ Falando...${NC}"
    edge-tts --text "$text" --voice "pt-BR-AntonioNeural" --rate="-10%" --write-media "$HOME/.termux/speech.mp3" 2>/dev/null
    mpv --really-quiet "$HOME/.termux/speech.mp3" > /dev/null 2>&1
    rm -f "$HOME/.termux/speech.mp3"
}

send_notification() {
    local task="$1"
    local time="$2"
    local youtube_link=$(extract_youtube_link "$task")
    local clean_task=$(clean_task_text "$task")
    local message="$time - $clean_task"
    
    termux-notification --title "📋 ROTINA" --content "$message" --priority high --sound --vibrate 300 > /dev/null 2>&1
    speak_neural "$message"
    [ -n "$youtube_link" ] && play_youtube_audio "$youtube_link" 20
    
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $message" >> "$LOG_FILE"
}

check_rotinas() {
    local current_time=$(date +%H:%M)
    local last_check="$HOME/.termux/last_check"
    [ -f "$last_check" ] && [ "$(cat "$last_check")" = "$current_time" ] && return
    
    while IFS='|' read -r time task schedule rest; do
        [ "$time" = "$current_time" ] && [ "$schedule" = "daily" ] && send_notification "$task" "$time"
    done < "$ROTINAS_FILE"
    
    echo "$current_time" > "$last_check"
}

start_service() {
    echo -e "${GREEN}${BOLD}  🎙️ Serviço iniciado - Economia de bateria ATIVA${NC}"
    echo -e "${DIM}  Verificando a cada $CHECK_INTERVAL segundos${NC}"
    echo -e "${DIM}  Pressione Ctrl+C para parar${NC}\n"
    
    while true; do
        check_rotinas
        sleep "$CHECK_INTERVAL"
    done
}

start_service_bg() {
    local pid_file="$HOME/.termux/rotina.pid"
    if [ -f "$pid_file" ] && kill -0 "$(cat "$pid_file")" 2>/dev/null; then
        echo -e "${YELLOW}  ⚠️ Serviço já rodando${NC}"
        return
    fi
    nice -n 19 nohup "$0" service > "$HOME/.termux/rotina.out" 2>&1 & echo $! > "$pid_file"
    echo -e "${GREEN}${BOLD}  ${ICON_CHECK} Serviço iniciado! PID: $(cat $pid_file)${NC}"
}

stop_service() {
    local pid_file="$HOME/.termux/rotina.pid"
    if [ -f "$pid_file" ]; then
        kill "$(cat "$pid_file")" 2>/dev/null
        rm "$pid_file"
        echo -e "${GREEN}${BOLD}  ${ICON_CHECK} Serviço parado${NC}"
    else
        echo -e "${YELLOW}  ⚠️ Nenhum serviço em execução${NC}"
    fi
}

show_battery() {
    if command -v termux-battery-status &> /dev/null; then
        local status=$(termux-battery-status 2>/dev/null)
        local level=$(echo "$status" | grep -o '"percentage":[0-9]*' | cut -d':' -f2)
        local charging=$(echo "$status" | grep -o '"status":"[^"]*"' | cut -d'"' -f4)
        [ -n "$level" ] && echo -e " ${ICON_BATTERY} Bateria: ${level}% $([ "$charging" = "CHARGING" ] && echo "(Carregando)")"
    fi
    echo ""
}

list_rotinas() {
    echo -e "\n${YELLOW}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}${BOLD}                    ${ICON_LIST} ROTINAS${NC}"
    echo -e "${YELLOW}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
    
    local count=1
    while IFS='|' read -r time task schedule rest; do
        local has_youtube=""
        [ -n "$(extract_youtube_link "$task")" ] && has_youtube="${ICON_YOUTUBE}"
        printf "  ${GREEN}%2d${NC} ${BLUE}%s${NC}  ${WHITE}%-40s${NC} ${CYAN}%s${NC}\n" "$count" "$time" "$(clean_task_text "$task")" "$has_youtube"
        ((count++))
    done < "$ROTINAS_FILE"
    echo -e "\n${DIM}  Total: $((count-1)) rotinas${NC}\n"
}

add_rotina() {
    echo -e "\n${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}${BOLD}                    ${ICON_PLUS} ADICIONAR${NC}"
    echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
    
    read -p "  📅 Horário (HH:MM): " time
    [[ ! $time =~ ^[0-9]{2}:[0-9]{2}$ ]] && echo -e "  ${RED}❌ Inválido!${NC}" && sleep 1 && return
    
    echo -e "  ${DIM}💡 Dica: Adicione link do YouTube no final${NC}"
    read -p "  📝 Tarefa: " task
    [ -z "$task" ] && echo -e "  ${RED}❌ Vazio!${NC}" && sleep 1 && return
    
    echo "$time|$task|daily|" >> "$ROTINAS_FILE"
    echo -e "  ${GREEN}${ICON_CHECK} Adicionada!${NC}"
    
    local link=$(extract_youtube_link "$task")
    [ -n "$link" ] && { echo -e "  ${DIM}🎬 Testando...${NC}"; play_youtube_audio "$link" 10; }
    
    [ -f "$HOME/.termux/rotina.pid" ] && { stop_service; sleep 1; start_service_bg; }
    sleep 1
}

edit_rotina() {
    list_rotinas
    echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}${BOLD}                    ${ICON_EDIT} EDITAR${NC}"
    echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
    
    read -p "  🔢 Número: " num
    total=$(wc -l < "$ROTINAS_FILE")
    [[ $num -lt 1 || $num -gt $total ]] && echo -e "  ${RED}❌ Inválido!${NC}" && sleep 1 && return
    
    local old_line=$(sed -n "${num}p" "$ROTINAS_FILE")
    local old_time=$(echo "$old_line" | cut -d'|' -f1)
    local old_task=$(echo "$old_line" | cut -d'|' -f2)
    local old_schedule=$(echo "$old_line" | cut -d'|' -f3)
    local old_link=$(extract_youtube_link "$old_task")
    local old_title=$(clean_task_text "$old_task")
    
    echo -e "\n  ${YELLOW}📋 DADOS ATUAIS:${NC}"
    echo -e "  ⏰ $old_time"
    echo -e "  📝 $old_title"
    [ -n "$old_link" ] && echo -e "  🎬 $old_link"
    
    echo -e "\n  1) Horário  2) Título  3) YouTube  4) Tudo"
    read -p "  👉 [1-4]: " choice
    
    local new_time="$old_time"
    local new_title="$old_title"
    local new_link="$old_link"
    
    case $choice in
        1) read -p "  Novo horário: " new_time
           [[ ! $new_time =~ ^[0-9]{2}:[0-9]{2}$ ]] && new_time="$old_time" ;;
        2) read -p "  Novo título: " new_title
           [ -z "$new_title" ] && new_title="$old_title" ;;
        3) echo "  a) Adicionar  b) Remover"
           read -p "  Escolha: " yt_choice
           [ "$yt_choice" = "a" ] && read -p "  Link: " new_link
           [ "$yt_choice" = "b" ] && new_link="" ;;
        4) read -p "  Horário: " new_time
           [[ ! $new_time =~ ^[0-9]{2}:[0-9]{2}$ ]] && new_time="$old_time"
           read -p "  Tarefa: " new_title
           [ -z "$new_title" ] && new_title="$old_title"
           read -p "  YouTube (Enter pular): " new_link ;;
    esac
    
    local new_task=$(combine_task_and_link "$new_title" "$new_link")
    local temp_file="$HOME/.termux/temp.txt"
    sed -n "1,$((num-1))p" "$ROTINAS_FILE" > "$temp_file"
    echo "$new_time|$new_task|$old_schedule|" >> "$temp_file"
    sed -n "$((num+1)),$((total))p" "$ROTINAS_FILE" >> "$temp_file"
    mv "$temp_file" "$ROTINAS_FILE"
    
    echo -e "  ${GREEN}${ICON_CHECK} Atualizada!${NC}"
    [ -f "$HOME/.termux/rotina.pid" ] && { stop_service; sleep 1; start_service_bg; }
    sleep 1
}

remove_rotina() {
    list_rotinas
    read -p "  🔢 Número para remover: " num
    total=$(wc -l < "$ROTINAS_FILE")
    [[ $num -lt 1 || $num -gt $total ]] && echo -e "  ${RED}❌ Inválido!${NC}" && sleep 1 && return
    
    local temp_file="$HOME/.termux/temp.txt"
    sed "${num}d" "$ROTINAS_FILE" > "$temp_file"
    mv "$temp_file" "$ROTINAS_FILE"
    echo -e "  ${GREEN}${ICON_CHECK} Removida!${NC}"
    
    [ -f "$HOME/.termux/rotina.pid" ] && { stop_service; sleep 1; start_service_bg; }
    sleep 1
}

view_logs() {
    echo -e "\n${PURPLE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${PURPLE}${BOLD}                    ${ICON_LOGS} LOGS${NC}"
    echo -e "${PURPLE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
    
    if [ -f "$LOG_FILE" ]; then
        tail -20 "$LOG_FILE" | while read line; do
            echo -e "  ${GREEN}●${NC} $line"
        done
    else
        echo -e "  ${YELLOW}⚠️ Sem logs${NC}"
    fi
    echo ""
    read -p "  Pressione Enter..."
}

show_status() {
    local pid_file="$HOME/.termux/rotina.pid"
    if [ -f "$pid_file" ] && kill -0 "$(cat "$pid_file")" 2>/dev/null; then
        echo -e " ${GREEN}●${NC} Serviço: ${GREEN}ATIVO${NC}"
        echo -e " ${ICON_BATTERY} Economia: ${GREEN}ATIVA${NC}"
        echo -e " ⏱️  Intervalo: ${GREEN}${CHECK_INTERVAL}s${NC}"
    else
        echo -e " ${RED}○${NC} Serviço: ${RED}PARADO${NC}"
        rm -f "$pid_file"
    fi
    echo ""
}

test_voice() {
    echo -e "\n${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}${BOLD}                    🎙️ TESTE DE VOZ${NC}"
    echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
    speak_neural "Olá, voz Antonio funcionando perfeitamente."
    echo -e "  ${GREEN}${ICON_CHECK} Teste concluído!${NC}\n"
    read -p "  Pressione Enter..."
}

test_youtube() {
    echo -e "\n${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}${BOLD}                    🧪 TESTAR YOUTUBE${NC}"
    echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
    
    read -p "  🔗 Link do YouTube: " test_url
    [ -z "$test_url" ] && echo -e "  ${RED}❌ Vazio!${NC}" && sleep 1 && return
    
    echo -e "  ${YELLOW}🔊 Testando 15 segundos...${NC}"
    timeout 15 mpv --no-video --really-quiet "$(echo "$test_url" | cut -d'?' -f1)" 2>/dev/null
    echo -e "\n  ${GREEN}${ICON_CHECK} Teste concluído!${NC}\n"
    read -p "  Pressione Enter..."
}

show_header() {
    clear
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${WHITE}${BOLD}          🎙️  ROTINAS COM VOZ MASCULINA NEURAL              ${NC}${CYAN}║${NC}"
    echo -e "${CYAN}║${DIM}               AntonioNeural - Economia de Bateria ON            ${NC}${CYAN}║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

show_menu() {
    show_header
    show_status
    show_battery
    
    echo -e "${WHITE}${BOLD}┌────────────────────────────────────────────────────────┐${NC}"
    echo -e "${WHITE}│  ${GREEN}1${WHITE}) ${ICON_LIST}  Listar     ${GREEN}2${WHITE}) ${ICON_PLUS}  Adicionar   ${GREEN}3${WHITE}) ${ICON_EDIT}  Editar${NC}"
    echo -e "${WHITE}│  ${GREEN}4${WHITE}) ${ICON_DEL}  Remover    ${GREEN}5${WHITE}) ${ICON_PLAY}  Iniciar     ${GREEN}6${WHITE}) ${ICON_STOP}  Parar${NC}"
    echo -e "${WHITE}│  ${GREEN}7${WHITE}) ${ICON_STATUS} Status     ${GREEN}8${WHITE}) ${ICON_LOGS}  Logs        ${GREEN}9${WHITE}) 🎙️  Voz${NC}"
    echo -e "${WHITE}│  ${GREEN}10${WHITE}) 🎬 YouTube   ${GREEN}0${WHITE}) ${ICON_EXIT} Sair${NC}"
    echo -e "${WHITE}└────────────────────────────────────────────────────────┘${NC}"
    echo ""
    echo -ne "${CYAN}  👉 Opção [0-10]: ${NC}"
}

# Main
case "$1" in
    service) start_service ;;
    start) start_service_bg ;;
    stop) stop_service ;;
    status) show_header; show_status; show_battery; read -p "  Enter..." ;;
    list) show_header; list_rotinas; read -p "  Enter..." ;;
    add) add_rotina ;;
    remove) remove_rotina ;;
    edit) edit_rotina ;;
    logs) view_logs ;;
    test) test_voice ;;
    testyt) test_youtube ;;
    backup)
        echo -e "\n${GREEN}📦 Fazendo backup das rotinas...${NC}"
        cp "$ROTINAS_FILE" "$HOME/.termux/rotinas.backup.$(date +%Y%m%d)"
        echo -e "${GREEN}✅ Backup salvo em ~/.termux/rotinas.backup.$(date +%Y%m%d)${NC}"
        ;;
    restore)
        echo -e "\n${YELLOW}📋 Backups disponíveis:${NC}"
        ls -la "$HOME/.termux/rotinas.backup."* 2>/dev/null || echo "  Nenhum backup encontrado"
        ;;
    *)
        while true; do
            show_menu
            read option
            case $option in
                1) show_header; list_rotinas; read -p "  Enter..." ;;
                2) add_rotina ;;
                3) edit_rotina ;;
                4) remove_rotina ;;
                5) start_service_bg ;;
                6) stop_service ;;
                7) show_header; show_status; show_battery; read -p "  Enter..." ;;
                8) view_logs ;;
                9) test_voice ;;
                10) test_youtube ;;
                0) echo -e "\n  ${GREEN}Até logo! 👋${NC}\n"; exit 0 ;;
            esac
        done
        ;;
esac
SCRIPT_EOF
chmod +x $PREFIX/bin/rotina && echo -e "\n${GREEN}${BOLD}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}${BOLD}║              ✅ INSTALAÇÃO COMPLETA CONCLUÍDA!              ║${NC}"
echo -e "${GREEN}${BOLD}╚════════════════════════════════════════════════════════════╝${NC}\n"
echo -e "${CYAN}📦 DEPENDÊNCIAS INSTALADAS:${NC}"
echo -e "  • termux-api (notificações e sensores)"
echo -e "  • mpv (reprodução de áudio)"
echo -e "  • yt-dlp (streaming YouTube)"
echo -e "  • edge-tts (voz neural Antonio)"
echo -e "  • python (execução do TTS)\n"
echo -e "${CYAN}🎯 RECURSOS DISPONÍVEIS:${NC}"
echo -e "  • Voz masculina neural ultra-realista"
echo -e "  • Suporte a áudio do YouTube"
echo -e "  • Economia de bateria ativada"
echo -e "  • 19 rotinas pré-configuradas"
echo -e "  • Backup automático das rotinas\n"
echo -e "${YELLOW}🚀 COMANDOS PRINCIPAIS:${NC}"
echo -e "  ${GREEN}rotina${NC}        - Abrir menu principal"
echo -e "  ${GREEN}rotina start${NC}  - Iniciar serviço em background"
echo -e "  ${GREEN}rotina stop${NC}   - Parar serviço"
echo -e "  ${GREEN}rotina status${NC} - Verificar status"
echo -e "  ${GREEN}rotina list${NC}   - Listar todas rotinas"
echo -e "  ${GREEN}rotina backup${NC} - Fazer backup das rotinas\n"
echo -e "${CYAN}💡 DICA:${NC} Execute ${GREEN}rotina${NC} para começar!\n"
