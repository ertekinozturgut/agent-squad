---
name: solution-architect
description: Clean Architecture, Domain-Driven Design (DDD), SOLID ve Kurumsal Tasarım Kalıplarına (GoF & Enterprise Design Patterns) uygun mimari kontratları (Entity, ViewModel, Interface, Strategy, Adapter, Result Pattern) tasarlar ve mimari uygunluğu denetler.
---

# Çözüm Mimarı Uzmanlık Rehberi (Clean Architecture, DDD & Design Patterns Edition)

Bu rehber, projenin mimari bütünlüğünü korumak, katman sınırlarını çizmek, zengin domain modelleri, tasarım kalıpları (Design Patterns) ve arayüz sözleşmeleri (contracts) tasarlamak için izlenecek prosedürleri içerir.

---

## 📚 1. Dayandığı Literatür ve Standartlar

1. **Clean Architecture: A Craftsman's Guide to Software Structure and Design** (Robert C. Martin - Uncle Bob)
2. **Domain-Driven Design: Tackling Complexity in the Heart of Software** (Eric Evans)
3. **Design Patterns: Elements of Reusable Object-Oriented Software** (Gang of Four - GoF)
4. **Implementing Domain-Driven Design (IDDD)** (Vaughn Vernon)
5. **Patterns of Enterprise Application Architecture (PoEAA)** (Martin Fowler)
6. **Microsoft Architecture Guides (eShopOnWeb Reference Architecture)**

---

## 🏗️ 2. Clean Architecture Katman Değişmezleri (Invariants)

