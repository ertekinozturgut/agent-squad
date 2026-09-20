#!/usr/bin/env bash
# ==============================================================================
# Agent Squad v2 — Kural Kataloğu Tutarlılık Doğrulayıcısı (Pure Bash / Zero Python)
#
# Bu script, kataloğun (.agents/rules_registry.yaml) vaat ettiği her kapının
# gerçekten var olduğunu doğrular. Kataloğa kural eklemek ile o kuralı uygulayan
# motor konfigürasyonunu yazmak arasındaki kopukluk, bu ürünün en kolay kaçırılan
# hata sınıfıdır; bu script o kopukluğu build zamanında yakalar.
#
# Kontroller:
#   1. Kural kimlikleri benzersiz, zorunlu alanlar dolu, severity/owner geçerli.
#   2. owner == enforced_by içindeki motor (opengrep kuralı archunit'e atanamaz).
#   3. Her opengrep enforced_by -> .opengrep/rules.yaml içinde gerçek bir kural.
#   4. Her archunit enforced_by -> ArchitectureRulesTests.cs içinde gerçek bir test.
#   5. Her codeql enforced_by -> .codeql altında gerçek bir @id (veya standart pakette).
#   6. Her roslyn enforced_by -> .editorconfig / BannedSymbols.txt / Directory.Build.props.
#   7. Ters yön: her opengrep kuralı ve her .ql sorgusu kataloğa bağlı olmalı.
#   8. S1 kuralları otomatik bir kapıya bağlı olmalı (process olamaz).
#   9. Opengrep kurulu ise fixture öz-testi: her kural kendi ihlalini yakalıyor mu,
#      uyumlu fixture'lar sıfır bulgu veriyor mu.
#
# Kullanım:  bash .agents/verify.sh
# Çıkış:     0 = tutarlı, 1 = tutarsızlık var
# ==============================================================================
set -u

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

REGISTRY=".agents/rules_registry.yaml"
OPENGREP_RULES=".opengrep/rules.yaml"
ARCH_TESTS="tests/ArchitectureTests/ArchitectureRulesTests.cs"

ERRORS=0
WARNINGS=0

fail() { printf '  ❌ %s\n' "$1"; ERRORS=$((ERRORS + 1)); }
warn() { printf '  ⚠️  %s\n' "$1"; WARNINGS=$((WARNINGS + 1)); }
ok()   { printf '  ✅ %s\n' "$1"; }
head_() { printf '\n%s\n' "── $1 ─────────────────────────────────────────────"; }

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# ---------------------------------------------------------------------------
# Katalogdan alanları çıkar (düz, makine üretimi YAML; her kural '- id:' ile başlar)
# ---------------------------------------------------------------------------
if [ ! -f "$REGISTRY" ]; then
    echo "❌ $REGISTRY bulunamadı."
    exit 1
fi

awk '
  /^- id: /            { id=$3;      print "ID\t" id                  ; next }
  /^  severity: /      { print "SEV\t" id "\t" $2                     ; next }
  /^  owner: /         { print "OWN\t" id "\t" $2                     ; next }
  /^  enforced_by: /   { print "ENF\t" id "\t" $2                     ; next }
  /^  fixture_proven: /{ print "FIX\t" id "\t" $2                     ; next }
  /^  text: /          { print "TXT\t" id                             ; next }
  /^  rationale: /     { print "RAT\t" id                             ; next }
  /^  remediation: /   { print "REM\t" id                             ; next }
  /^  also_enforced_by:/ { in_also=1                                  ; next }
  /^  [a-z_]+: /       { in_also=0                                    ; next }
  in_also && /^  - /   { print "ALSO\t" id "\t" $2                    ; next }
' "$REGISTRY" > "$TMP/reg.tsv"

grep -P '^ID\t' "$TMP/reg.tsv" | cut -f2 > "$TMP/ids.txt"
RULE_COUNT=$(wc -l < "$TMP/ids.txt")

echo "=========================================================="
echo "🔍 Agent Squad v2 — Kural Kataloğu Doğrulaması"
echo "📚 Katalog: $REGISTRY ($RULE_COUNT kural)"
echo "=========================================================="

# ---------------------------------------------------------------------------
head_ "1. Katalog bütünlüğü"
# ---------------------------------------------------------------------------
DUPES=$(sort "$TMP/ids.txt" | uniq -d)
if [ -n "$DUPES" ]; then
    while read -r d; do fail "Yinelenen kural kimliği: $d"; done <<< "$DUPES"
else
    ok "Tüm kural kimlikleri benzersiz ($RULE_COUNT)."
fi

for field in SEV OWN ENF TXT RAT REM; do
    n=$(grep -cP "^$field\t" "$TMP/reg.tsv" || true)
    [ "$n" -eq "$RULE_COUNT" ] || fail "$field alanı $n/$RULE_COUNT kuralda tanımlı (eksik alan var)."
