# Mimari Değişmezler ve Clean Architecture Standartları

Bu kural, .NET 10 projesinde **Clean Architecture (Temiz Mimari)**, **Domain-Driven Design (DDD)** ve **SOLID** ilkelerinin tavizsiz uygulanmasını güvence altına alır. Tüm geliştirmeler bu anayasaya uymak zorundadır.

## 📚 Dayandığı Literatür ve Standartlar
- **Clean Architecture: A Craftsman's Guide to Software Structure and Design** (Robert C. Martin - Uncle Bob)
- **Domain-Driven Design: Tackling Complexity in the Heart of Software** (Eric Evans)
- **Patterns of Enterprise Application Architecture** (Martin Fowler)
- **Microsoft .NET Architecture Guides (eShopOnWeb Reference Architecture)**
- **Refactoring: Improving the Design of Existing Code** (Martin Fowler)

---

## 1. Katman Mimarisi ve İçe Doğru Bağımlılık Kuralı (The Dependency Rule)

Bağımlılıklar daima içe doğru (Domain/Core yönüne) akar. İç katmanlar dış dünyayı kesinlikle tanımaz:

```
[ Web (Presentation / Razor) ] 
       │ 
       ▼
[ Infrastructure (EF Core / External Services) ] 
       │ 
       ▼
[ Core (Domain / Entities / Interfaces / Business Logic) ]
```

### Katman Sorumluluk Sınırları:
1. **Core (Domain Katmanı):**
   - Sistemin kalbidir. Hiçbir dış kütüphaneye (`Microsoft.EntityFrameworkCore`, `Microsoft.AspNetCore.*`, `Newtonsoft.Json`) bağımlı olamaz.
   - Yalnızca saf iş modellerini (Entities), değer nesnelerini (Value Objects), domain istisnalarını ve arayüzleri (`IRepository`, `IService`) barındırır.
2. **Infrastructure (Altyapı Katmanı):**
   - Core katmanında tanımlanan arayüzlerin somut uygulamalarını (`DbContext`, Repository implementasyonları, e-posta/SMS servisleri) içerir.
3. **Web (Sunum / MVC Katmanı):**
   - Sadece HTTP isteklerini karşılama, yönlendirme (Routing), `ViewModel` doğrulama ve Razor `.cshtml` çıktısı üretme işini yapar.

---

## 2. İhlal Edilemez 8 Clean Architecture Kuralı

### 🏛️ Kural 1: Entity Asla View Katmanına Sızamaz (Zorunlu ViewModel Sınırı)
- Veritabanı Domain Entity'si doğrudan Controller'dan View'a gönderilemez ve View formundan post edilemez.
- Her ekran için yalnızca o ekranın ihtiyaç duyduğu alanları taşıyan bir **`ViewModel`** (veya `DTO`) tanımlanmalıdır.
- *Gerekçe:* Mass-assignment güvenlik açıklarını, döngüsel JSON serileştirme hatalarını ve arayüzün veri tabanına sıkı sıkıya bağlanmasını (tight coupling) engellemek.

### 🏛️ Kural 2: İnce Controller (Skinny Controllers) Zorunluluğu
- Controller'lar birer orkestra şefidir; enstrüman çalmazlar. Sadece HTTP isteğini karşılar, servise devreder ve sonucu View/Redirect yanıtına dönüştürür.
- **Kısıtlar:**
  - Bir Action metodu maksimum **15-20 satır** olabilir.
  - Action içinde `if-else` iş mantığı zincirleri, döngüler (`for`/`foreach`) veya hesaplama kodları **kesinlikle bulunamaz**.
  - Controller içinde doğrudan `_dbContext` enjekte edilemez ve çağrılamaz.

### 🏛️ Kural 3: İş Kurallarında Exception Yasaktır (Result Pattern Zorunluluğu)
- Beklenen iş kuralı durumları (Örn: *"Kullanıcı bulunamadı"*, *"Bakiye yetersiz"*, *"Bu e-posta zaten kullanımda"*) için `throw new Exception()` fırlatılamaz.
- Tüm servisler `Result` veya `Result<T>` deseniyle dönmelidir.
- *Gerekçe:* Exception fırlatmak CPU maliyetlidir, testleri zorlaştırır ve akış kontrolünü bozar. Exception sadece beklenmeyen sistemik çökmeler içindir.

### 🏛️ Kural 4: Zengin Domain Modeli (Rich Domain Model vs. Anemic Anti-Pattern)
- Entity'ler sadece `public get; set;` taşıyan içi boş veri torbaları olmamalıdır.
- Domain Entity'si kendi iç durumunun geçerliliğini korumalıdır. Durum değişiklikleri açık isimli metotlarla yapılmalıdır (Örn: `user.SetPassword(...)`, `user.Deactivate()`).

### 🏛️ Kural 5: Veri Tabanı Performans ve İzolasyon Standartları
- **Salt Okunur Sorgular:** Ekranda sadece gösterilecek veriler için `.AsNoTracking()` kullanımı zorunludur.
- **Zorunlu Projeksiyon (Select):** Tablodan tüm kolonları çekmek yerine sadece ViewModel'e lazım olan alanlar `.Select()` ile çekilmelidir.
- **Zorunlu Sayfalama (Pagination):** Hiçbir liste sınırsız çekilemez; mutlaka `Skip()` ve `Take()` ile sınırlandırılmalıdır.
- **N+1 Sorgu Yasağı:** Döngü içinde veritabanı sorgusu atılamaz.

### 🏛️ Kural 6: SOLID Prensipleri ve Bağımlılık Enjeksiyonu
- **Single Responsibility (SRP):** Her sınıfın yalnızca tek bir değişim sebebi olmalıdır.
- **Interface Segregation (ISP):** 30 metotluk dev arayüzler yasaktır; amaca yönelik küçük arayüzler kurulmalıdır.
- **Açık Bağımlılık (Explicit Dependencies):** Bağımlılıklar C# 14 Primary Constructor ile enjekte edilmeli, Service Locator anti-pattern kullanılmamalıdır.

### 🏛️ Kural 7: Tip Güvenli Yapılandırma (Strongly-Typed Options Pattern)
- Kod içinde `_configuration["MySetting:Key"]` gibi serbest metin (magic string) gezdirilemez.
- Tüm ayarlar bir sınıf ile eşleştirilip `IOptions<T>` veya `IOptionsSnapshot<T>` üzerinden inject edilmelidir.

### 🏛️ Kural 8: Uçtan Uca Asenkron (Async-First)
- Tüm I/O ve veritabanı işlemleri `async Task` olmalı ve `CancellationToken` zincir boyunca taşınmalıdır.
- `.Result` veya `.Wait()` ile senkron bloklama yapmak kesinlikle yasaktır.

### 🏛️ Kural 9: Temiz Kod ve Geliştirme Standartları (Clean Code & Craftsmanship)
- Tüm fonksiyonlar maksimum **15-25 satır**, parametre sayısı en fazla **3** ve tek sorumluluklu olmalıdır.
- Sınıflar maksimum **200-300 satır** olmalı; God Object, Helper ve Manager torba sınıfları yasaktır.
- Kapsülleme (Encapsulation), Demeter Yasası, CQS ve Guard Clauses tavizsiz işletilmelidir.
- Ayrıntılı kural seti için: [05-backend-development-clean-code-standards.md](file:///C:/Users/Ertekin/.gemini/antigravity-ide/scratch/DotNet10WebApp/.agents/rules/05-backend-development-clean-code-standards.md).