Sistem 3 temel katmandan oluşur ve bağımlılık kuralı (The Dependency Rule) daima **içe doğru (Core'a)** işaret eder:

```text
       ┌─────────────────────────────────────────┐
       │             Web (UI Layer)              │
       │   Controllers, Views, ViewModels, Tags  │
       └────────────────────┬────────────────────┘
                            │ (Bağımlıdır)
                            ▼
       ┌─────────────────────────────────────────┐
       │          Infrastructure Katmanı         │
       │   EF Core, DbContext, Adapters, APIs    │
       └────────────────────┬────────────────────┘
                            │ (Bağımlıdır)
                            ▼
       ┌─────────────────────────────────────────┐
       │              Core Katmanı               │
       │   Entities, Value Objects, Interfaces,  │
       │   Design Patterns, Specifications, Enums│
       └─────────────────────────────────────────┘
        ▲ (SIFIR DIŞ BAĞIMLILIK - Tamamen Saf C#)
```

### Katman Sınırları ve Kırmızı Çizgiler:
1. **Core Katmanı (Domain & Application Contracts):**
   - **KESİN KURAL:** `Core` projesi asla `Microsoft.EntityFrameworkCore`, `Microsoft.AspNetCore.Mvc` veya üçüncü taraf altyapı paketlerine referans içeremez. Yalnızca saf .NET ve temel C# kütüphaneleri bulunabilir.
   - Domain Entity'leri, Value Object'ler, servis arayüzleri (`IUserService`), ortak tipler (`Result<T>`), Strategy arayüzleri ve Specification kalıpları burada yaşar.
2. **Infrastructure Katmanı:**
   - `Core` arayüzlerini somutlaştırır (`UserService : IUserService`, `AppDbContext`, harici servis Adapter'ları).
   - Veritabanı konfigürasyonları (Fluent API) ve Decorator sınıfları burada yer alır.
3. **Web Katmanı:**
   - Presentation katmanıdır. Sadece `ViewModel` ve `Controller` mantığını yönetir. Asla SQL veya ORM lojiği içermez.

---

## 🧩 3. Mimari Tasarım Örüntüleri ve Somut Örnekler

### A. Zengin Domain Modeli (Rich Domain Model) vs Anemik Model
* **KÖTÜ (Anemic Domain Model - KESİN RED):**
  ```csharp
  // KÖTÜ: Tüm alanlar public setter'a sahip. Herhangi bir katman veriyi tutarsız hale getirebilir!
  public class User
  {
      public Guid Id { get; set; }
      public string FullName { get; set; }
      public string Email { get; set; }
      public bool IsActive { get; set; }
  }
  ```
* **İYİ (Rich Domain Model - ONAY):**
  ```csharp
  // İYİ: Alanlar private set ile korunur, durum değişiklikleri iş kuralları ile denetlenir.
  namespace MyApp.Core.Entities;

  public class User : BaseEntity
  {
      public string FullName { get; private set; } = string.Empty;
      public string Email { get; private set; } = string.Empty;
      public bool IsActive { get; private set; } = true;

      // EF Core için private parameterless constructor
      private User() { }

      public User(string fullName, string email)
      {
          UpdateProfile(fullName, email);
      }

      public void UpdateProfile(string fullName, string email)
      {
          ArgumentException.ThrowIfNullOrWhiteSpace(fullName, nameof(fullName));
          ArgumentException.ThrowIfNullOrWhiteSpace(email, nameof(email));

          FullName = fullName.Trim();
          Email = email.Trim().ToLowerInvariant();
          SetModified();
      }

      public void Deactivate()
      {
          IsActive = false;
          SetModified();
      }
  }
  ```

### B. Evrensel Result Deseni (Core/Common)
* **Kural:** Katmanlar arası el sıkışmada hata kodları ve mesajları tipli olarak iletilir:
  ```csharp
  namespace MyApp.Core.Common;

  public record Result
  {
      public bool IsSuccess { get; init; }
      public string? ErrorMessage { get; init; }

      public static Result Success() => new() { IsSuccess = true };
      public static Result Failure(string message) => new() { IsSuccess = false, ErrorMessage = message };
  }

  public record Result<T> : Result
  {
      public T? Value { get; init; }

      public static Result<T> Success(T value) => new() { IsSuccess = true, Value = value };
      public new static Result<T> Failure(string message) => new() { IsSuccess = false, ErrorMessage = message };
  }
  ```

### C. Değer Nesneleri (Value Objects)
* İki değer nesnesi kimlikleriyle (ID) değil, taşıdıkları değerlerin eşitliği ile karşılaştırılır (C# `record` veya `readonly record struct`):
  ```csharp
  namespace MyApp.Core.ValueObjects;

  public readonly record struct Money(decimal Amount, string Currency)
  {
      public static Money Zero(string currency = "TRY") => new(0m, currency);
  }
  ```

---

## 🏛️ 4. Kurumsal Tasarım Kalıpları Kataloğu ve Seçim Rehberi (Design Patterns Selection Guide)

Çözüm Mimarı, DoR aşamasında her görev için aşağıdaki matrise göre hangi kalıbın kullanılacağını belirlemek ve `artifacts.designPatternsUsed` içine yazmakla yükümlüdür:

| Tasarım Kalıbı | Kategori | Kullanılacağı Senaryo & Problem | Core / Infra Sözleşmesi |
| :--- | :--- | :--- | :--- |
| **Strategy Pattern** | Davranışsal | Değişen iş kuralları, çoklu indirim/fiyatlandırma hesaplamaları, farklı ödeme yöntemleri | Arayüz `Core/Interfaces` içinde (`IDiscountStrategy`), somut stratejiler `Core/Strategies` veya `Infrastructure` içinde tanımlanır. |
| **Adapter Pattern** | Yapısal | Üçüncü parti kütüphaneler, SMS, E-Posta veya Ödeme API'leri (Stripe, Twilio vb.) | Domain hedef arayüzü `Core/Interfaces` içinde (`IPaymentGateway`), entegrasyon adaptörü `Infrastructure/Adapters` içinde yer alır. |
| **Decorator Pattern** | Yapısal | Caching, Logging, Performans Sayacı, Retry veya Yetkilendirme gibi kesişen endişeler | Ana servis sınıfına dokunulmaz; aynı arayüzü uygulayan `CachedXService` veya `LoggingXService` ile DI katmanında sarmalanır. |
| **Specification Pattern** | Davranışsal | Tekrar eden, birleştirilebilir veritabanı veya domain iş kuralı filtreleri | `ISpecification<T>` arayüzü `Core/Common` içinde, somut sorgu kuralları `Core/Specifications` içinde yaşar. |
| **Factory / Builder** | Yaratımsal | Çok parametreli, birden fazla adımlı veya katı invariyantlara sahip nesnelerin inşası | Varlık içi `Static Factory Method` (`Order.Create(...)`) veya test/sorgu için `OrderBuilder` kullanılır. |

---

## 📋 5. Adım Adım Mimari Tasarım Protokolü (SOP)

```text
[Adım 1: Gereksinim Ayrıştırma]
  ├── Analistin Gherkin şartnamesini oku.
  └── Varlık (Entity), Değer Nesnesi (Value Object) ve Eylem (Command/Query) sınırlarını ayır.

[Adım 2: Tasarım Kalıbı ve Sözleşme Seçimi]
  ├── İş mantığındaki dallanmalar için Strategy, dış entegrasyon için Adapter belirle.
  └── 'artifacts.designPatternsUsed' alanına seçilen kalıpları kaydet.

[Adım 3: Core Modellerini Tanımla]
  ├── 'Core/Entities/' altında Zengin Domain Entity'sini oluştur.
  ├── Gerekli invariyant kontrollerini (ThrowHelpers) entity metotlarına göm.
  └── Dış dünya ile el sıkışılacak DTO/Command record'larını oluştur.

[Adım 4: Arayüz (Interface) Sözleşmesini Çiz]
  ├── 'Core/Interfaces/' altında 'IService' ve 'IStrategy' arayüzlerini oluştur.
  ├── Tüm metotları Result<T> dönecek ve CancellationToken alacak şekilde imzala.
  └── Presentation katmanı için 'Web/ViewModels/' altında ViewModel sözleşmesini hazırla.

[Adım 5: Mimari Uygunluk Denetimi]
  ├── Core projesinin referanslarını denetle (Üçüncü parti bağımlılık var mı?).
  └── ViewModel ile Entity arasında doğrudan sızıntı var mı kontrol et.
```

---

## 🔍 6. Çözüm Mimarının 10 Maddelik Uygunluk Kapısı

| # | Kontrol Kriteri | Beklenen Standart | İhlal Durumunda |
| :--- | :--- | :--- | :--- |
| **1** | **Core İzolasyonu** | `Core` projesinde sıfır EF Core / Web referansı olmalıdır. | Referans varsa ➔ KESİN RED |
| **2** | **Anemik Model Yasağı** | Domain Entity'lerinde kontrolsüz public setter bulunamaz. | Varsa ➔ Private set ve metot yap |
| **3** | **Result Sözleşmesi** | Servis arayüzleri Exception yerine `Result` veya `Result<T>` dönmelidir. | Çıplak tip dönüyorsa ➔ RED |
| **4** | **ViewModel İzolasyonu** | View katmanına asla Domain Entity gönderilemez; `ViewModel` zorunludur. | Entity varsa ➔ RED |
| **5** | **Tasarım Kalıpları** | Dallanmalarda Strategy, dış API'de Adapter, kesişen işlerde Decorator şartnameye işlendi mi? | Belirtilmemişse ➔ RED |
| **6** | **DIP Kuralı** | Controller'lar somut sınıflara değil, daima `Core` arayüzlerine (`IUserService`) bağımlı olmalıdır. | Somut sınıf varsa ➔ RED |
| **7** | **CancellationToken** | Arayüzlerdeki tüm asenkron metotlar `CancellationToken ct = default` parametresi almalıdır. | Eksikse ➔ Ekle |
| **8** | **Captive Dependency** | Singleton sınıflara Scoped nesne inject edilemez. | Varsa ➔ Yaşam döngüsünü düzelt |
| **9** | **Kayıt Tarihçesi** | Tüm entity'ler `BaseEntity`'den türemeli ve `CreatedAt`, `ModifiedAt` yönetilmelidir. | Türemiyorsa ➔ RED |
| **10**| **0 Compiler Warning** | Mimari şablonlar sıfır uyarı ile derlenmelidir. | Uyarı varsa ➔ RED |
