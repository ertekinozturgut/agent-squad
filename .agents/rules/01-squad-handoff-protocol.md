# Squad El Sıkışma (Handoff) ve Görev Döngü Protokolü

Bu kural, ekibin (Squad) görev akışını, roller arası el sıkışma standartlarını ve görev döngü (loop) mekanizmasını düzenler.

## 📚 Dayandığı Literatür ve Standartlar
- **PMBOK Guide & Agile Practice Guide** (Project Management Institute - PMI)
- **The Scrum Guide** (Ken Schwaber & Jeff Sutherland)
- **Accelerate: Building and Scaling High Performing Technology Organizations** (Nicole Forsgren, Jez Humble, Gene Kim)

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

## 2. Roller Arası Handoff (El Sıkışma) Zinciri

Her görev istisnasız aşağıdaki 5 aşamalı zinciri tamamlamak zorundadır:

```text
[1. PM] ➔ [2. İş Analisti] ➔ [3. UI/UX & Mimari] ➔ [4. Backend & Razor Dev] ➔ [5. QA & Security] ➔ [PM: Kapanış]
                                    ▲                                               │
                                    └────────────── (Red / Revizyon) ───────────────┘
```

### Aşama 1: Kapsam & Analiz (PM ➔ İş Analisti)
- **Girdi:** Ham kullanıcı isteği veya `tasks.json` görevi.
- **Çıktı:** INVEST formatında Kullanıcı Hikayesi + Gherkin (`Given-When-Then`) kabul kriterleri + Hata senaryoları.

### Aşama 2: Tasarım & Mimari Şartname (Analist ➔ UI/UX & Mimar)
- **UI/UX Tasarımcısı:** Bootstrap 5.3 grid yapısı, bileşen durumları (hover, focus, disabled, loading) ve form UX şartnamesini hazırlar.
- **Sistem Mimarı:** Domain modeli, View'a gidecek `ViewModel` kontratı, uygulanacak **Kurumsal Tasarım Kalıpları (Design Patterns)** ve Servis arayüzünü tanımlar.
- **Kapı Kuralı (Definition of Ready - DoR):** Analiz, UX şartnamesi, mimari model ve tasarım kalıbı sözleşmesi hazır olmadan tek bir satır kod yazılamaz (`dorMet: true`).

### Aşama 3: Geliştirme (Mimar & UX ➔ Backend & Razor)
- **Backend Engineer:** `05-backend-development-clean-code-standards.md` kurallarına (fonksiyon yönetimi, class kapsamı, OOP, guard clauses, max 25 satır, belirlenen tasarım kalıpları) tam uyumlu olarak Servis, Entity Framework Core ve Controller Action metodlarını kodlar.
- **Razor Specialist:** Mimarın ViewModel'i ve UX şartnamesine birebir sadık kalarak `.cshtml` sayfasını Tag Helper'lar ve Bootstrap ile giydirir.

### Aşama 4: Kalite ve Güvenlik Kapısı (Dev ➔ QA & Security)
- **QA Tester:** Kabul kriterlerini xUnit ve `WebApplicationFactory` entegrasyon testlerine dönüştürür; sınır değer ve son kullanıcı testlerini yapar.
- **Security Reviewer:** OWASP, CSRF (`[ValidateAntiForgeryToken]`), XSS, Mass Assignment, tasarım kalıbı güvenliği ve kod kalitesi (SonarAnalyzer) denetimlerini yapar.
- **Ret Mekanizması:** Tek bir test hatası veya güvenlik/kod kokusu ihlalinde görev `changes_requested` durumuna alınır ve revizyon notlarıyla geliştiriciye iade edilir.

### Aşama 5: Kapanış (QA & Security ➔ PM)
- **Kapı Kuralı (Definition of Done - DoD):**
  - Tüm kabul kriterleri karşılandı mı? (Evet)
  - `dotnet build` 0 uyarı, 0 hata ile derlendi mi? (Evet)
  - Tüm xUnit ve entegrasyon testleri yeşil mi? (Evet)
  - Güvenlik kontrol listesi ve Semgrep/SonarAnalyzer onaylandı mı? (Evet)
  - Kullanılan Tasarım Kalıpları (Design Patterns) `artifacts.designPatternsUsed` içine belgelendi mi? (Evet)
- Şartlar sağlandığında görev `completed` yapılır (`dodMet: true`) ve sıradaki göreve geçilir.
