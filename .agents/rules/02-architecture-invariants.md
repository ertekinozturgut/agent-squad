# Mimari Değişmezler, Modülerlik ve Clean Architecture Standartları (UDAP v2)

Bu anayasa, .NET 10 / C# 14 projelerinde **Clean Architecture**, **Domain-Driven Design (DDD)**, **Modüler Monolit Sınırları**, **SOLID** ilkeleri, **ISO/IEC 25010:2023 Kalite Karakteristikleri** ve **UDAP v2 Mimari Kuralları (R-ARCH & R-MOD)** standartlarının tavizsiz uygulanmasını güvence altına alır.

## 📚 Dayandığı Literatür ve Standartlar
- **Clean Architecture: A Craftsman's Guide to Software Structure and Design** (Robert C. Martin - Uncle Bob)
- **Domain-Driven Design: Tackling Complexity in the Heart of Software** (Eric Evans)
- **Design Patterns: Elements of Reusable Object-Oriented Software** (Gang of Four - GoF)
- **ISO/IEC 25010:2023 Systems and software Quality Requirements and Evaluation (SQuaRE)** — Modularity, Maintainability, Analysability, Replaceability
- **Microsoft Framework Design Guidelines (MSFDG)**
- **UDAP .NET Kural Kataloğu v2 (R-ARCH-001..010, R-MOD-001..004)**

---

## 1. Katman Mimarisi ve Sözleşme Bağımlılık Matrisi (`contract.yaml`)

Bağımlılıklar daima içe doğru (Domain/Core yönüne) akar. Dış katman detayları iç dünyayı kesinlikle kirletemez:

```text
┌─────────────────────────────────────────────────────────────┐
│                    Api Katmanı (L1)                         │
│       Endpoints, Controllers, Filters, ViewModels           │
│   (Yalnızca Application ve Domain sözleşmelerine bağımlı)   │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│               Application Katmanı (L2)                      │
│     Use Cases, Commands, Queries, Handlers, DTOs, Enums     │
│             (Yalnızca Domain katmanına bağımlı)             │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                  Domain Katmanı (L3)                        │
│    Entities, Value Objects, Domain Events, Pure Interfaces   │
│             (SIFIR DIŞ BAĞIMLILIK - SAF C#)                 │
└─────────────────────────────────────────────────────────────┘
                               ▲
                               │ (Implemente eder)
┌──────────────────────────────┴──────────────────────────────┐
│              Infrastructure Katmanı (L2)                    │
│   EF Core, DbContext, Polly Adapters, MassTransit, Clients  │
│        (Application ve Domain arayüzlerini somutlaştırır)   │
└─────────────────────────────────────────────────────────────┘
```

### 🏛️ Zorunlu Katman Kuralları (R-ARCH):
1. **R-ARCH-001 [S1]:** Domain dış katmanlara kesinlikle bağımlı olamaz (`may_depend_on: []`).
2. **R-ARCH-002 [S1]:** Application katmanı yalnızca Domain'e bağımlı olabilir. Infrastructure veya Api katmanlarına doğrudan bağımlılık yasaktır.
3. **R-ARCH-003 [S1]:** Domain projesinde hiçbir framework veya altyapı tipi bulunamaz (`Microsoft.EntityFrameworkCore`, `Microsoft.AspNetCore`, `System.Data`, `Azure.Messaging` vb. yasaktır).
4. **R-ARCH-004 [S1]:** Api katmanı Infrastructure somut sınıflarına doğrudan erişemez. Katmanlar arası geçiş arayüzler ve Application servisleri üzerinden yapılır.
5. **R-ARCH-005 [S1]:** Domain entity tipleri Api imzalarında (Action parametreleri veya dönüş tipleri) asla görünemez (CWE-915 Mass Assignment koruması).
6. **R-ARCH-006 [S2]:** Katmanlar arası geçişler daima arayüzler (interfaces) üzerinden yürütülmelidir.
7. **R-ARCH-007 [S1]:** Döngüsel namespace bağımlılığı kesinlikle yasaktır.
8. **R-ARCH-008 [S2]:** Public API yüzeyi izlenmeli, kontrolsüz tip genişlemesi önlenmelidir.
9. **R-ARCH-009 [S3]:** Tipler varsayılan olarak `internal` olmalıdır; `public` erişim açık gerekçe ister.
10. **R-ARCH-010 [Process]:** Her assembly tek bir sorumluluk taşımalı ve kökünde bir marker tip (`IAssemblyMarker`) bulundurmalıdır.

