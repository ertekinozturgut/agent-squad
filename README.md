# 🤖 Agent Squad v2 — UDAP .NET Standart İzlenebilirliğiyle

> **Antigravity AI IDE için 8 Kişilik Otonom Yazılım Geliştirme Squad'ı**  
> Clean Architecture, Domain-Driven Design (DDD), 23 GoF Tasarım Kalıbı, **175 UDAP .NET Kuralı**, **11 Uluslararası & Sektörel Standart**, **5 Motorlu Analiz Hattı** ve **%100 Saf .NET / C# Yerel Araç Entegrasyonu (Sıfır Python Bağımlılığı)**.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform: Antigravity](https://img.shields.io/badge/Platform-Antigravity%20AI-purple.svg)](https://github.com/ertekinozturgut/agent-squad)
[![Tech: .NET 10 / C# 14](https://img.shields.io/badge/.NET-10.0-512BD4.svg)](https://dotnet.microsoft.com/)
[![Rules: 175 UDAP Rules](https://img.shields.io/badge/Rules-175%20UDAP%20Rules%20(v2)-blueviolet.svg)](.agents/rules_registry.yaml)
[![Standards: 11 Standard Traceability](https://img.shields.io/badge/Standards-11%20Standards%20(ASVS%205.0%20%7C%2025010%20%7C%2021434)-darkgreen.svg)](docs/TRACEABILITY_MATRIX.md)
[![Pipeline: 5 Engine](https://img.shields.io/badge/Engines-ArchUnit%20%7C%20Opengrep%20%7C%20CodeQL%20%7C%20Stryker%20%7C%20Roslyn-orange.svg)](tests/ArchitectureTests/)
[![Quality: Zero Warnings](https://img.shields.io/badge/Quality-Zero%20Compiler%20Warnings-brightgreen.svg)](Directory.Build.props)
[![Mutations: Stryker 0 Survived](https://img.shields.io/badge/Mutation%20Testing-0%20Survived%20Mutants-success.svg)](stryker-config.json)

---

## 🌟 Genel Bakış

**Agent Squad v2**, tek bir yapay zeka modeline tüm yazılım geliştirme sürecini yüklemek yerine; endüstri standardı kanonik literatürlerle donatılmış **8 bağımsız uzman persona**, **6 bağlayıcı anayasal kural**, **175 kurallı merkezi kural kataloğu (`rules_registry.yaml`)** ve **5 motorlu yerel denetim hattı** ile çalışan kurumsal seviyede bir yapay zeka yazılım fabrikası mimarisidir.

### Temel Felsefe
- **Uzmanlaşma:** Her persona sadece kendi disiplininde (Analiz, Mimari, Kodlama, Güvenlik, Test) dünyanın en prestijli literatürlerine dayanarak çalışır.
- **Standart İzlenebilirliği:** Her kural en az bir uluslararası veya sektörel standarda bağlanır (ASVS 5.0, ISO 25010, CWE, UNECE R155 vb.).
- **5 Motorlu Otomasyon Hattı:** ArchUnitNET, Opengrep, CodeQL, Stryker ve Roslyn derleyici analizörleri ile çok katmanlı savunma.
- **Saf .NET / Sıfır Python:** Dış script bağımlılığı yoktur; her kontrol aracı doğrudan kendi resmi konfigürasyonlarıyla (`tests/`, `.opengrep/`, `.codeql/`, `.editorconfig`, `stryker-config.json`, `Directory.Build.props`) çalışır.
- **WIP = 1 (Work-in-Progress):** Ekip tek seferde yalnızca tek bir atomik göreve odaklanır; çoklu görev karmaşası engellenir.
- **Kural Şiddet Modeli:** S1 (Build kırar, tolerans yok), S2 (PR bloklar, gerekçeli `@UdapSuppress` şart), S3 (Uyarı).

---

## 🏛️ 11 Referans Standart ve Kapsam Gerçeği

| Kısaltma | Standart | Kapsam ve Kullanım Amacı |
|---|---|---|
| **ASVS** | OWASP Application Security Verification Standard v5.0.0 (Mayıs 2025, 17 Bölüm, ~350 Gereksinim) | Güvenlik gereksinimlerinin birincil kaynağı (L1/L2/L3) |
| **CWE** | MITRE Common Weakness Enumeration | Zafiyet sınıfı kimliği |
| **A10** | OWASP Top 10:2021 | Yönetici raporlaması ve web riskleri |
| **API10** | OWASP API Security Top 10:2023 | Entegrasyon ve API yüzeyi |
| **25010** | ISO/IEC 25010:2023 (9 Karakteristik) | Ürün kalite modeli (Modularity, Performance, Reliability, Security vb.) |
| **SSDF** | NIST SP 800-218 Secure Software Development Framework | Güvenli süreç kapıları |
| **SLSA** | SLSA v1.0 Build Levels (L2/L3) | Tedarik zinciri güvenliği ve build bütünlüğü |
| **21434** | ISO/SAE 21434 + UNECE R155 (CSMS) | Otomotiv siber güvenlik yönetim sistemi |
| **ASPICE** | Automotive SPICE v4.0 (SWE.1 - SWE.6) | Süreç izlenebilirliği (Gereksinim ➔ Kod ➔ Test) |
| **KVKK** | 6698 Sayılı KVKK / GDPR | Kişisel veri işleme, aktarma ve saklama ilkeleri |
| **MSFDG** | Microsoft Framework Design Guidelines | C# ve .NET API hijyeni |

> [!IMPORTANT]
> **Kapsam Gerçeği (Reality Check):**
> ASVS'in yaklaşık **%55'i** statik analiz araçlarıyla otomatik doğrulanabilir. İş mantığı doğrulaması, dinamik oturum davranışı ve yetkilendirme kararlarının mantıksal doğruluğu Solution Architect ve QA Tester incelemesi gerektirir. Bağımsız denetim kanıtları için: [docs/TRACEABILITY_MATRIX.md](docs/TRACEABILITY_MATRIX.md).

---

## 🔄 Squad El Sıkışma Zinciri ve Görev Durum Makinesi

Tüm görevler `tasks.json` üzerindeki durum makinesi doğrultusunda şu 5 aşamalı zinciri takip eder:

```text
       ┌───────────┐
       │  pending  │ (Backlog'da bekleyen atomik görev)
       └─────┬─────┘
             │
             ▼
   [Aşama 1: Kapsam & Analiz] ────────► İş Analisti (BABOK v3 & JTBD & PII Sınıflandırması)
             │
             ▼
   [Aşama 2: Mimari & UX Şartnamesi] ─► Çözüm Mimarı (contract.yaml / GoF / ADR) & UI/UX Tasarımcısı
             │
             ├──────────────────────────► 🚪 [DoR Giriş Kapısı Onayı]
             ▼
   [Aşama 3: Geliştirme] ─────────────► Backend Engineer (.NET 10 / TimeProvider) & Razor Specialist
             │
             ▼
   [Aşama 4: Kalite & Güvenlik] ──────► QA Tester (Stryker 0 Mutant) & Security Reviewer (5-Engine Guard)
             │                          │
             │                          ├────── (Red / Revizyon Gerekli) ─────► ┌───────────────────┐
             │                          │                                       │ changes_requested │
             │                          │                                       └─────────┬─────────┘
             │                          │                                                 │ (Düzeltildi)
             │                          │ ◄───────────────────────────────────────────────┘
             ├──────────────────────────► 🚪 [DoD Çıkış Kapısı Onayı]
             ▼
      ┌───────────┐
      │ completed │ ──► Sıradaki 'pending' göreve geçiş
      └───────────┘
```

---

## 🧠 8 Personanın Uzmanlık Alanları

| Persona | Rol & Uzmanlık | Dayandığı Standart & Kanon | Temel Çıktı & Sorumluluk |
| :--- | :--- | :--- | :--- |
| **`project-manager`** | Orkestratör & Akış Yöneticisi | PMBOK 7th, Scrum, DORA, 8 Dalga Protokolü | `tasks.json`, WIP=1, DoR/DoD kapı onayları ve 8 dalgalı devreye alma yönetimi. |
| **`business-analyst`** | Değer & Çelişki Dedektörü | BABOK v3, JTBD, KVKK m.4-12, ISO 21434 | 4 kademeli Gherkin (`Happy`, `Validation`, `Conflict`, `Security`), PII Veri Sözlüğü. |
| **`solution-architect`** | Clean Architecture & DDD Mimarı | Clean Arch, DDD, GoF, ISO 25010, ASPICE SWE.2 | `.agents/contract.yaml` sözleşmesi, ArchUnitNET testleri, ADR kayıtları, Outbox pattern. |
| **`backend-engineer`** | .NET 10 & 23 GoF Kalıbı Ustası | Clean Code, C# 14, 23 GoF, Concurrency Cookbook | İnce Controller, AsNoTracking, TimeProvider, CancellationToken, Polly resilience. |
| **`uiux-designer`** | UX & Tasarım Sistemi Yöneticisi | Don Norman, Steve Krug, Refactoring UI, WCAG AA | Bootstrap 5.3 grid, 5 bileşen durumu (`Hover`, `Focus`, `Loading` vb.), sıfır inline CSS. |
| **`razor-specialist`** | Modern Razor & Frontend Uzmanı | ASP.NET Core Tag Helpers, HTML Living Standard | Modern `.cshtml`, double-submit engelleme, Partial View / ViewComponent ayrımı. |
| **`qa-tester`** | Test & Mutasyon Avcısı | xUnit Patterns, Stryker .NET, ISTQB, ASPICE | Stryker mutasyon testi (0 hayatta kalan mutant - R-TST-001), TDD RED_GATE, RTM. |
| **`security-reviewer`** | Siber Güvenlik & Kalite Baş Denetçisi | ASVS v5.0 (L1-L3), OWASP Top 10, CWE, KVKK | 5 motorlu analiz (ArchUnit, Opengrep, CodeQL, Stryker, Roslyn), S1/S2 kapı onayı. |

---

## 🛠️ 5 Motorlu Yerel Denetim Hattı ve Çalıştırma

Tüm denetim araçları doğrudan ilgili konfigürasyon dosyalarına bağlanmıştır ve yerel CLI komutlarıyla çalışır:

| Araç / Motor | Doğrudan Yapılandırma Dosyası | Çalıştırma Komutu | Kapsam ve Rol |
|---|---|---|---|
| **ArchUnitNET** | [`tests/ArchitectureTests/`](tests/ArchitectureTests/) | `dotnet test tests/ArchitectureTests/` | Katman sınırları, dikey dilim izolasyonu, endpoint yetki ve PII marker testleri (32 kural). |
| **Opengrep** | [`.opengrep/rules.yaml`](.opengrep/rules.yaml) | `opengrep scan --config .opengrep/rules.yaml` | Sintaktik hijyen; .Result, async/await, HttpClient, lock, yapılandırılmış loglama (71 kural). |
| **CodeQL** | [`.codeql/queries/`](.codeql/README.md) & [`.codeql/models/`](.codeql/models/) | `codeql database analyze db .codeql/queries/codeql-suites/csharp-quality-rules.qls` | 35 özel kural (8 Design Patterns, 11 SonarQube Temiz Kod, 16 Senior Mühendislik kuralı) ve derin taint modelleri. |
| **Stryker .NET** | [`stryker-config.json`](stryker-config.json) | `dotnet stryker --since:origin/main` | Mutasyon test kapısı; değişen dosyalarda 0 hayatta kalan mutant (R-TST-001) (3 kural). |
| **Roslyn Analizörleri**| [`Directory.Build.props`](Directory.Build.props), [`BannedSymbols.txt`](BannedSymbols.txt), [`.editorconfig`](.editorconfig) | `dotnet build` | `BannedSymbols.txt` (TimeProvider), SonarAnalyzer, VSTHRD ve sıfır uyarı kuralı (22 kural). |
| **Süreç Kapıları** | [`nuget.config`](nuget.config), [`.agents/contract.yaml`](.agents/contract.yaml), [docs/](docs/) | CI / PR Pipeline | Lockfile, SBOM, NuGet allowlist, ADR, ASPICE izlenebilirliği (28 kural). |

---

## 📜 6 Bağlayıcı Anayasa Kuralı (`.agents/rules/`)

1. **`01-squad-handoff-protocol.md`:** Görev döngüsü, S1/S2/S3 şiddet kapısı, DoR/DoD kontrolleri ve 8 dalgalı devreye alma sırası.
2. **`02-architecture-invariants.md`:** Katman sınırları (R-ARCH), dikey dilim izolasyonu (R-MOD), TimeProvider ve pure domain kuralları.
3. **`03-security-guardrails.md`:** ASVS v5.0, KVKK/PII sızıntı koruması, CSRF/XSS, IDOR, SQLi ve kriptografi hijyeni.
4. **`04-ui-design-invariants.md`:** Sıfır inline CSS, WCAG AA erişilebilirlik, 5 bileşen durumu ve empty state tasarımı.
5. **`05-backend-development-clean-code-standards.md`:** Fonksiyon sınırları (max 60 satır, max 3 parametre, karmaşıklık $\le 10$), asenkron kurallar, EF Core sayfalama ve Polly resilience.
6. **`06-standard-traceability-and-compliance.md`:** 11 standardın genel çerçevesi, %55 statik ASVS kapsam gerçeği ve ASPICE/R155 denetim kanıtları.

---

## 🚀 Projelerinizde Nasıl Kullanılır? (Otomatik Başlatma)

### Yöntem A: Tek Prompt ile Ajan Üzerinden Otomatik Kurulum (Önerilen)
`.agents/` klasörünü projenize kopyalayın ve Antigravity AI IDE'ye şu istemi verin:
> *"Bu projede agent-squad'ı başlat. .agents/INIT.md yönergelerini izleyerek hedef çözüm ve projelere uygun kök konfigürasyonlarını, ArchUnitNET testlerini, Opengrep kurallarını ve tasks.json dosyasını otomatik oluştur ve doğrula."*

Ajan tüm kök araçlarını (`Directory.Build.props`, `BannedSymbols.txt`, `.editorconfig`, `nuget.config`, `stryker-config.json`, `.opengrep/`, `tests/`) projenizin çözüm ve namespace adına göre otomatik kurar ve `dotnet test` ile doğrular.

### Yöntem B: Tek Terminal Komutuyla Kurulum
Doğrudan terminal üzerinden tek komutla tüm ortamı kurmak için:
```bash
bash .agents/init.sh [NamespacePrefix]
```

---

### Manuel Çalıştırma ve Denetim Komutları (Saf .NET)
```bash
# 1. Derleme, Roslyn ve BannedApi (TimeProvider vb.) kontrolü:
dotnet build

# 2. Mimari testleri (ArchUnitNET):
dotnet test tests/ArchitectureTests/Company.ArchitectureTests.csproj

# 3. Mutasyon testi (Stryker 0 mutant):
dotnet stryker --since:origin/main

# 4. Güvenlik ve sözdizimi taraması (Opengrep):
opengrep scan --config .opengrep/rules.yaml
```

### 4. Antigravity AI IDE ile Geliştirmeye Başlayın
- Antigravity AI IDE `.agents/rules/` altındaki 6 anayasayı sürekli aktif tutar.
- Persona el kitapları (`SKILL.md`) roller değiştikçe otomatik devreye girer.
- `tasks.json` durum makinesi DoR/DoD kapılarını ve S1/S2 denetimlerini otonom yönetir.

---

## 📄 Lisans

Bu proje [MIT Lisansı](LICENSE) altında açık kaynak olarak sunulmuştur.

## 👨‍💻 Geliştirici

**Ertekin Özturgut**  
- GitHub: [@ertekinozturgut](https://github.com/ertekinozturgut)