done

while IFS=$'\t' read -r _ id sev; do
    case "$sev" in S1|S2|S3) ;; *) fail "$id: geçersiz severity '$sev' (S1/S2/S3 bekleniyor)." ;; esac
done < <(grep -P '^SEV\t' "$TMP/reg.tsv")

while IFS=$'\t' read -r _ id own; do
    case "$own" in
        opengrep|archunit|codeql|roslyn|stryker|msbuild|process) ;;
        *) fail "$id: geçersiz owner '$own'." ;;
    esac
done < <(grep -P '^OWN\t' "$TMP/reg.tsv")
[ "$ERRORS" -eq 0 ] && ok "Zorunlu alanlar, severity ve owner değerleri geçerli."

# ---------------------------------------------------------------------------
head_ "2. owner ↔ enforced_by uyumu"
# ---------------------------------------------------------------------------
join -t$'\t' -1 2 -2 2 \
    <(grep -P '^OWN\t' "$TMP/reg.tsv" | sort -t$'\t' -k2,2) \
    <(grep -P '^ENF\t' "$TMP/reg.tsv" | sort -t$'\t' -k2,2) \
    -o 1.2,1.3,2.3 > "$TMP/owner_enf.tsv"

MISMATCH=0
while IFS=$'\t' read -r id own enf; do
    case "$own" in
        opengrep) [[ "$enf" == opengrep-* || "$enf" == banned-import-* ]] || { fail "$id: owner=opengrep ama enforced_by='$enf'."; MISMATCH=1; } ;;
        archunit) [[ "$enf" == ArchUnitNET.* ]] || { fail "$id: owner=archunit ama enforced_by='$enf'."; MISMATCH=1; } ;;
        codeql)   [[ "$enf" == cs/* ]]          || { fail "$id: owner=codeql ama enforced_by='$enf'."; MISMATCH=1; } ;;
        roslyn)   [[ "$enf" == SonarAnalyzer.* || "$enf" == Microsoft.* || "$enf" == Roslynator.* ]] \
                                                || { fail "$id: owner=roslyn ama enforced_by='$enf'."; MISMATCH=1; } ;;
        stryker)  [[ "$enf" == stryker.* ]]     || { fail "$id: owner=stryker ama enforced_by='$enf'."; MISMATCH=1; } ;;
        msbuild)  [[ "$enf" == msbuild.* ]]     || { fail "$id: owner=msbuild ama enforced_by='$enf'."; MISMATCH=1; } ;;
        process)  [[ "$enf" == process.* ]]     || { fail "$id: owner=process ama enforced_by='$enf'."; MISMATCH=1; } ;;
    esac
done < "$TMP/owner_enf.tsv"
[ "$MISMATCH" -eq 0 ] && ok "Her kuralın owner'ı enforced_by içindeki motorla aynı."

# ---------------------------------------------------------------------------
head_ "3. Opengrep kural eşleşmesi"
# ---------------------------------------------------------------------------
if [ -f "$OPENGREP_RULES" ]; then
    grep -E '^- id: ' "$OPENGREP_RULES" | sed 's/^- id: //' | sort > "$TMP/og_ids.txt"
    OG_COUNT=$(wc -l < "$TMP/og_ids.txt")

    grep -P '^(ENF|ALSO)\t' "$TMP/reg.tsv" | cut -f3 \
        | grep -E '^(opengrep-|banned-import-)' | sort -u > "$TMP/og_used.txt"

    MISSING=$(comm -13 "$TMP/og_ids.txt" "$TMP/og_used.txt")
    if [ -n "$MISSING" ]; then
        while read -r m; do fail "Katalog '$m' kuralına atıf yapıyor ama $OPENGREP_RULES içinde yok."; done <<< "$MISSING"
    fi
    ORPHAN=$(comm -23 "$TMP/og_ids.txt" "$TMP/og_used.txt")
    if [ -n "$ORPHAN" ]; then
        while read -r o; do fail "Opengrep kuralı '$o' hiçbir katalog kuralına bağlı değil (izlenemez kural)."; done <<< "$ORPHAN"
    fi
    [ -z "$MISSING" ] && [ -z "$ORPHAN" ] && ok "$OG_COUNT opengrep kuralının tamamı kataloğa bağlı."
else
    fail "$OPENGREP_RULES bulunamadı."
fi

# ---------------------------------------------------------------------------
head_ "4. ArchUnitNET test eşleşmesi"
# ---------------------------------------------------------------------------
if [ -f "$ARCH_TESTS" ]; then
    grep -oP '(?<=public )(?:void|async Task) \K\w+(?=\()' "$ARCH_TESTS" | sort -u > "$TMP/arch_methods.txt"
    ARCH_METHOD_COUNT=$(wc -l < "$TMP/arch_methods.txt")

    grep -P '^(ENF|ALSO)\t' "$TMP/reg.tsv" | cut -f3 | grep '^ArchUnitNET\.' \
        | sed 's/^ArchUnitNET\.//' | sort -u > "$TMP/arch_used.txt"

    MISSING=$(comm -13 "$TMP/arch_methods.txt" "$TMP/arch_used.txt")
    if [ -n "$MISSING" ]; then
        while read -r m; do fail "Katalog 'ArchUnitNET.$m' testine atıf yapıyor ama böyle bir test metodu yok."; done <<< "$MISSING"
    fi
    ORPHAN=$(comm -23 "$TMP/arch_methods.txt" "$TMP/arch_used.txt")
    if [ -n "$ORPHAN" ]; then
        while read -r o; do warn "Mimari test '$o' hiçbir katalog kuralına bağlı değil."; done <<< "$ORPHAN"
    fi
    [ -z "$MISSING" ] && ok "$ARCH_METHOD_COUNT mimari test metodunun tamamı kataloğa bağlı."
else
    fail "$ARCH_TESTS bulunamadı."
fi

# ---------------------------------------------------------------------------
head_ "5. CodeQL sorgu eşleşmesi"
# ---------------------------------------------------------------------------
if [ -d .codeql/queries ]; then
    grep -rhoP '@id\s+\K\S+' .codeql/queries --include='*.ql' | sort -u > "$TMP/ql_ids.txt"
    QL_COUNT=$(wc -l < "$TMP/ql_ids.txt")

    grep -P '^(ENF|ALSO)\t' "$TMP/reg.tsv" | cut -f3 | grep '^cs/' | sort -u > "$TMP/ql_used.txt"

    # Standart codeql/csharp-queries paketindeki sorgular yerel dosya olarak bulunmaz.
    comm -13 "$TMP/ql_ids.txt" "$TMP/ql_used.txt" > "$TMP/ql_external.txt"
    while read -r q; do
        case "$q" in
            cs/design-patterns/*|cs/sonarqube/*|cs/senior-engineering/*)
                fail "Katalog '$q' sorgusuna atıf yapıyor ama .codeql/queries altında böyle bir @id yok." ;;
            *)
                grep -qF "$q" .codeql/queries/codeql-suites/csharp-quality-rules.qls 2>/dev/null \
                    || warn "Standart CodeQL sorgusu '$q' analiz süitinde açıkça listelenmiyor." ;;
        esac
    done < "$TMP/ql_external.txt"

    ORPHAN=$(comm -23 "$TMP/ql_ids.txt" "$TMP/ql_used.txt")
    if [ -n "$ORPHAN" ]; then
        while read -r o; do fail "CodeQL sorgusu '$o' hiçbir katalog kuralına bağlı değil (izlenemez sorgu)."; done <<< "$ORPHAN"
    fi
    [ -z "$ORPHAN" ] && ok "$QL_COUNT özel CodeQL sorgusunun tamamı kataloğa bağlı."
else
    warn ".codeql/queries bulunamadı, CodeQL kontrolü atlandı."
fi

# ---------------------------------------------------------------------------
head_ "6. Roslyn analizör eşleşmesi"
# ---------------------------------------------------------------------------
cat .editorconfig BannedSymbols.txt Directory.Build.props 2>/dev/null > "$TMP/roslyn_config.txt"
ROSLYN_MISSING=0
while IFS=$'\t' read -r _ id enf; do
    case "$enf" in
        SonarAnalyzer.*|Microsoft.*|Roslynator.*)
            code="${enf##*.}"
            grep -qF "$code" "$TMP/roslyn_config.txt" \
                || { fail "$id: '$code' tanı kodu .editorconfig / BannedSymbols.txt / Directory.Build.props içinde yapılandırılmamış."; ROSLYN_MISSING=1; } ;;
    esac
done < <(grep -P '^ENF\t' "$TMP/reg.tsv")
[ "$ROSLYN_MISSING" -eq 0 ] && ok "Tüm Roslyn tanı kodları yapılandırma dosyalarında mevcut."

# ---------------------------------------------------------------------------
head_ "6b. MSBuild özellik eşleşmesi"
# ---------------------------------------------------------------------------
MSBUILD_MISSING=0
while IFS=$'\t' read -r _ id enf; do
    case "$enf" in
        msbuild.*)
            prop="${enf#msbuild.}"
            grep -qF "<$prop>" Directory.Build.props 2>/dev/null \
                || { fail "$id: '<$prop>' özelliği Directory.Build.props içinde tanımlı değil."; MSBUILD_MISSING=1; } ;;
    esac
done < <(grep -P '^ENF\t' "$TMP/reg.tsv")
[ "$MSBUILD_MISSING" -eq 0 ] && ok "Tüm MSBuild kapı özellikleri Directory.Build.props içinde mevcut."

# ---------------------------------------------------------------------------
head_ "7. S1 kuralları otomatik kapıya bağlı mı"
# ---------------------------------------------------------------------------
S1_MANUAL=0
while IFS=$'\t' read -r id sev own; do
    if [ "$sev" = "S1" ] && [ "$own" = "process" ]; then
        fail "$id: S1 (build kırar) ama yalnızca manuel süreç kapısına bağlı. S2'ye indirin veya otomatikleştirin."
        S1_MANUAL=1
    fi
done < <(join -t$'\t' -1 2 -2 2 \
            <(grep -P '^SEV\t' "$TMP/reg.tsv" | sort -t$'\t' -k2,2) \
            <(grep -P '^OWN\t' "$TMP/reg.tsv" | sort -t$'\t' -k2,2) \
            -o 1.2,1.3,2.3)
[ "$S1_MANUAL" -eq 0 ] && ok "Her S1 kuralı otomatik bir motora bağlı."

# ---------------------------------------------------------------------------
head_ "7b. fixture_proven beyanı"
# ---------------------------------------------------------------------------
# fixture_proven yalnızca bu depoda gerçekten fixture'ı olan kapılar için beyan edilebilir:
#   opengrep -> .opengrep/fixtures/   archunit -> SampleArchitectureFixture.cs
FIX_BAD=0
while IFS=$'\t' read -r id own fix; do
    if [ "$fix" = "true" ] && [ "$own" != "opengrep" ] && [ "$own" != "archunit" ]; then
        fail "$id: fixture_proven=true ama '$own' kapısının bu depoda fixture'ı yok (asılsız kanıt beyanı)."
        FIX_BAD=1
    fi
done < <(join -t$'\t' -1 2 -2 2 \
            <(grep -P '^OWN\t' "$TMP/reg.tsv" | sort -t$'\t' -k2,2) \
            <(grep -P '^FIX\t' "$TMP/reg.tsv" | sort -t$'\t' -k2,2) \
            -o 1.2,1.3,2.3)
[ "$FIX_BAD" -eq 0 ] && ok "fixture_proven beyanları gerçek fixture'larla örtüşüyor."

# ---------------------------------------------------------------------------
head_ "8. Opengrep fixture öz-testi"
# ---------------------------------------------------------------------------
SCANNER=""
for candidate in opengrep semgrep osemgrep; do
    command -v "$candidate" >/dev/null 2>&1 && { SCANNER="$candidate"; break; }
done

if [ -z "$SCANNER" ]; then
    warn "opengrep/semgrep kurulu değil; kural öz-testi atlandı."
elif [ ! -d .opengrep/fixtures ]; then
    warn ".opengrep/fixtures bulunamadı; kural öz-testi atlandı."
else
    cp -r .opengrep/fixtures "$TMP/fixtures"
    "$SCANNER" scan --config "$OPENGREP_RULES" --metrics=off --json "$TMP/fixtures" \
        > "$TMP/scan.json" 2>"$TMP/scan.err" || true

    if [ ! -s "$TMP/scan.json" ]; then
        fail "Tarama çıktısı üretilemedi. Ayrıntı: $(tail -n 3 "$TMP/scan.err" | tr '\n' ' ')"
    else
        grep -oE '"check_id": *"[^"]+"' "$TMP/scan.json" \
            | sed -E 's/.*"check_id": *"//; s/"$//; s/^.*\.//' | sort -u > "$TMP/fired.txt"

        NOT_FIRED=$(comm -23 "$TMP/og_ids.txt" "$TMP/fired.txt")
        if [ -n "$NOT_FIRED" ]; then
            while read -r n; do fail "Kural '$n' kendi ihlal fixture'ında tetiklenmedi (ölü kural)."; done <<< "$NOT_FIRED"
        else
            ok "$OG_COUNT kuralın tamamı ihlal fixture'ında tetiklendi."
        fi

        FP=$(grep -oE '"path": *"[^"]*[Cc]ompliant[^"]*"' "$TMP/scan.json" | sort -u)
        if [ -n "$FP" ]; then
            while read -r f; do fail "Uyumlu fixture'da yanlış pozitif: $f"; done <<< "$FP"
        else
            ok "Uyumlu fixture'larda yanlış pozitif yok."
        fi
    fi
fi

# ---------------------------------------------------------------------------
echo
echo "=========================================================="
if [ "$ERRORS" -eq 0 ]; then
    echo "✅ Katalog tutarlı. ($WARNINGS uyarı)"
    echo "=========================================================="
    exit 0
fi
echo "❌ $ERRORS tutarsızlık bulundu. ($WARNINGS uyarı)"
echo "=========================================================="
exit 1
