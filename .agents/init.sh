#!/usr/bin/env bash
# ==============================================================================
# Agent Squad v2: Otomatik Ortam ve Araç Başlatma Scripti (Pure Bash / Zero Python)
# ==============================================================================
set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "=========================================================="
echo "🚀 Agent Squad v2: Ortam ve Araç Kurulumu Başlatılıyor..."
echo "📂 Proje Dizini: $PROJECT_ROOT"
echo "=========================================================="

# 1. Hedef Solution ve Namespace Tespiti
SLN_FILE=$(find . -maxdepth 1 -name "*.sln" | head -n 1)
if [ -n "$SLN_FILE" ]; then
    SLN_NAME=$(basename "$SLN_FILE")
    DEFAULT_NS="${SLN_NAME%.sln}"
else
    DEFAULT_NS="$(basename "$PROJECT_ROOT")"
    SLN_NAME="${DEFAULT_NS}.sln"
fi

NAMESPACE="${1:-$DEFAULT_NS}"
echo "🎯 Çözüm Adı: $SLN_NAME"
echo "🎯 Namespace Prefix: $NAMESPACE"

# 2. tasks.json Kurulumu
if [ ! -f "tasks.json" ]; then
    if [ -f "tasks.template.json" ]; then
        echo "📋 tasks.json şablondan oluşturuluyor..."
        cp tasks.template.json tasks.json
    elif [ -f ".agents/tasks.template.json" ]; then
        cp .agents/tasks.template.json tasks.json
    fi
fi

# 3. stryker-config.json Uyarlaması
if [ -f "stryker-config.json" ]; then
    echo "🧪 stryker-config.json çözüm adı güncelleniyor ($SLN_NAME)..."
    sed -i.bak "s/\"solution\": \".*\"/\"solution\": \"$SLN_NAME\"/g" stryker-config.json 2>/dev/null || true
    rm -f stryker-config.json.bak
fi

# 4. ArchUnitNET Mimari Test Projesi Uyarlaması
if [ -d "tests/ArchitectureTests" ]; then
    echo "🏛️ tests/ArchitectureTests namespace güncelleniyor ($NAMESPACE)..."
    sed -i.bak "s/Company/$NAMESPACE/g" tests/ArchitectureTests/ArchitectureRulesTests.cs 2>/dev/null || true
    sed -i.bak "s/Company/$NAMESPACE/g" tests/ArchitectureTests/SampleArchitectureFixture.cs 2>/dev/null || true
    rm -f tests/ArchitectureTests/*.bak
fi

# 5. Çözüme Ekleme (Eğer .sln varsa)
if [ -f "$SLN_FILE" ] && [ -f "tests/ArchitectureTests/Company.ArchitectureTests.csproj" ]; then
    echo "🔗 Mimari test projesi çözüme bağlanıyor..."
    dotnet sln "$SLN_FILE" add tests/ArchitectureTests/*.csproj 2>/dev/null || true
fi

# 6. Doğrulama: dotnet test
if [ -f "tests/ArchitectureTests/Company.ArchitectureTests.csproj" ]; then
    echo "🔍 Mimari testler derleniyor ve doğrulanıyor..."
    dotnet test tests/ArchitectureTests/Company.ArchitectureTests.csproj --verbosity quiet || {
        echo "⚠️ Test çalıştırmasında uyarı alındı, lütfen bağımlılıkları kontrol edin."
    }
fi

# 7. Doğrulama: Opengrep
if command -v opengrep &> /dev/null; then
    echo "🔍 Opengrep kural seti kontrol ediliyor..."
    opengrep scan --config .opengrep/rules.yaml --dry-run >/dev/null 2>&1 && echo "✅ Opengrep kuralları hazır (84 kural)."
fi

echo "=========================================================="
echo "✅ Agent Squad v2 kurulumu başarıyla tamamlandı!"
echo "📌 Görev kuyruğu: tasks.json"
echo "📌 Mimari testler: tests/ArchitectureTests/"
echo "📌 Statik analiz: .opengrep/rules.yaml"
echo "📌 Kalite kapıları: Directory.Build.props & BannedSymbols.txt"
echo "=========================================================="
