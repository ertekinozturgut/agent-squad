# Squad El Sıkışma (Handoff), Görev Döngü Protokolü ve UDAP v2 Kalite Kapıları

Bu kural, ekibin (Squad) görev akışını, roller arası el sıkışma standartlarını, **UDAP v2 Şiddet Modelini (S1/S2/S3)**, **8 Dalgalı Devreye Alma Sırasını** ve görev döngü (loop) mekanizmasını düzenler.

## 📚 Dayandığı Literatür ve Standartlar
- **PMBOK Guide & Agile Practice Guide** (Project Management Institute - PMI)
- **The Scrum Guide** (Ken Schwaber & Jeff Sutherland)
- **Accelerate: Building and Scaling High Performing Technology Organizations** (DORA Metrics)
- **Automotive SPICE v4.0 (SWE.1 - SWE.6)**
- **NIST SP 800-218 (SSDF) & SLSA v1.0**
- **UDAP .NET Kural Kataloğu v2 Standartları**

---

## 1. Görev Durum Makinesi (Task State Machine)
`tasks.json` dosyasındaki her görev şu döngüyü sırayla takip eder:
`pending` ➔ `in_progress` ➔ `in_review` ➔ `completed`

*İstisnai Durumlar:*
- **Engel Durumu (`blocked`):** Beklenmedik dış bağımlılık veya teknik engel çıktığında görev `blocked` durumuna alınır; gerekçesi `reviewNotes` içine yazılır.
- **Revizyon / Ret Durumu (`changes_requested`):** QA Tester veya Security Reviewer kapısından geçemeyen görev `changes_requested` durumuna çekilir, `rejectionCount` 1 artırılır ve geliştiriciye geri devredilir.

1. **WIP Limiti:** Aynı anda sadece **1 görev** `in_progress` veya `changes_requested` durumunda olabilir.
2. **Döngü Tetikleme:** Bir görev `completed` olduğunda orkestratör otomatik olarak sıradaki ilk `pending` görevi seçer.

---

## 2. UDAP v2 Şiddet Modeli ve Kapı Davranışı

Tüm kod tabanı `.agents/rules_registry.yaml` içindeki 175 kural doğrultusunda 3 kademeli şiddet modeliyle denetlenir:

| Seviye | Anlamı | Kapı Davranışı | Örnek İhlal |
|---|---|---|---|
| **S1** | Sömürülebilir zafiyet veya mimari sözleşme ihlali | **Build ve PR kırar, istisna/tolerans kesinlikle yok.** | SQL injection, Domain→Infrastructure bağımlılığı, ham catch, .Result bloklama, PII sızıntısı |
| **S2** | Bakım, güvenilirlik veya performans riski | **PR bloklar; yalnızca gerekçeli `@UdapSuppress` ile geçilebilir.** | Timeout'suz dış çağrı, şişkin arayüz (ISP), eksik AsNoTracking |
| **S3** | Kod konvansiyonu ve stil standardı | **Uyarı verir; build ve PR'ı bloklamaz.** | İsimlendirme kuralları, metot uzunluk uyarısı |

> [!IMPORTANT]
> **Terfi Kuralı:** Hiçbir kural referans korpusta `fp_rate` (yanlış pozitif oranı) ölçülmeden S3'ten S2'ye, S2'den S1'e çıkarılamaz. Eşik: S1 için $\le \%2$, S2 için $\le \%10$.

---

## 3. Roller Arası Handoff (El Sıkışma) Zinciri

Her görev istisnasız aşağıdaki 5 aşamalı zinciri tamamlamak zorundadır:

```text
[1. PM] ➔ [2. İş Analisti] ➔ [3. UI/UX & Mimari] ➔ [4. Backend & Razor Dev] ➔ [5. QA & Security] ➔ [PM: Kapanış]
                                    ▲                                               │
                                    └────────────── (Red / Revizyon) ───────────────┘
```

### Aşama 1: Kapsam & Analiz (PM ➔ İş Analisti)
- **Girdi:** Ham kullanıcı isteği veya `tasks.json` görevi.
- **Çıktı:** INVEST formatında Kullanıcı Hikayesi + Gherkin (`Given-When-Then`) kabul kriterleri + Hata senaryoları + PII / Veri Sınıflandırması.

### Aşama 2: Tasarım & Mimari Şartname (Analist ➔ UI/UX & Mimar)
- **UI/UX Tasarımcısı:** Bootstrap 5.3 grid yapısı, bileşen durumları (hover, focus, disabled, loading) ve form UX şartnamesini hazırlar.
- **Sistem Mimarı:** Domain modeli, View'a gidecek `ViewModel` kontratı, uygulanacak **Kurumsal Tasarım Kalıpları (Design Patterns)**, `.agents/contract.yaml` katman sınırları ve Servis arayüzünü tanımlar.
- **Giriş Kapısı (Definition of Ready - DoR):**
  - Analiz ve 4 kademeli Gherkin senaryoları hazır mı? (`Happy`, `Validation`, `Conflict`, `Security`)
  - PII alanları belirlenip `[SensitiveData]` ile işaretlendi mi?
  - Mimari model, Result pattern sözleşmesi ve tasarım kalıbı belirlendi mi?
  - UX durum matrisi hazır mı?
  - Bu şartlar eksiksiz olmadan geliştirme başlatılamaz (`dorMet: true`).

