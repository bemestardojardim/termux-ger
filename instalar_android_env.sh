#!/bin/bash

echo "========================================"
echo "🚀 INSTALANDO AMBIENTE ANDROID COMPLETO"
echo "========================================"
echo ""

# 1. Atualizar pacotes
echo "📦 Atualizando pacotes..."
pkg update -y && pkg upgrade -y

# 2. Instalar dependências essenciais
echo "📦 Instalando Java e ferramentas..."
pkg install openjdk-17 wget unzip zip git nano -y

# 3. Instalar aapt2 (essencial para compilar)
echo "📦 Instalando aapt2..."
pkg install aapt aapt2 -y

# 4. Dar permissão de armazenamento
echo "📁 Dando permissão de armazenamento..."
termux-setup-storage
sleep 3

# 5. Criar estrutura do Android SDK
echo "📱 Instalando Android SDK..."
mkdir -p $HOME/android-sdk
cd $HOME/android-sdk

# 6. Baixar command-line tools
echo "📥 Baixando command-line tools..."
wget --no-check-certificate https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O cmdline-tools.zip
unzip -o cmdline-tools.zip
mkdir -p cmdline-tools/latest
mv cmdline-tools/* cmdline-tools/latest/ 2>/dev/null || true
rm cmdline-tools.zip

# 7. Baixar Gradle
echo "📥 Baixando Gradle..."
cd $HOME
wget --no-check-certificate https://services.gradle.org/distributions/gradle-8.5-bin.zip
unzip -o gradle-8.5-bin.zip -d $HOME/.gradle
rm gradle-8.5-bin.zip

# 8. Configurar variáveis de ambiente
echo "⚙️ Configurando variáveis de ambiente..."
cat >> ~/.bashrc << 'EOF'

# Android SDK
export ANDROID_HOME=$HOME/android-sdk
export PATH=$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH

# Gradle
export PATH=$HOME/.gradle/gradle-8.5/bin:$PATH

# Java
export JAVA_HOME=$PREFIX/lib/jvm/java-17-openjdk

# Gradle options (evita erro de memória)
export GRADLE_OPTS="-Xmx512m"
EOF

source ~/.bashrc

# 9. Configurar aapt2 override (CRÍTICO para evitar erro)
echo "⚙️ Configurando aapt2 override..."
mkdir -p $HOME/.gradle
cat > $HOME/.gradle/gradle.properties << 'EOF'
android.aapt2FromMavenOverride=/data/data/com.termux/files/usr/bin/aapt2
org.gradle.jvmargs=-Xmx512m
EOF

# 10. Aceitar licenças do SDK
echo "📜 Aceitando licenças..."
mkdir -p $ANDROID_HOME/licenses
cat > $ANDROID_HOME/licenses/android-sdk-license << 'EOF'
8933bad161af4178b1185d1a37fbf41ea5269c55
EOF

# Também aceitar a licença do build-tools
cat > $ANDROID_HOME/licenses/android-sdk-preview-license << 'EOF'
8933bad161af4178b1185d1a37fbf41ea5269c55
EOF

# 11. Instalar plataformas Android
echo "📱 Instalando plataformas Android (pode demorar um pouco)..."
yes | sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0" > /dev/null 2>&1

# 12. Criar link simbólico para o aapt2 (garantia extra)
echo "🔗 Configurando links do sistema..."
ln -sf /data/data/com.termux/files/usr/bin/aapt2 $ANDROID_HOME/build-tools/34.0.0/aapt2 2>/dev/null || true

echo ""
echo "========================================"
echo "✅ AMBIENTE CONFIGURADO COM SUCESSO!"
echo "========================================"
echo ""
echo "📋 O que foi instalado:"
echo "   • Java 17 (OpenJDK)"
echo "   • Android SDK (platforms 34)"
echo "   • Build Tools 34.0.0"
echo "   • Gradle 8.5"
echo "   • aapt2 configurado"
echo ""
echo "💡 Agora você pode:"
echo "   • Criar projetos Android"
echo "   • Compilar APKs"
echo "   • Usar 'gradle assembleDebug'"
echo ""
echo "⚠️  IMPORTANTE: Feche e reabra o Termux ou execute:"
echo "   source ~/.bashrc"
echo ""
echo "========================================"
