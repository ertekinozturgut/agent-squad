# Standart İzlenebilirliği, Uyumluluk ve Denetim Kanıtları (UDAP v2)

Bu anayasa, Agent Squad tarafından geliştirilen yazılımların 11 uluslararası ve kurumsal standarda olan izlenebilirliğini (traceability), denetim hazırlığını ve kanıt toplama prosedürlerini belirler.

---

## 📚 1. 11 Referans Standart Haritası

Her mimari karar, geliştirme kuralı ve test senaryosu en az bir standarda bağlanmak zorundadır:

| Kısaltma | Standart Tam Adı | Kapsam ve Kullanım Amacı |
|---|---|---|
| **ASVS** | OWASP Application Security Verification Standard v5.0.0 (Mayıs 2025, 17 Bölüm, ~350 Gereksinim) | Güvenlik gereksinimlerinin birincil kaynağı (L1/L2/L3) |
| **CWE** | MITRE Common Weakness Enumeration | Zafiyet sınıfı kimliği ve kataloglama |
| **A10** | OWASP Top 10:2021 | Yönetici raporlaması ve web güvenlik riskleri |
| **API10** | OWASP API Security Top 10:2023 | Mikroservis ve entegrasyon API yüzeyi |
| **25010** | ISO/IEC 25010:2023 — 9 Karakteristik | Yazılım ürün kalitesi (Modularity, Performance, Reliability, Security, Analysability) |
| **SSDF** | NIST SP 800-218 Secure Software Development Framework | Güvenli yazılım yaşam döngüsü ve süreç kapıları |
| **SLSA** | SLSA v1.0 Build Levels (L2/L3) | Tedarik zinciri güvenliği ve build bütünlüğü |
| **21434** | ISO/SAE 21434 + UNECE R155 (CSMS) | Otomotiv siber güvenlik yönetim sistemi ve araç verisi koruması |
| **ASPICE** | Automotive SPICE v4.0 (SWE.1 - SWE.6) | Süreç izlenebilirliği (Gereksinim ➔ Tasarım ➔ Kod ➔ Test) |
| **KVKK** | 6698 Sayılı KVKK / GDPR | Kişisel veri işleme, aktarma ve saklama ilkeleri |
| **MSFDG** | Microsoft Framework Design Guidelines | C# ve .NET API tasarım hijyeni ve tip güvenliği |

---

## 2. ASVS 5.0 Kapsam Gerçeği (Reality Check)

> [!CAUTION]
> **"Yeşil Kapı = ASVS Uyumlu" Yanılgısını Önleme:**
> ASVS v5.0'ın yaklaşık **%55'i** statik kod analiz araçlarıyla (ArchUnit, Opengrep, CodeQL, Roslyn) otomatik doğrulanabilir.
> - **Kapsanan Alanlar:** Encoding (V1), API kuralları (V4), dosya işleme (V5), token parametreleri (V9), kriptografi (V11), güvenli iletişim (V12), temel veri akışı (V14), mimari sınırlar (V15), hata loglama (V16).
> - **Kapsanamayan Alanlar (Manuel İnceleme Şart):** İş mantığı doğrulaması (V2), dinamik oturum davranışı (V7), yetkilendirme kararlarının mantıksal doğruluğu (V8), OAuth akış tasarımı (V10).
> Statik kapıların yeşil olması projenin mimari ve sintaktik olarak korunduğunu gösterir; iş kuralı doğruluğu için QA Tester ve Solution Architect onayları zorunludur.

---

## 3. Süreç ve Denetim İzlenebilirliği (ASPICE & UNECE R155)

1. **İki Yönlü İzlenebilirlik (SWE.1 - SWE.6):**
   - Her kullanıcı hikayesi (`userStory`) $\rightarrow$ Gherkin kabul kriterine (`acceptanceCriteria`),
   - Her kabul kriteri $\rightarrow$ bir mimari karara (`architectureDecisions`),
   - Her mimari karar $\rightarrow$ ilgili C# koduna ve tasarım kalıbına (`designPatternsUsed`),
   - Her kod $\rightarrow$ en az bir otomatik xUnit testine ve mutasyon testine (`testsWritten`) bağlanmalıdır.

2. **Kural Doğrulama Fixture Kanıtı (UDAP 6. Yasa - R-TST-007):**
   - S1 seviyesindeki her kural için 3 durumlu test fixture'ı bulunmalıdır:
     - **Pozitif Fixture:** Kurala uygun temiz kodun geçtiğini kanıtlayan test.
     - **Negatif Fixture:** Kural ihlali yapıldığında analizörün hatayı kesinlikle yakaladığını kanıtlayan test.
     - **Boş Fixture:** Sınır durumunda yanlış pozitif (false positive) üretilmediğini kanıtlayan test.

3. **Merkezi İzlenebilirlik Raporları:**
   - Proje kökündeki hazır ve güncel denetim belgeleri:
     - `docs/TRACEABILITY_MATRIX.md`
     - `docs/traceability_matrix.csv`
     bağımsız ASPICE, UNECE R155 ve ASVS denetimlerinde doğrudan teknik kanıt olarak sunulur.
