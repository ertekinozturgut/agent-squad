# Web Güvenliği, Kişisel Veri Koruma ve Kalite Korkulukları (UDAP v2)

Bu anayasa, .NET 10 web uygulamalarının siber güvenlik açıklarına, kişisel veri (KVKK / GDPR / 21434) ihlallerine ve sistemik kalite tuzaklarına karşı sıfır toleransla korunmasını güvence altına alır.

## 📚 Dayandığı Standartlar
- **OWASP Application Security Verification Standard (ASVS v5.0.0 - Mayıs 2025, 17 Bölüm, ~350 Gereksinim, L1/L2/L3)**
- **MITRE Common Weakness Enumeration (CWE Top 25)**
- **OWASP Top 10:2021 & OWASP API Security Top 10:2023**
- **6698 Sayılı KVKK & GDPR (Genel Veri Koruma Tüzüğü)**
- **ISO/SAE 21434 & UNECE R155 (CSMS - Otomotiv Siber Güvenliği)**
- **NIST SP 800-218 (SSDF) & SLSA v1.0**

> [!IMPORTANT]
> **Kapsam Gerçeği (Reality Check):**
> ASVS v5.0 gereksinimlerinin yaklaşık **%55'i** statik analiz araçlarıyla (ArchUnit, Opengrep, CodeQL, Roslyn) otomatik doğrulanabilir. Kalan kısım (iş mantığı bütünlüğü, oturum davranışı, yetkilendirme kararlarının doğruluğu) Solution Architect tasarım denetimi ve QA Tester dinamik testlerini gerektirir.

---

## 1. Kişisel Veri ve Gizlilik Koruma Korkulukları (KVKK / GDPR / R-PII / R-AUT)

Sistemde kişisel veri (PII) olarak sınıflandırılan alanlar:
`["Tckn", "Vkn", "Email", "Phone", "PlateNumber", "Vin", "ChassisNo", "EngineNo", "DriverLicenseNo", "Iban", "Address", "BirthDate"]`

1. **R-PII-001 [S1]:** PII alanı log çağrılarına (`ILogger.Log`, `Console.Write`) parametre olarak **kesinlikle geçirilemez**. Maskeleme veya hash zorunludur (CWE-532, KVKK m.12).
2. **R-PII-002 [S1]:** PII alanları `Exception` mesajlarına konulamaz (CWE-209). Hata mesajlarında yalnızca genel hata kodları ve anonim GUID anahtarlar kullanılabilir.
3. **R-PII-003 [S1]:** PII verisi barındıran tüm model ve entity sınıfları veya property'leri `[SensitiveData]` özniteliği ile işaretlenmek zorundadır (KVKK m.6).
4. **R-PII-004 [S1]:** PII verileri üçüncü taraf istemci payload'larına maskelenmeden veya açık rıza/yasal dayanak olmadan gönderilemez (KVKK m.8/9).
5. **R-PII-005 [S2]:** PII alanları önbellek (Redis / IMemoryCache) anahtarı olarak kullanılamaz (CWE-524).
6. **R-PII-006 [S1]:** PII verileri URL query string (`?tckn=...&email=...`) içinde taşınamaz (CWE-598). Veriler POST gövdesinde şifreli taşınmalıdır.
7. **R-PII-007 [Process]:** PII içeren tablolar için veri saklama süresi ve periyodik imha/anonimleştirme politikası tanımlı olmalıdır (KVKK m.7).
8. **R-PII-008 [S2]:** `ToString()` metotları PII alanlarını düz metin olarak sızdıramaz.
9. **R-PII-009 [S1]:** Test fixture'larında gerçek kişisel veriler kullanılamaz; daima sentetik test verisi (Bogus) üretilmelidir.
10. **R-PII-010 [S1]:** Telemetri ve analitik olaylarına (Application Insights vb.) PII eklenemez.
11. **R-AUT-001 [S1]:** Araç tanımlayıcıları (VIN, şasi no, motor no, araç plakası) doğrudan araç sahibine bağlanabildiğinden PII sınıfında işlenir ve korunur (ISO 21434).

---

## 2. Girdi Doğrulama ve Enjeksiyon Savunması (R-INJ)

1. **R-INJ-001 [S1]:** EF Core veya Dapper sorgularında string birleştirme (`$""` veya `string.Format`) kesinlikle yasaktır. Daima parametreli sorgu veya LINQ kullanılmalıdır (CWE-89, A03:2021).
2. **R-INJ-002 [S1]:** İşletim sistemi komut çalıştırma (`Process.Start`) kullanıcı girdisiyle beslenemez (CWE-78 Command Injection).
3. **R-INJ-003 [S1]:** Dosya yolları kullanıcı girdisinden doğrudan türetilemez; `Path.GetFileName` ve temel dizin doğrulama zorunludur (CWE-22 Path Traversal).
4. **R-INJ-004 [S1]:** Dış URL adresleri kullanıcı girdisinden türetilemez; katı allowlist zorunludur (CWE-918 SSRF).
5. **R-INJ-005 [S1]:** XML okuyucularda DTD parsing açık bırakılamaz (`DtdProcessing.Prohibit` zorunludur) (CWE-611 XXE).
6. **R-INJ-006 [S1]:** JSON deserialization işlemlerinde `TypeNameHandling.All` veya `Auto` kullanımı kesinlikle yasaktır (CWE-502 Deserialization RCE).
7. **R-INJ-007 [S1]:** LDAP ve XPath sorgularında kullanıcı girdileri kaçış süzgecinden geçirilmelidir (CWE-90).
8. **R-INJ-008 [S2]:** Dinamik regex ifadeleri kullanıcı girdisiyle derlenemez; Regex timeout tanımlanmalıdır (CWE-1333 ReDoS).
9. **R-INJ-009 [S2]:** Tüm public API endpoint modelleri `[Required]`, `[StringLength]` veya FluentValidation kuralları taşımalıdır.

