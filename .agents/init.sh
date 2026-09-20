#!/usr/bin/env bash
# ==============================================================================
# Agent Squad v2: Otomatik Ortam ve Araç Başlatma Scripti (Pure Bash / Zero Python)
#
# Kullanım:  bash .agents/init.sh [NamespacePrefix]
#
# Namespace verilmezse kökteki *.sln adından, o da yoksa klasör adından türetilir.
# ==============================================================================
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "=========================================================="
echo "🚀 Agent Squad v2: Ortam ve Araç Kurulumu Başlatılıyor..."
echo "📂 Proje Dizini: $PROJECT_ROOT"
echo "=========================================================="

# ---------------------------------------------------------------------------
# 1. Hedef Solution ve Namespace Tespiti
# ---------------------------------------------------------------------------
SLN_FILE="$(find . -maxdepth 1 -name '*.sln' -print -quit)"
if [ -n "$SLN_FILE" ]; then
    SLN_NAME="$(basename "$SLN_FILE")"
    DEFAULT_NS="${SLN_NAME%.sln}"
else
    DEFAULT_NS="$(basename "$PROJECT_ROOT")"
    SLN_NAME="${DEFAULT_NS}.sln"
fi

NAMESPACE="${1:-$DEFAULT_NS}"

# Namespace, C# tanımlayıcısı ve sed değiştirme metni olarak güvenli olmalıdır.
if ! [[ "$NAMESPACE" =~ ^[A-Za-z_][A-Za-z0-9_]*(\.[A-Za-z_][A-Za-z0-9_]*)*$ ]]; then
    echo "❌ Geçersiz namespace prefix: '$NAMESPACE'"
    echo "   Yalnızca harf, rakam, alt çizgi ve nokta içeren bir C# namespace'i verin (örn: Contoso.Billing)."
    exit 1
fi

echo "🎯 Çözüm Adı: $SLN_NAME"
echo "🎯 Namespace Prefix: $NAMESPACE"

# ---------------------------------------------------------------------------
# 2. tasks.json Kurulumu
# ---------------------------------------------------------------------------
if [ -f "tasks.json" ]; then
    echo "📋 tasks.json zaten mevcut, korunuyor."
elif [ -f "tasks.template.json" ]; then
    echo "📋 tasks.json şablondan oluşturuluyor..."
    cp tasks.template.json tasks.json
elif [ -f ".agents/tasks.template.json" ]; then
    echo "📋 tasks.json şablondan oluşturuluyor..."
    cp .agents/tasks.template.json tasks.json
else
    echo "⚠️  tasks.template.json bulunamadı; görev kuyruğu oluşturulamadı."
fi

# ---------------------------------------------------------------------------
# 3. stryker-config.json Uyarlaması
# ---------------------------------------------------------------------------
if [ -f "stryker-config.json" ]; then
    echo "🧪 stryker-config.json çözüm adı güncelleniyor ($SLN_NAME)..."
    sed -i.bak -E "s|(\"solution\"[[:space:]]*:[[:space:]]*\")[^\"]*(\")|\1${SLN_NAME}\2|" stryker-config.json
    rm -f stryker-config.json.bak
fi

# ---------------------------------------------------------------------------
# 4. ArchUnitNET Mimari Test Projesi Uyarlaması
#
# 'Company' öneki hem .cs dosyalarında hem de proje dosyası ADINDA geçtiği için
# ikisi birlikte yeniden adlandırılır; aksi halde csproj adı ile RootNamespace
# birbirinden ayrışır ve sonraki adımlardaki yol referansları kırılır.
# ---------------------------------------------------------------------------
TEST_DIR="tests/ArchitectureTests"
TEST_CSPROJ="$TEST_DIR/${NAMESPACE}.ArchitectureTests.csproj"

if [ -d "$TEST_DIR" ]; then
    if [ "$NAMESPACE" != "Company" ]; then
        echo "🏛️ $TEST_DIR namespace güncelleniyor (Company -> $NAMESPACE)..."
        for f in "$TEST_DIR"/*.cs "$TEST_DIR"/*.csproj; do
            [ -e "$f" ] || continue
            sed -i.bak "s/\bCompany\b/${NAMESPACE}/g" "$f"
            rm -f "$f.bak"
        done

        if [ -f "$TEST_DIR/Company.ArchitectureTests.csproj" ]; then
            mv "$TEST_DIR/Company.ArchitectureTests.csproj" "$TEST_CSPROJ"
        fi
    else
        TEST_CSPROJ="$TEST_DIR/Company.ArchitectureTests.csproj"
    fi
fi

# ---------------------------------------------------------------------------
# 5. Çözüme Ekleme (Eğer .sln varsa)
# ---------------------------------------------------------------------------
if [ -n "$SLN_FILE" ] && [ -f "$TEST_CSPROJ" ] && command -v dotnet >/dev/null 2>&1; then
    echo "🔗 Mimari test projesi çözüme bağlanıyor..."
    dotnet sln "$SLN_FILE" add "$TEST_CSPROJ" >/dev/null 2>&1 || \
        echo "⚠️  Proje çözüme eklenemedi; 'dotnet sln add $TEST_CSPROJ' komutunu elle çalıştırın."
fi

# ---------------------------------------------------------------------------
# 6. Doğrulama: Kural kataloğu tutarlılığı (motorlardan bağımsız, daima çalışır)
# ---------------------------------------------------------------------------
VERIFY_FAILED=0
if [ -f ".agents/verify.sh" ]; then
    echo
    echo "🔍 Kural kataloğu tutarlılığı doğrulanıyor..."
    bash .agents/verify.sh || VERIFY_FAILED=1
fi

# ---------------------------------------------------------------------------
# 7. Doğrulama: dotnet test
# ---------------------------------------------------------------------------
if [ -f "$TEST_CSPROJ" ]; then
    if command -v dotnet >/dev/null 2>&1; then
        echo
        echo "🔍 Mimari testler derleniyor ve doğrulanıyor..."
        dotnet test "$TEST_CSPROJ" --verbosity quiet || \
            echo "⚠️  Mimari testler başarısız. ArchitectureRulesTests.ProductAssemblies() içine hedef çözümün katman assembly'lerini eklediğinizden emin olun."
    else
        echo "⚠️  dotnet CLI bulunamadı; mimari test doğrulaması atlandı."
    fi
fi

# ---------------------------------------------------------------------------
# 8. Özet
# ---------------------------------------------------------------------------
OG_RULE_COUNT=$(grep -c '^- id: ' .opengrep/rules.yaml 2>/dev/null || echo 0)
CATALOG_COUNT=$(grep -c '^- id: ' .agents/rules_registry.yaml 2>/dev/null || echo 0)

echo
echo "=========================================================="
if [ "$VERIFY_FAILED" -eq 0 ]; then
    echo "✅ Agent Squad v2 kurulumu tamamlandı!"
else
    echo "⚠️  Kurulum tamamlandı ancak kural kataloğunda tutarsızlık var."
    echo "   Düzeltmeden geliştirmeye başlamayın: bash .agents/verify.sh"
fi
echo "📌 Kural kataloğu:  .agents/rules_registry.yaml ($CATALOG_COUNT kural)"
echo "📌 Görev kuyruğu:   tasks.json"
echo "📌 Mimari testler:  $TEST_DIR/"
echo "📌 Statik analiz:   .opengrep/rules.yaml ($OG_RULE_COUNT kural)"
echo "📌 Kalite kapıları: Directory.Build.props & BannedSymbols.txt"
echo "📌 Tutarlılık:      bash .agents/verify.sh"
echo "=========================================================="

exit "$VERIFY_FAILED"
