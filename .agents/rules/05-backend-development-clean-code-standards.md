# Backend Geliştirme, Temiz Kod ve UDAP v2 Standartları

Bu anayasa, backend geliştiricilerinin (.NET 10 / C# 14) kod tabanında uygulayacağı **fonksiyon zanaatkarlığı**, **sınıf tasarımı**, **asenkron ve eşzamanlılık disiplini**, **veri erişimi (EF Core)**, **dayanıklı entegrasyon (Polly)**, **gözlemlenebilirlik (OpenTelemetry)** ve **UDAP v2 kural limitleri** standartlarını belirler.

---

## 📚 Dayandığı Literatür ve Standartlar
- **Clean Code: A Handbook of Agile Software Craftsmanship** (Robert C. Martin - Uncle Bob)
- **Design Patterns: Elements of Reusable Object-Oriented Software** (Gang of Four - GoF)
- **Concurrency in C# Cookbook (2nd Edition)** (Stephen Cleary)
- **Patterns of Enterprise Application Architecture** (Martin Fowler)
- **ISO/IEC 25010:2023** (Performance, Reliability, Maintainability, Analysability)
- **Microsoft Framework Design Guidelines (MSFDG)**
- **UDAP .NET Kural Kataloğu v2**

---

## ⚡ 1. Sözleşme Metrik Limitleri (`contract.yaml`)

| Metrik | İdeal Standart | Üst Sınır (İhlal) | İlgili Kural | Eylem |
|---|---|---|---|---|
| **Metot Satır Sayısı** | $\le 25$ satır | **Max 60 satır** | R-SOLID-010 | Aşıyorsa alt private fonksiyonlara parçala. |
| **Sınıf Satır Sayısı** | $\le 250$ satır | **Max 400 satır** | R-SOLID-010 | Aşıyorsa SRP doğrultusunda sınıflara böl. |
| **Metot Parametre Sayısı** | 0 - 2 parametre | **Max 3 (Triadic)** | R-SOLID-007 | 4+ parametre yasaktır; `Command` / `Record` nesnesi yap. |
| **Siklomatik Karmaşıklık** | $1 - 5$ | **Max 10** | R-SOLID-008 | Strategy deseni veya pattern matching ile dallanmayı azalt. |
| **Bilişsel Karmaşıklık** | $1 - 7$ | **Max 15** | R-SOLID-009 | İç içe blokları guard clause ile düzleştir. |
| **İç İçe Koşul Derinliği**| $\le 2$ | **Max 3** | R-SOLID-011 | Erken dönüş (early return) ile tersine çevir. |
| **Kalıtım Derinliği** | $\le 1$ | **Max 3** | R-SOLID-012 | Kalıtım yerine kompozisyon ve arayüz kullan. |
| **Arayüz Metot Sayısı** | $1 - 3$ metot | **Max 5 metot** | R-SOLID-006 | ISP ilkesine uyarak daha küçük arayüzlere böl. |
| **Constructor Bağımlılık** | $2 - 3$ servis | **Max 5 servis** | R-SOLID-007 | Facade deseni uygula veya sınıfı parçala. |

---

## ⚡ 2. Asenkron, Eşzamanlılık ve Kaynak Yönetimi (R-NET)

1. **R-NET-001 [S1]:** `.Result`, `.Wait()` veya `GetAwaiter().GetResult()` kesinlikle yasaktır. Uçtan uca `async/await` işletilir (CWE-833).
2. **R-NET-002 [S1]:** `async void` yalnızca UI/Event handler'larda kullanılabilir. Tüm asenkron metotlar `Task` veya `Task<T>` dönmelidir (CWE-248).
3. **R-NET-003 [S2]:** Kütüphane ve altyapı kodlarında `.ConfigureAwait(false)` kullanımı zorunludur.
4. **R-NET-004 [S1]:** Asenkron tüm I/O metot imzalarında `CancellationToken ct = default` bulunmalı ve alt çağrılara iletilmelidir (CWE-400).
5. **R-NET-005 [S3]:** `Task` dönen tüm metot adları `Async` soneki ile bitmelidir (MSFDG).
6. **R-NET-006 [S1]:** `lock` bloğu içinde `await` kullanılamaz; `SemaphoreSlim.WaitAsync` kullanılmalıdır.
7. **R-NET-007 [S1]:** `IDisposable` ve `IAsyncDisposable` nesneler `using var` veya `await using var` ile tüketilmelidir (CA2000, CWE-404).
8. **R-NET-008 [S1]:** `ValueTask` asla birden fazla kez await edilemez; gerekirse `AsTask()` çağrılmalıdır (CA2012).
9. **R-NET-009 [S1]:** Awaitsiz arka plan görevleri (`fire-and-forget`) yasaktır; tüm görevler await edilmeli veya kontrollü Channel/Worker üzerinden yürütülmelidir (CS4014).
10. **R-NET-070 [S1]:** `SemaphoreSlim` ve `Mutex` serbest bırakma çağrıları (`Release()`) daima `finally` bloğunda yapılmalıdır (CWE-667).
11. **R-NET-071 [S2]:** `Parallel.ForEach` içinde async lambda kullanılamaz; .NET 6+ `Parallel.ForEachAsync` kullanılmalıdır.
12. **R-NET-073 [S2]:** Sınırsız bellek büyümesini önlemek için kuyruklar daima sınırlandırılmış (bounded) olmalıdır (`Channel.CreateBounded<T>`).

---

## ⚡ 3. Hata Yönetimi ve Yapılandırılmış Loglama (R-SEC & R-NET)

1. **R-SEC-003 [S2]:** Ham `throw new Exception()` yasaktır. Ya spesifik bir domain istisnası ya da `Result.Failure(...)` deseni kullanılmalıdır.
2. **R-SEC-004 [S1]:** `OperationCanceledException` yutulamaz; akış derhal sonlandırılmalı veya hata yeniden fırlatılmalıdır.
3. **R-SEC-007 [S1]:** Boş `catch` bloğu kesinlikle yasaktır (CWE-390).
4. **R-SEC-008 [S1]:** İç sistem istisna mesajları istemciye ham dönemez (CWE-209). RFC 7807 ProblemDetails dönülmelidir.
5. **R-NET-080 [S2]:** `catch` yalnızca spesifik istisna tiplerini yakalamalıdır. Genel `catch (Exception ex)` yakalanıyorsa loglanıp orijinal `throw;` ile yeniden fırlatılmalıdır (`throw ex;` yasaktır).
6. **R-NET-082 [S1]:** Global Exception Handler middleware zorunludur; stack trace dışarı sızdırılamaz.
7. **R-NET-083 [S1]:** Güvenlik olayları (oturum açma başarısızlığı, yetki reddi, şüpheli işlem) açıkça audit loguna yazılmalıdır (ISO 21434, ASVS V16).
8. **R-NET-084 [S1]:** Log injection engellenmelidir; kullanıcı girdileri doğrudan log formatına gömülemez (CWE-117).
9. **R-NET-085 [S2]:** Loglamada string interpolasyonu (`logger.LogInformation($"User {id}")`) yasaktır. Yapılandırılmış şablon zorunludur: `logger.LogInformation("User {UserId}", id)`.

---

## ⚡ 4. Veri Erişimi ve EF Core Performans Kuralları (R-NET)

1. **R-NET-010 [S2]:** Salt okunur sorgularda `.AsNoTracking()` kullanımı zorunludur.
2. **R-NET-011 [S2]:** Derin `.Include()` zincirleri yerine doğrudan DTO'ya `.Select(dto => new ...)` projeksiyonu yapılmalıdır.
3. **R-NET-012 [S1]:** Lazy loading kapalı olmalıdır (`UseLazyLoadingProxies()` yasaktır). N+1 sorgu zincirleri engellenmelidir.
4. **R-NET-013 [S1]:** Ham SQL sorgularında (`FromSqlRaw`) string birleştirme yasaktır; parametreli `FromSqlInterpolated` veya `SqlParameter` zorunludur (CWE-89).
5. **R-NET-014 [S1]:** `DbContext` kesinlikle Singleton olarak kaydedilemez; Scoped olmalıdır (CWE-543).
6. **R-NET-016 [S2]:** Senkron `SaveChanges()` yasaktır; `await SaveChangesAsync(ct)` kullanılmalıdır.
7. **R-NET-017 [S1]:** Sayfalama (`.Skip().Take()`) yapılmadan sınırsız `ToListAsync()` çağrılması yasaktır (CWE-770).
8. **R-NET-018 [S2]:** Transaction sınırları açıkça Unit of Work veya MediatR pipeline'ında yönetilmeli; rastgele SaveChanges çağrıları yapılmamalıdır.
9. **R-NET-024 [S2]:** Eşzamanlı güncellenen entity'lerde `[Timestamp]` veya Concurrency Token kontrolü yapılmalıdır.
10. **R-NET-025 [S3]:** Toplu güncellemelerde `ExecuteUpdateAsync` ve `ExecuteDeleteAsync` tercih edilmelidir.

---

## ⚡ 5. Dayanıklı Entegrasyon ve Dış Çağrı Kuralları (R-NET)

1. **R-NET-022 [S1]:** `new HttpClient()` açılması yasaktır; daima `IHttpClientFactory` veya Typed Client kullanılmalıdır (CWE-404).
2. **R-NET-040 [S1]:** Tüm dış servis çağrılarında `X-Correlation-Id` başlığı taşınmalıdır (W3C traceparent).
3. **R-NET-041 [S1]:** Mesaj ve webhook işleyicilerinde idempotency anahtarı kontrolü zorunludur.
4. **R-NET-042 [S1]:** Dış çağrılarda Polly retry politikası bulunması zorunludur.
5. **R-NET-045 [S1]:** Timeout yapılandırması olmayan `HttpClient` çağrısı yasaktır (CWE-400).
6. **R-NET-046 [S2]:** Polly Circuit Breaker politikası tanımlı olmalıdır.
7. **R-NET-047 [S1]:** Retry politikası yalnızca idempotent (GET, PUT veya idempotency anahtarlı POST) operasyonlarda işletilebilir.
8. **R-NET-048 [S2]:** Retry bekleme sürelerinde üstel geri çekilme ve rastgele gecikme (exponential backoff + jitter) zorunludur.
9. **R-NET-049 [S1]:** Mesaj sözleşmelerinde `int Version` veya `string SchemaVersion` alanı bulunması zorunludur.
10. **R-NET-056 [S1]:** Outbox Pattern: Veritabanı transaction'ı içinde harici HTTP veya Service Bus çağrısı yapılamaz. Mesajlar önce veritabanı Outbox tablosuna yazılır.
11. **R-NET-058 [S1]:** Webhook endpoint'lerinde HMAC imza doğrulaması zorunludur (CWE-345).

---

## ⚡ 6. Gözlemlenebilirlik ve Telemetri (R-OBS)

1. **R-OBS-001 [S2]:** Her harici HTTP veya veritabanı entegrasyonu bir OpenTelemetry `Activity` (span) açmalıdır.
2. **R-OBS-002 [S1]:** Dağıtık izleme için W3C `traceparent` başlığı giden tüm isteklere enjekte edilmelidir.
3. **R-OBS-003 [S2]:** Uygulama `/health/live` (liveness) ve `/health/ready` (readiness) sağlık kontrolü endpoint'lerini barındırmalıdır.
4. **R-OBS-005 [S1]:** Finansal veya idari onay gibi kritik iş akışları için değişmez denetim kaydı (audit log) zorunludur.
5. **R-OBS-006 [S2]:** Metrik etiketlerinde yüksek kardinalite patlaması (GUID veya e-posta gibi benzersiz değerlerin etiket yapılması) yasaktır.
