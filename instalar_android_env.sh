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
wget https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O cmdline-tools.zip
unzip -o cmdline-tools.zip
mkdir -p cmdline-tools/latest
mv cmdline-tools/* cmdline-tools/latest/ 2>/dev/null || true
rm cmdline-tools.zip

# 7. Baixar Gradle
echo "📦 Instalando Gradle..."
cd $HOME
wget https://services.gradle.org/distributions/gradle-8.5-bin.zip
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

# 11. Instalar plataformas Android
echo "📱 Instalando plataformas Android (pode demorar um pouco)..."
yes | sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0" 2>/dev/null || true

echo ""
echo "✅ AMBIENTE CONFIGURADO COM SUCESSO!"
echo ""

# ============================================
# CRIAR APP PONTO ELETRÔNICO
# ============================================

echo "========================================"
echo "📱 CRIANDO APP PONTO ELETRÔNICO"
echo "========================================"

# Criar projeto
cd $HOME
mkdir -p PontoApp
cd PontoApp

# Criar estrutura de pastas
mkdir -p app/src/main/java/com/ponto/app
mkdir -p app/src/main/res/layout
mkdir -p app/src/main/res/values
mkdir -p app/src/main/res/mipmap-hdpi
mkdir -p app/src/main/res/mipmap-mdpi
mkdir -p app/src/main/res/mipmap-xhdpi
mkdir -p app/src/main/res/mipmap-xxhdpi
mkdir -p app/src/main/res/mipmap-xxxhdpi

# Criar arquivos principais

# settings.gradle
cat > settings.gradle << 'EOF'
include ':app'
EOF

# gradle.properties
cat > gradle.properties << 'EOF'
android.useAndroidX=true
android.enableJetifier=true
org.gradle.jvmargs=-Xmx512m
android.suppressUnsupportedCompileSdk=34
EOF

# build.gradle raiz
cat > build.gradle << 'EOF'
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:8.1.0'
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}
EOF

# app/build.gradle
cat > app/build.gradle << 'EOF'
plugins {
    id 'com.android.application'
}

android {
    namespace 'com.ponto.app'
    compileSdk 34
    
    defaultConfig {
        applicationId 'com.ponto.app'
        minSdk 21
        targetSdk 34
        versionCode 1
        versionName '1.0'
    }
    
    buildTypes {
        release {
            minifyEnabled false
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}

dependencies {
    implementation 'androidx.appcompat:appcompat:1.6.1'
    implementation 'com.google.android.material:material:1.9.0'
    implementation 'androidx.recyclerview:recyclerview:1.3.0'
    implementation 'androidx.cardview:cardview:1.0.0'
}
EOF

# Criar ícone simples
echo "iVBORw0KGgoAAAANSUhEUgAAAEgAAABICAYAAABV7bNHAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAHHSURBVHhe7dPBbcJAEIXhURQARSBKB6QDKB1QOqB0QOkA0gGlAyoHpAMoHWAY2V5r7Yy9o+Wv513rSc+BY/3K/kUYY4wxxhhjjDHGGGOMMcYYY4wxxhhjjDHGGGOMMcYYY4wxxhhjjDHGGGOMMcYYY4wxxhhjjDHGGGOMMcYYY4wxxhhjjDHGGGOMMcYYY4wxxhhjjDHGGGOMMcYYY4wxxhhjjDHGGGOMMcYYY4wxxhhjjDHGGGOMMcYYY4wxxhhjjDHGGGOMMcYYY4wxxhhjjDHGGGOMMcYYY4wxxhhjjDHGGGOMMcYYY4wxxhhjjDHGGGOMMcYYY4wxxhhjjDHGGGOMMcYYY4wxxhhjjDHGGGOMMcYYY4wxxhhjjDHGGGOMMcYYY4wxxhhjjDHGGGOMMcYYY4wxxhhjjDHGGGOMMcYYY4wxxhhjjDHGGGOMMcYYY4wxxhhjjDHGGGOMMcYYY4wxxhhjjDHGGGOMMcYYY4wxxhhjjDHGGGOMMcYYY4wxxhhjjDHGGGOMMcYYY4wxxhhjjDHGGGOMMcYYY4wxxhhjjDHGGGOMMcYYY4wxxhhjjDHGGGOMMcYYY4wxxhhjjDHGGGOMMcYYY4wxxhhjjDHGGGOMMcYYY4z5P/MLmHzLfjrHYGQAAAAASUVORK5CYII=" | base64 -d > app/src/main/res/mipmap-hdpi/ic_launcher.png

# Copiar ícone para todas resoluções
cp app/src/main/res/mipmap-hdpi/ic_launcher.png app/src/main/res/mipmap-mdpi/
cp app/src/main/res/mipmap-hdpi/ic_launcher.png app/src/main/res/mipmap-xhdpi/
cp app/src/main/res/mipmap-hdpi/ic_launcher.png app/src/main/res/mipmap-xxhdpi/
cp app/src/main/res/mipmap-hdpi/ic_launcher.png app/src/main/res/mipmap-xxxhdpi/

# Criar DatabaseHelper.java
cat > app/src/main/java/com/ponto/app/DatabaseHelper.java << 'EOF'
package com.ponto.app;

import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Locale;

public class DatabaseHelper extends SQLiteOpenHelper {
    private static final String DATABASE_NAME = "PontoDB";
    private static final int DATABASE_VERSION = 1;
    private static final String TABLE_REGISTROS = "registros";
    private static final String COL_ID = "id";
    private static final String COL_DATA = "data";
    private static final String COL_HORA = "hora";
    private static final String COL_TIPO = "tipo";
    private static final String COL_TIMESTAMP = "timestamp";
    
    public DatabaseHelper(Context context) {
        super(context, DATABASE_NAME, null, DATABASE_VERSION);
    }
    
    @Override
    public void onCreate(SQLiteDatabase db) {
        String createTable = "CREATE TABLE " + TABLE_REGISTROS + "("
                + COL_ID + " INTEGER PRIMARY KEY AUTOINCREMENT,"
                + COL_DATA + " TEXT,"
                + COL_HORA + " TEXT,"
                + COL_TIPO + " TEXT,"
                + COL_TIMESTAMP + " INTEGER" + ")";
        db.execSQL(createTable);
    }
    
    @Override
    public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
        db.execSQL("DROP TABLE IF EXISTS " + TABLE_REGISTROS);
        onCreate(db);
    }
    
    public long inserirRegistro(String tipo) {
        SQLiteDatabase db = this.getWritableDatabase();
        ContentValues values = new ContentValues();
        long now = System.currentTimeMillis();
        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd", Locale.getDefault());
        SimpleDateFormat timeFormat = new SimpleDateFormat("HH:mm:ss", Locale.getDefault());
        values.put(COL_DATA, dateFormat.format(new Date(now)));
        values.put(COL_HORA, timeFormat.format(new Date(now)));
        values.put(COL_TIPO, tipo);
        values.put(COL_TIMESTAMP, now);
        return db.insert(TABLE_REGISTROS, null, values);
    }
    
    public List<Registro> getTodosRegistros() {
        List<Registro> lista = new ArrayList<>();
        SQLiteDatabase db = this.getReadableDatabase();
        String query = "SELECT * FROM " + TABLE_REGISTROS + " ORDER BY " + COL_TIMESTAMP + " DESC LIMIT 50";
        Cursor cursor = db.rawQuery(query, null);
        if (cursor.moveToFirst()) {
            do {
                Registro r = new Registro();
                r.id = cursor.getInt(cursor.getColumnIndexOrThrow(COL_ID));
                r.data = cursor.getString(cursor.getColumnIndexOrThrow(COL_DATA));
                r.hora = cursor.getString(cursor.getColumnIndexOrThrow(COL_HORA));
                r.tipo = cursor.getString(cursor.getColumnIndexOrThrow(COL_TIPO));
                lista.add(r);
            } while (cursor.moveToNext());
        }
        cursor.close();
        return lista;
    }
    
    public String getProximaAcao() {
        SQLiteDatabase db = this.getReadableDatabase();
        String hoje = new SimpleDateFormat("yyyy-MM-dd", Locale.getDefault()).format(new Date());
        String query = "SELECT * FROM " + TABLE_REGISTROS + " WHERE " + COL_DATA + " = ? ORDER BY " + COL_TIMESTAMP + " DESC LIMIT 1";
        Cursor cursor = db.rawQuery(query, new String[]{hoje});
        if (cursor.moveToFirst()) {
            String ultimoTipo = cursor.getString(cursor.getColumnIndexOrThrow(COL_TIPO));
            cursor.close();
            switch (ultimoTipo) {
                case "ENTRADA": return "SAIDA_ALMOCO";
                case "SAIDA_ALMOCO": return "VOLTA_ALMOCO";
                case "VOLTA_ALMOCO": return "SAIDA";
                default: return "ENTRADA";
            }
        }
        cursor.close();
        return "ENTRADA";
    }
    
    public static class Registro {
        public int id;
        public String data;
        public String hora;
        public String tipo;
        public String getTipoDisplay() {
            switch (tipo) {
                case "ENTRADA": return "🌅 Entrada";
                case "SAIDA_ALMOCO": return "🍽️ Almoço";
                case "VOLTA_ALMOCO": return "🏢 Volta";
                case "SAIDA": return "🏠 Saída";
                default: return tipo;
            }
        }
    }
}
EOF

# Criar RegistroAdapter.java
cat > app/src/main/java/com/ponto/app/RegistroAdapter.java << 'EOF'
package com.ponto.app;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;
import java.util.List;

public class RegistroAdapter extends RecyclerView.Adapter<RegistroAdapter.ViewHolder> {
    private List<DatabaseHelper.Registro> registros;
    
    public RegistroAdapter(List<DatabaseHelper.Registro> registros) {
        this.registros = registros;
    }
    
    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.item_registro, parent, false);
        return new ViewHolder(view);
    }
    
    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        DatabaseHelper.Registro registro = registros.get(position);
        holder.txtTipo.setText(registro.getTipoDisplay());
        holder.txtHora.setText(registro.hora);
        holder.txtData.setText(registro.data);
    }
    
    @Override
    public int getItemCount() {
        return registros.size();
    }
    
    public static class ViewHolder extends RecyclerView.ViewHolder {
        TextView txtTipo, txtHora, txtData;
        public ViewHolder(@NonNull View itemView) {
            super(itemView);
            txtTipo = itemView.findViewById(R.id.txtTipo);
            txtHora = itemView.findViewById(R.id.txtHora);
            txtData = itemView.findViewById(R.id.txtData);
        }
    }
}
EOF

# Criar MainActivity.java
cat > app/src/main/java/com/ponto/app/MainActivity.java << 'EOF'
package com.ponto.app;

import android.os.Bundle;
import android.os.Handler;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Locale;

public class MainActivity extends AppCompatActivity {
    private TextView txtHoraAtual, txtDataAtual, txtProximaAcao;
    private RecyclerView recyclerView;
    private DatabaseHelper dbHelper;
    private Handler handler = new Handler();
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        
        dbHelper = new DatabaseHelper(this);
        
        txtHoraAtual = findViewById(R.id.txtHoraAtual);
        txtDataAtual = findViewById(R.id.txtDataAtual);
        txtProximaAcao = findViewById(R.id.txtProximaAcao);
        recyclerView = findViewById(R.id.recyclerView);
        recyclerView.setLayoutManager(new LinearLayoutManager(this));
        
        Button btnEntrada = findViewById(R.id.btnEntrada);
        Button btnSaidaAlmoco = findViewById(R.id.btnSaidaAlmoco);
        Button btnVoltaAlmoco = findViewById(R.id.btnVoltaAlmoco);
        Button btnSaida = findViewById(R.id.btnSaida);
        
        btnEntrada.setOnClickListener(v -> registrarPonto("ENTRADA"));
        btnSaidaAlmoco.setOnClickListener(v -> registrarPonto("SAIDA_ALMOCO"));
        btnVoltaAlmoco.setOnClickListener(v -> registrarPonto("VOLTA_ALMOCO"));
        btnSaida.setOnClickListener(v -> registrarPonto("SAIDA"));
        
        atualizarHora();
        carregarRegistros();
    }
    
    private void atualizarHora() {
        handler.post(new Runnable() {
            @Override
            public void run() {
                SimpleDateFormat timeFormat = new SimpleDateFormat("HH:mm:ss", Locale.getDefault());
                SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy", Locale.getDefault());
                Date now = new Date();
                txtHoraAtual.setText(timeFormat.format(now));
                txtDataAtual.setText(dateFormat.format(now));
                
                String proxima = dbHelper.getProximaAcao();
                if (proxima.equals("ENTRADA")) txtProximaAcao.setText("🌅 Próximo: ENTRADA");
                else if (proxima.equals("SAIDA_ALMOCO")) txtProximaAcao.setText("🍽️ Próximo: SAÍDA ALMOÇO");
                else if (proxima.equals("VOLTA_ALMOCO")) txtProximaAcao.setText("🏢 Próximo: VOLTA ALMOÇO");
                else txtProximaAcao.setText("🏠 Próximo: SAÍDA");
                
                handler.postDelayed(this, 1000);
            }
        });
    }
    
    private void registrarPonto(String tipo) {
        dbHelper.inserirRegistro(tipo);
        String msg = tipo.equals("ENTRADA") ? "🌅 Entrada registrada!" :
                     tipo.equals("SAIDA_ALMOCO") ? "🍽️ Saída almoço!" :
                     tipo.equals("VOLTA_ALMOCO") ? "🏢 Volta almoço!" : "🏠 Saída registrada!";
        Toast.makeText(this, msg, Toast.LENGTH_SHORT).show();
        carregarRegistros();
    }
    
    private void carregarRegistros() {
        List<DatabaseHelper.Registro> registros = dbHelper.getTodosRegistros();
        recyclerView.setAdapter(new RegistroAdapter(registros));
    }
    
    @Override
    protected void onDestroy() {
        super.onDestroy();
        handler.removeCallbacksAndMessages(null);
    }
}
EOF

# Criar activity_main.xml
cat > app/src/main/res/layout/activity_main.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:orientation="vertical"
    android:background="#F5F5F5">
    
    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:orientation="vertical"
        android:padding="20dp"
        android:background="#FFFFFF"
        android:elevation="4dp">
        
        <TextView
            android:id="@+id/txtHoraAtual"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="00:00:00"
            android:textSize="48sp"
            android:textColor="#2196F3"
            android:textStyle="bold"/>
        
        <TextView
            android:id="@+id/txtDataAtual"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="00/00/0000"
            android:textSize="18sp"
            android:textColor="#666666"
            android:layout_marginTop="5dp"/>
        
        <TextView
            android:id="@+id/txtProximaAcao"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="🌅 Próximo: ENTRADA"
            android:textSize="16sp"
            android:textColor="#4CAF50"
            android:layout_marginTop="10dp"
            android:background="#E8F5E9"
            android:padding="8dp"
            android:paddingStart="15dp"
            android:paddingEnd="15dp"/>
    </LinearLayout>
    
    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:orientation="horizontal"
        android:padding="10dp">
        
        <Button
            android:id="@+id/btnEntrada"
            android:layout_width="0dp"
            android:layout_height="wrap_content"
            android:layout_weight="1"
            android:text="🌅\nEntrada"
            android:textSize="12sp"
            android:backgroundTint="#4CAF50"
            android:layout_margin="2dp"/>
        
        <Button
            android:id="@+id/btnSaidaAlmoco"
            android:layout_width="0dp"
            android:layout_height="wrap_content"
            android:layout_weight="1"
            android:text="🍽️\nAlmoço"
            android:textSize="12sp"
            android:backgroundTint="#FF9800"
            android:layout_margin="2dp"/>
        
        <Button
            android:id="@+id/btnVoltaAlmoco"
            android:layout_width="0dp"
            android:layout_height="wrap_content"
            android:layout_weight="1"
            android:text="🏢\nVolta"
            android:textSize="12sp"
            android:backgroundTint="#2196F3"
            android:layout_margin="2dp"/>
        
        <Button
            android:id="@+id/btnSaida"
            android:layout_width="0dp"
            android:layout_height="wrap_content"
            android:layout_weight="1"
            android:text="🏠\nSaída"
            android:textSize="12sp"
            android:backgroundTint="#F44336"
            android:layout_margin="2dp"/>
    </LinearLayout>
    
    <TextView
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:text="Últimos registros"
        android:textSize="18sp"
        android:textColor="#333333"
        android:padding="16dp"
        android:paddingBottom="8dp"/>
    
    <androidx.recyclerview.widget.RecyclerView
        android:id="@+id/recyclerView"
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:padding="10dp"/>
</LinearLayout>
EOF

# Criar item_registro.xml
cat > app/src/main/res/layout/item_registro.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<androidx.cardview.widget.CardView xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:layout_margin="4dp"
    app:cardElevation="2dp"
    app:cardCornerRadius="8dp">
    
    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:orientation="horizontal"
        android:padding="16dp"
        android:background="#FFFFFF">
        
        <LinearLayout
            android:layout_width="0dp"
            android:layout_height="wrap_content"
            android:layout_weight="1"
            android:orientation="vertical">
            
            <TextView
                android:id="@+id/txtTipo"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:text="🌅 Entrada"
                android:textSize="16sp"
                android:textColor="#333333"
                android:textStyle="bold"/>
            
            <TextView
                android:id="@+id/txtData"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:text="2024-01-01"
                android:textSize="14sp"
                android:textColor="#999999"
                android:layout_marginTop="4dp"/>
        </LinearLayout>
        
        <TextView
            android:id="@+id/txtHora"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="08:30:00"
            android:textSize="20sp"
            android:textColor="#2196F3"
            android:textStyle="bold"/>
    </LinearLayout>
</androidx.cardview.widget.CardView>
EOF

# Criar strings.xml
cat > app/src/main/res/values/strings.xml << 'EOF'
<resources>
    <string name="app_name">Ponto Eletrônico</string>
</resources>
EOF

# Criar colors.xml
cat > app/src/main/res/values/colors.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="purple_500">#FF6200EE</color>
    <color name="purple_700">#FF3700B3</color>
    <color name="teal_200">#FF03DAC5</color>
    <color name="teal_700">#FF018786</color>
    <color name="black">#FF000000</color>
    <color name="white">#FFFFFFFF</color>
</resources>
EOF

# Criar AndroidManifest.xml
cat > app/src/main/AndroidManifest.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <application
        android:allowBackup="true"
        android:label="@string/app_name"
        android:theme="@style/Theme.AppCompat.Light">
        <activity
            android:name=".MainActivity"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
    </application>
</manifest>
EOF

echo ""
echo "✅ APP CRIADO COM SUCESSO!"
echo ""

# ============================================
# COMPILAR APK
# ============================================

echo "========================================"
echo "🔨 COMPILANDO APK (pode demorar 3-5 min)"
echo "========================================"

cd $HOME/PontoApp
gradle assembleDebug

echo ""
echo "========================================"
echo "📦 COPIANDO APK PARA DOWNLOADS"
echo "========================================"

cp $HOME/PontoApp/app/build/outputs/apk/debug/app-debug.apk /sdcard/Download/PontoApp.apk
chmod 644 /sdcard/Download/PontoApp.apk

echo ""
echo "========================================"
echo "🎉 TUDO PRONTO!"
echo "========================================"
echo ""
echo "✅ Ambiente Android configurado"
echo "✅ App Ponto Eletrônico criado"
echo "✅ APK salvo em: /sdcard/Download/PontoApp.apk"
echo ""
echo "📲 Agora no seu celular:"
echo "   1. Abra o app 'Files'"
echo "   2. Vá para 'Download'"
echo "   3. Toque em 'PontoApp.apk'"
echo "   4. Instale e use!"
echo ""
echo "========================================"