---

## 2. Modülerlik ve Dikey Dilim İzolasyonu (R-MOD)

Modüler monolit yapısında özellik paketleri (feature slices) izole sınırlarla korunur:

1. **R-MOD-001 [S1]:** Feature $\rightarrow$ Feature doğrudan bağımlılığı kesinlikle yasaktır (`Orders` feature'ı doğrudan `Customers` feature'ına referans veremez).
2. **R-MOD-003 [Process]:** Paylaşılan tüm kodlar yalnızca `Company.SharedKernel` veya `Company.Common` altında yaşayabilir.
3. **R-MOD-004 [S1]:** `SharedKernel` hiçbir işlevsel feature'a bağımlı olamaz (`SharedKernel` tamamen bağımsızdır).

---

## 3. Domain Saflığı, Determinizm ve Zaman Kuralları

Domain katmanı dış dünya yan etkilerinden (I/O, ağ, saat, işlemci durumu) tamamen arındırılmış olmalıdır:

1. **R-NET-050 [S1]:** Kod tabanında `DateTime.Now` ve `DateTime.UtcNow` kullanımı kesinlikle yasaktır. Zamana duyarlı tüm işlemler için .NET 8+ **`TimeProvider`** soyutlaması enjekte edilmelidir (`timeProvider.GetUtcNow()`).
2. **R-NET-052 [S2]:** Domain içinde doğrudan `Guid.NewGuid()` çağrısı yapılamaz; test edilebilirliği ve determinizmi sağlamak için ID'ler parametre olarak verilmeli veya `IIdGenerator` üzerinden sağlanmalıdır.
3. **R-NET-053 [S2]:** Domain içinde `Environment.MachineName`, `Process.GetCurrentProcess().Id` gibi donanım/ortam değişkenleri kullanılamaz.
4. **R-NET-054 [S1]:** Domain katmanı içinde dosya sistemi (`System.IO`) veya ağ (`System.Net.Http`) erişimi kesinlikle yasaktır. Tüm I/O işlemleri Infrastructure katmanındaki adapter'lar aracılığıyla yürütülür.
5. **R-NET-059 [S2]:** Zaman dilimi belirsizliğini önlemek için `DateTime` yerine daima **`DateTimeOffset`** tercih edilmelidir.

---

## 4. İhlal Edilemez 5 Temel Tasarım ve Sözleşme Kuralı

### 🏛️ Kural 1: ViewModel ve Result Pattern Zorunluluğu
- Form ve API uçlarında doğrudan veritabanı Entity'si bağlanamaz. Her uç için bağımsız `ViewModel` veya `DTO` kullanılır.
- Beklenen iş kuralı durumları için `Exception` fırlatmak yasaktır; tüm iş metotları **`Result`** veya **`Result<T>`** deseniyle dönmelidir.

### 🏛️ Kural 2: İnce Controller (Skinny Controllers)
- Controller Action metotları en fazla **15-20 satır** olabilir.
- Action içinde veritabanı sorgusu, `_dbContext` çağrısı veya karmaşık iş mantığı bulunamaz; istek Application katmanına delege edilir.

### 🏛️ Kural 3: Tip Güvenli Yapılandırma (Strongly-Typed Options)
- Kod içinde `_config["MyKey"]` şeklinde serbest metin (magic string) gezdirilemez.
- `IOptions<T>` deseni ve `ValidateOnStart()` kuralı zorunludur (R-CFG-001).

### 🏛️ Kural 4: Zengin Domain Modeli (Rich Domain Model)
- Anemic Entity (yalnızca boş get/set taşıyan varlıklar) yasaktır.
- İş kuralları entity metotlarıyla korunmalı (`order.Approve()`, `account.Withdraw(amount)`); property setter'ları `private set` veya `init` olmalıdır.

### 🏛️ Kural 5: Kurumsal Tasarım Kalıpları (Design Patterns)
- **Strategy:** Enum ve switch/if dallanmalarında açık strateji sınıfları (`IDiscountStrategy`).
- **Adapter:** Üçüncü taraf dış servisler ve API'lerin Infrastructure katmanında izole edilmesi.
- **Decorator:** Caching, audit, logging gibi kesişen endişelerin ana koda dokunmadan sarmalanması.
- **Outbox:** Dış mesajlaşma çağrıları ile veritabanı yazımının aynı transaction içinde yapılmaması (R-NET-056).