---

## 3. Kriptografi ve Güvenli İletişim (R-CRY)

1. **R-CRY-001 [S1]:** MD5, SHA1, DES, RC2 ve TripleDES algoritmaları kesinlikle yasaktır. SHA256 veya AES-GCM kullanılmalıdır (CA5350/5351, CWE-327).
2. **R-CRY-002 [S1]:** Şifreleme işlemlerinde ECB modu yasaktır; CBC veya GCM modu zorunludur (CA5358).
3. **R-CRY-003 [S1]:** Kriptografik amaçla `System.Random` kullanılamaz; `RandomNumberGenerator` zorunludur (CA5394, CWE-338).
4. **R-CRY-004 [S1]:** Parola saklamada ham SHA yasaktır; Argon2id, PBKDF2 veya bcrypt kullanılmalıdır (CWE-916).
5. **R-CRY-005 [S1]:** SSL/TLS sertifika doğrulaması bypass edilemez (`ServerCertificateCustomValidationCallback = true` yasaktır) (CA5359, CWE-295).
6. **R-CRY-006 [S1]:** Minimum TLS sürümü $\ge 1.2$ olarak sabitlenmelidir (CWE-326, ASVS V12).
7. **R-CRY-007 [S1]:** Kriptografik IV (Initialization Vector) veya nonce sabit olamaz; her işlemde rastgele üretilmelidir (CWE-329).
8. **R-CRY-008 [S2]:** Kriptografik anahtarlar bellekte düz metin `string` olarak tutulamaz; `byte[]` ve `CryptographicOperations.ZeroMemory` kullanılmalıdır.
9. **R-CRY-009 [S1]:** Kaynak kodda `http://` şemalı URL sabitleri yasaktır (localhost hariç); daima `https://` kullanılmalıdır (CWE-319).

---

## 4. Kimlik Doğrulama, Yetkilendirme ve Token Korkulukları (R-AUTH)

1. **R-AUTH-001 [S1]:** Her controller ve action metodu açıkça `[Authorize]` veya gerekçeli `[AllowAnonymous]` taşımak zorundadır (ASVS V8, CWE-862, BOLA).
2. **R-AUTH-002 [S2]:** `[AllowAnonymous]` kullanılan her endpoint'in üzerinde iş gerekçesini açıklayan bir yorum bulunmalıdır.
3. **R-AUTH-003 [Process/S1]:** URL'den gelen kayıt ID'si oturumdaki `UserId` veya `TenantId` ile doğrulanmadan veri döndürülemez/değiştirilemez (CWE-639 IDOR).
4. **R-AUTH-004 [S1]:** JWT token doğrulamasında `ValidateIssuer`, `ValidateAudience` ve `ValidateLifetime` bayrakları açıkça `true` olmalıdır (CWE-347).
5. **R-AUTH-005 [S1]:** JWT yapılandırmasında `RequireHttpsMetadata = false` yapılması kesinlikle yasaktır (CWE-319).
6. **R-AUTH-006 [S1]:** Simetrik JWT anahtarları kod içine gömülemez; Azure KeyVault veya Secret Manager'dan okunmalıdır (CWE-798).
7. **R-AUTH-007 [S2]:** Rol isimleri magic string olamaz; `Roles.Admin` gibi strongly-typed sabitlerden gelmelidir.
8. **R-AUTH-009 [Roslyn/S1]:** Durum değiştiren tüm HTTP POST/PUT/DELETE eylemlerinde Antiforgery token (`[ValidateAntiForgeryToken]`) zorunludur (CWE-352).

---

## 5. Konfigürasyon, Sırlar ve Üretim Hijyeni (R-CFG & R-NET)

1. **R-NET-032 [Process/S1]:** `appsettings.json` veya git deposuna girecek hiçbir dosyada parola, token veya veritabanı şifresi yer alamaz (Gitleaks ile taranır).
2. **R-CFG-001 [S2]:** Konfigürasyon sınıfları uygulama başlangıcında `ValidateOnStart()` ile doğrulanmalıdır.
3. **R-CFG-002 [S1]:** `app.UseDeveloperExceptionPage()` üretim ortamında kesinlikle etkinleştirilemez (CWE-489).
4. **R-CFG-003 [S1]:** CORS yapılandırmasında `AllowAnyOrigin()` ile kimlik bilgileri (`AllowCredentials()`) kombinasyonu kesinlikle yasaktır (CWE-942).
5. **R-CFG-004 [S2]:** HTTP yanıtlarında güvenlik başlıkları (`HSTS`, `CSP`, `X-Content-Type-Options: nosniff`, `X-Frame-Options`) zorunludur.
6. **R-CFG-005 [S1]:** Üretimde detaylı stack trace gösteren hata sayfaları kapalı olmalı, RFC 7807 ProblemDetails dönülmelidir (CWE-209).
