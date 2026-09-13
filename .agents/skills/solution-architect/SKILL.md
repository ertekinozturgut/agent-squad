---
name: solution-architect
description: Clean Architecture, Domain-Driven Design (DDD), SOLID, contract.yaml sözleşmesi, ArchUnitNET testleri ve Kurumsal Tasarım Kalıplarına (23 GoF & Enterprise) uygun mimari kontratları tasarlar.
---

# Çözüm Mimarı Uzmanlık Rehberi (UDAP v2 & Clean Architecture Contract Edition)

Bu rehber, projenin mimari bütünlüğünü korumak, `.agents/contract.yaml` sözleşmesini yönetmek, katman sınırlarını çizmek, zengin domain modelleri, tasarım kalıpları (Design Patterns) ve ArchUnitNET ile doğrulanabilir mimari sözleşmeler tasarlamak için izlenecek prosedürleri içerir.

---

## 📚 1. Dayandığı Standartlar ve Literatür

1. **Clean Architecture: A Craftsman's Guide to Software Structure and Design** (Robert C. Martin - Uncle Bob).
2. **Domain-Driven Design: Tackling Complexity in the Heart of Software** (Eric Evans).
3. **Design Patterns: Elements of Reusable Object-Oriented Software** (Gang of Four - GoF).
4. **Patterns of Enterprise Application Architecture (PoEAA)** (Martin Fowler).
5. **ISO/IEC 25010:2023:** Modularity, Maintainability, Replaceability, Analysability.
6. **Automotive SPICE v4.0 (SWE.2 Software Architectural Design) & ADR:** Mimari Karar Kayıtları (R-AUT-004).
7. **UDAP v2 Mimari ve Modülerlik Kuralları (R-ARCH-001..010, R-MOD-001..004).**

---

## 🏗️ 2. Katman Mimarisi ve Sözleşme Bağımlılıkları (`contract.yaml`)

Sistem 4 temel katmandan oluşur ve bağımlılık kuralı daima **içe doğru (Domain'e)** işaret eder:

```text
┌─────────────────────────────────────────┐
│               Api (L1)                  │
│       Controllers, Endpoints, Tags      │
└────────────────────┬────────────────────┘
                     │ (may_depend_on: [application, domain])
                     ▼
┌─────────────────────────────────────────┐
│            Application (L2)             │
│    Use Cases, Commands, Handlers, DTOs  │
└────────────────────┬────────────────────┘
                     │ (may_depend_on: [domain])
                     ▼
┌─────────────────────────────────────────┐
│               Domain (L3)               │
│   Entities, Value Objects, Pure Enums   │
└─────────────────────────────────────────┘
 ▲                   ▲
 │                   │ (may_depend_on: [domain, application])
 │                   ▼
 │     ┌─────────────────────────────────────────┐
 └─────┤          Infrastructure (L2)            │
       │   EF Core, DbContext, Polly, Outbox     │
       └─────────────────────────────────────────┘
```

### Katman Sorumluluk Sınırları ve Kırmızı Çizgiler:
1. **Domain Katmanı (R-ARCH-001, R-ARCH-003, R-NET-054):**
   - **KESİN KURAL:** Domain asla `Microsoft.EntityFrameworkCore`, `Microsoft.AspNetCore`, `System.Data`, `System.IO`, `System.Net.Http` veya `Azure.Messaging` paketlerine bağımlı olamaz. Tamamen saf C# olmalıdır.
   - Zamana bağlı işlemlerde `DateTime.Now` yasaktır; `TimeProvider` soyutlaması kullanılır (R-NET-050).
   - `Guid.NewGuid()` çağrısı enjekte edilir (R-NET-052).
2. **Application Katmanı (R-ARCH-002):**
   - Yalnızca Domain katmanına bağımlı olabilir. Altyapı somutlamalarını tanımaz; soyut servis arayüzleri ve MediatR/CQRS işleyicileri barındırır.
3. **Infrastructure Katmanı (R-ARCH-004):**
   - Application ve Domain arayüzlerini somutlaştırır (`AppDbContext`, Polly HTTP Clients, Transactional Outbox Worker).
4. **Api Katmanı (R-ARCH-004, R-ARCH-005):**
   - Infrastructure sınıflarına doğrudan erişemez. Domain entity tipleri API imzalarında asla görünemez (Mass-assignment koruması CWE-915).

---

## 🧩 3. Modüler Monolit ve Dikey Dilim İzolasyonu (R-MOD)

1. **Feature Bağımsızlığı (R-MOD-001):** `Orders`, `Customers`, `Vehicles`, `Campaigns` dikey dilimleri birbirine doğrudan bağımlı olamaz.
2. **Ortak Kod (R-MOD-003):** Paylaşılan kodlar yalnızca `Company.SharedKernel` altında toplanabilir.
3. **SharedKernel Saflığı (R-MOD-004):** `SharedKernel` hiçbir dikey feature paketine bağımlı olamaz.

---

## 🏛️ 4. Kurumsal Dayanıklılık ve Entegrasyon Tasarımı

1. **Transactional Outbox Pattern (R-NET-056):** Veritabanı transaction'ı içinde harici Service Bus veya HTTP çağrısı yapılamaz. Olaylar önce `OutboxMessages` tablosuna yazılır ve bağımsız worker tarafından asenkron yayınlanır.
2. **Resilience & Circuit Breaker (R-NET-042, R-NET-046, R-NET-048):** Dış servislere giden çağrılar Polly pipeline ile (Exponential backoff + jitter + Circuit Breaker) korunmalıdır.
3. **Idempotency & Correlation (R-NET-040, R-NET-041):** Tüm mesaj ve dış isteklerde `X-Correlation-Id` başlığı ve idempotency anahtarı tasarlanmalıdır.

---

## 📋 5. Çözüm Mimarının DoR Tasarım Kontrol Listesi

Bir görev kodlanmaya başlamadan önce (`dorMet: true`), Mimar şu şartları tamamlar:
1. `contract.yaml` katman ve feature sınırlarına uygun model tasarlandı mı?
2. Entity'ler zengin domain modeli (private setter, invariyant koruması) prensibinde mi?
3. View için bağımsız `ViewModel` / `DTO` kontratı hazırlandı mı?
4. Fonksiyonel gereksinim için uygun GoF veya Enterprise Tasarım Kalıbı belirlendi mi?
5. Kritik mimari kararlar için `docs/adr/` altında ADR kaydı açıldı mı (R-AUT-004)?
