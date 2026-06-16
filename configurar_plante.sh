#!/bin/bash
pkg update -y && pkg upgrade -y && pkg install -y git gh nano curl wget && git config --global user.name "planteoficial" && git config --global user.email "projetoplanteoficial@gmail.com" && echo "alias plante='bash ~/painel-plante.sh'" >> ~/.bashrc && echo "alias c='clear'" >> ~/.bashrc && echo "alias ll='ls -la'" >> ~/.bashrc && echo "alias gs='git status'" >> ~/.bashrc && echo "alias ga='git add .'" >> ~/.bashrc && echo "alias gc='git commit -m'" >> ~/.bashrc && echo "alias gp='git push'" >> ~/.bashrc && source ~/.bashrc && mkdir -p ~/storage/downloads/meusite && cd ~/storage/downloads/meusite && git clone https://github.com/planteoficial/Plante.git . || echo "Repositório já existe" && cat > ~/painel-plante.sh << 'FIMPAINEL'
#!/bin/bash
VERDE='\033[0;32m'; AMARELO='\033[1;33m'; AZUL='\033[0;34m'; RESET='\033[0m'; BRANCO='\033[1;37m'
REPO_DIR="$HOME/storage/downloads/meusite"
echo -e "${VERDE}🌱 Painel Plante${RESET}"
echo -e "${AZUL}1) Abrir site${RESET}"
echo -e "${AZUL}2) git status${RESET}"
echo -e "${AZUL}3) git add . && git commit${RESET}"
echo -e "${AZUL}4) git push${RESET}"
echo -e "${AZUL}5) Abrir código (nano)${RESET}"
read -p "Opção: " opt
case $opt in
  1) am start -a android.intent.action.VIEW -d https://planteoficial.github.io/Plante/ ;;
  2) cd $REPO_DIR && git status ;;
  3) cd $REPO_DIR && git add . && read -p "Mensagem: " msg && git commit -m "$msg" ;;
  4) cd $REPO_DIR && git push ;;
  5) cd $REPO_DIR && nano index.html ;;
  *) echo "Inválido";;
esac
FIMPAINEL
chmod +x ~/painel-plante.sh && gh auth login