### Aşama 3: Geliştirme (Mimar & UX ➔ Backend & Razor)
- **Backend Engineer:** `05-backend-development-clean-code-standards.md` kurallarına (fonksiyon yönetimi, class kapsamı, OOP, guard clauses, max 25 satır, belirlenen tasarım kalıpları, `TimeProvider`, `CancellationToken`) tam uyumlu kodlar.
- **Razor Specialist:** Mimarın ViewModel'i ve UX şartnamesine birebir sadık kalarak `.cshtml` sayfasını Tag Helper'lar ve Bootstrap ile giydirir.

### Aşama 4: Kalite ve Güvenlik Kapısı (Dev ➔ QA & Security)
- **QA Tester:**
  - TDD RED_GATE (R-TST-002): Testler implementasyon öncesinde kırmızı mıydı?
  - Kabul kriterlerini xUnit ve `WebApplicationFactory` entegrasyon testlerine dönüştürür.
  - Sınır değer (BVA), son kullanıcı kullanılabilirlik ve çift gönderim testlerini yapar.
  - **Stryker Mutasyon Testi (R-TST-001):** Değişen dosyalarda hayatta kalan mutant sayısı = 0 olmalıdır.
- **Security Reviewer:**
  - 5 Motorlu Analiz Hattını çalıştırır: ArchUnitNET, Opengrep, CodeQL, Stryker, Roslyn Analyzers.
  - OWASP ASVS v5.0, CSRF (`[ValidateAntiForgeryToken]`), XSS, Mass Assignment, IDOR denetimlerini yapar.
  - PII ve KVKK sızıntı kontrolü (loglara, URL query string'e veya exception'a PII yazılmaması).
  - S1 ihlali = 0, S2 ihlalleri varsa geçerli `@UdapSuppress` gerekçesi var mı kontrol eder.
- **Ret Mekanizması:** Tek bir test hatası, hayatta kalan mutant veya S1 güvenlik/mimari ihlalinde görev `changes_requested` durumuna alınır ve revizyon notlarıyla geliştiriciye iade edilir.

### Aşama 5: Kapanış (QA & Security ➔ PM)
- **Çıkış Kapısı (Definition of Done - DoD):**
  - Tüm Gherkin kabul kriterleri karşılandı mı? (Evet)
  - `dotnet build` 0 uyarı, 0 hata ile derlendi mi? (`<TreatWarningsAsErrors>true`) (Evet)
  - `BannedSymbols.txt` ve Roslyn analizörleri temiz mi? (Evet)
  - Tüm xUnit ve entegrasyon testleri yeşil mi? (Evet)
  - Stryker mutasyon testinde değişen dosyalarda hayatta kalan mutant = 0 mı? (Evet)
  - S1 kurallarında 0 ihlal sağlandı mı? (Evet)
  - Kullanılan Tasarım Kalıpları `artifacts.designPatternsUsed` içine belgelendi mi? (Evet)
- Şartlar sağlandığında görev `completed` yapılır (`dodMet: true`) ve sıradaki göreve geçilir.

---

## 4. 8 Dalgalı Devreye Alma Protokolü

Kural ailesinin projeye kademeli entegrasyonu aşağıdaki dalga sırasına göre yürütülür:

| Dalga | Kural Aileleri | Kapsam ve Gerekçe |
|---|---|---|
| **Dalga 1** | R-NET-060..065, R-SUP-001..007 | Build ve tedarik zinciri hijyeni (CPM, lockfile, SBOM, NuGet allowlist). Tek seferlik, tartışmasız. |
| **Dalga 2** | Roslyn analizörleri (R-CRY, R-NET-001..009, R-NET-050/051) | SDK'da hazır, yanlış pozitif oranı (FP) en düşük, hızlı ve deterministik derleyici kuralları. |
| **Dalga 3** | ArchUnitNET (R-ARCH, R-MOD, R-SOLID, R-AUTH-001, R-NET-054) | `contract.yaml` dosyasından üretilen, katman sınırlarını ve modülerliği koruyan testler. |
| **Dalga 4** | Opengrep Kurumsal (R-NET-040..058, R-OBS) | En yüksek katma değer; correlation ID, idempotency, retry, circuit breaker ve gözlemlenebilirlik kontrolleri. |
| **Dalga 5** | Opengrep Hijyen (R-SEC, R-CFG, R-INJ-005/006/008) | Geniş sintaktik hijyen kuralları; başlangıçta S3/S2, olgunlaştıkça S1. |
| **Dalga 6** | CodeQL Veri Akışı (R-PII, R-INJ-001..004, R-SEC-008, R-NET-084) | Taint tracking ve PII akış analizi; otomotiv ve KVKK risklerini engelleyen derinlik. |
| **Dalga 7** | Stryker .NET (R-TST-001) | Mutasyon test kapısı; değişen dosyalarda 0 mutant kuralı. |
| **Dalga 8** | Süreç Kapıları (R-AUT-003..005, R-TST-002/007) | Standart izlenebilirlik matrisi, ASPICE SWE.1-6 ve UNECE R155 CSMS denetim izi. |
