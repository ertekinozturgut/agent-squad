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

## 1. Görev Durum Makinesi ve SDLC Runner Motoru
`tasks.json` dosyasındaki her görev deterministik CLI motoru (`node .agents/runner/squad-runner.mjs`) tarafından yönetilir ve şu döngüyü sırayla takip eder:
`pending` ➔ `in_progress` ➔ `in_review` ➔ `completed`

*İstisnai Durumlar & Devre Kesici (Circuit Breaker):*
- **Revizyon / Ret Durumu (`changes_requested`):** QA Tester veya Security Reviewer kapısından geçemeyen görev `changes_requested` durumuna çekilir, `rejectionCount` 1 artırılır ve gerekçesiyle geliştiriciye geri devredilir (`squad-runner reject --reason "..."`).
- **Katı Devre Kesici (Circuit Breaker - Max 3 İterasyon):** Eğer bir görev üst üste 3 kez ret alırsa (`rejectionCount >= 3`), sonsuz döngü ve token israfını önlemek için otonom akış durdurulur. Görev otomatik olarak **`blocked`** durumuna çekilir, `.agents/tasks/{taskId}/rca-report.md` Kök Neden Analizi raporu üretilir ve kullanıcıya eskalasyon yapılır.
- **WIP Limiti:** Aynı anda sadece **1 görev** `in_progress` veya `changes_requested` durumunda olabilir.
- **Git Feature Branch İzolasyonu:** Her yeni görevde `feature/{taskId}` dalı açılır. Tüm ara testler, derlemeler ve mutasyonlar bu izole dalda yürütülür. DoD sağlandığında ana dala (`main`) temiz merge edilir.
- **Görev Başına İzole Çalışma Alanı ($O(1)$ Token):** Her görev `.agents/tasks/{taskId}/` klasöründe kendi `spec.md` ve `arch.md` dosyalarını barındırır. Ajanlar yalnızca aktif görevin dosyalarını okur; geçmiş görevlerin okunmasıyla token israfı yapılması engellenir.

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

### Aşama 0: Ortam Başlatma ve Doğrulama Kapısı (Init Gate)
- Yeni bir projede `.agents/` devreye alındığında, kök dizin araçları (`Directory.Build.props`, `BannedSymbols.txt`, `.opengrep/`, `tests/ArchitectureTests/`, `tasks.json`) eksikse **hiçbir geliştirme görevi başlatılamaz**.
- Orkestratör derhal `.agents/INIT.md` prosedürünü işleterek (`bash .agents/init.sh`) kök araçları kurar ve `dotnet test` ile doğrular.

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

### Aşama 4: Kademeli Kalite ve Güvenlik Kapıları (Tiered Fast-Fail)
Kalite ve güvenlik motorları kaynakları ve tokenları korumak amacıyla 3 kademeli hızlı-başarısızlık (fail-fast) sırasıyla CLI üzerinden koşturulur (`squad-runner verify --tier <1|2|3>`):

1. **Kademe 1: Derleme, Linter & Hızlı Birim Testler (< 30 Saniye)**
   - `node .agents/runner/squad-runner.mjs verify --tier 1`
   - Derleme (`<TreatWarningsAsErrors>true` / `npm run build`), sıfır hata ve sıfır uyarı.
   - Hızlı birim testleri (mimari ve entegrasyon hariç). Hata varsa sonraki kademelere geçmeden derhal geliştiriciye döner.
2. **Kademe 2: Mimari Kurallar & SAST Taraması (1 - 2 Dakika)**
   - `node .agents/runner/squad-runner.mjs verify --tier 2`
   - ArchUnitNET / Dependency-Cruiser katman sınırları ve modülerlik denetimi.
   - Opengrep statik güvenlik taraması (`.agents/opengrep/` veya `.opengrep/`).
3. **Kademe 3: Scoped Stryker Mutasyon Testi & CodeQL Analizi (Pre-DoD)**
   - `node .agents/runner/squad-runner.mjs verify --tier 3`
   - Stryker mutasyon testi yalnızca `git diff` ile değişen dosyalarda çalıştırılır (`--since:main`); hayatta kalan mutant sayısı = 0 olmalıdır.
   - CodeQL 35 kural paketi (Design Patterns, SonarQube Clean Code, Senior Engineering) sıfır S1 ihlaliyle geçer.
   - OWASP ASVS v5.0, CSRF, XSS, Mass Assignment ve PII/KVKK sızıntı kontrolleri tamamlanır.

- **Ret Mekanizması & Devre Kesici:** Herhangi bir kademede hata alındığında `node .agents/runner/squad-runner.mjs reject --reason "<hata>"` komutuyla ret verilir. 3. rette devre kesici tetiklenir ve `rca-report.md` üretilir.

### Aşama 5: Kapanış ve Otomatik Merge (QA & Security ➔ PM)
- **Çıkış Kapısı (Definition of Done - DoD):**
  - Tüm 3 kademe (Tier 1, Tier 2, Tier 3) yeşil mi? (Evet)
  - Tüm Gherkin kabul kriterleri karşılandı mı? (Evet)
  - Kullanılan Tasarım Kalıpları `artifacts.designPatternsUsed` içine belgelendi mi? (Evet)
- **Otomatik Kapanış:** Şartlar sağlandığında `node .agents/runner/squad-runner.mjs complete` çalıştırılır. Görev `completed` yapılır (`dodMet: true`), feature branch ana dala (`main`) merge edilir ve silinir. Sıradaki göreve otomatik geçilir.

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
