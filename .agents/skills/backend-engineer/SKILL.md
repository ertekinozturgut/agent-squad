---
name: backend-engineer
description: C# 14, .NET 10, ASP.NET Core MVC Controller/Action metotları, EF Core 10 veri erişimi, Result deseni, Tüm GoF Tasarım Kalıpları (23 Kalıp) ve Kurumsal Desenleri (Specification, Unit of Work, Options) eksiksiz uygular.
---

# .NET 10 Backend Geliştirici Uzmanlık Rehberi (Clean Architecture & Full Design Patterns Encyclopedia)

Bu rehber, projedeki backend geliştirmelerinin mimari değişmezlere uyumlu; asenkron, yüksek performanslı, nesne yönelimli programlama (OOP), **Tüm Gang of Four (GoF) Tasarım Kalıpları (23 Kalıp)**, **Kurumsal .NET Desenleri** ve **Temiz Kod (Clean Code)** standartlarında üretilmesini sağlayan kuralları ve somut C# 14 / .NET 10 uygulamalarını içerir.

> [!IMPORTANT]
> Tüm backend geliştirmelerinde proje anayasası olan `05-backend-development-clean-code-standards.md` ve `02-architecture-invariants.md` kurallarına harfiyen uyulması zorunludur.

---

## 📚 1. Dayandığı Literatür ve Standartlar

1. **Clean Code: A Handbook of Agile Software Craftsmanship** (Robert C. Martin - Uncle Bob)
2. **Design Patterns: Elements of Reusable Object-Oriented Software** (Gang of Four - Erich Gamma, Richard Helm, Ralph Johnson, John Vlissides)
3. **Patterns of Enterprise Application Architecture (PoEAA)** (Martin Fowler)
4. **Refactoring: Improving the Design of Existing Code** (Martin Fowler)
5. **C# in Depth (4th Edition)** (Jon Skeet)
6. **CLR via C# (4th Edition)** (Jeffrey Richter)
7. **Concurrency in C# Cookbook (2nd Edition)** (Stephen Cleary)

---

## ⚡ 2. Fonksiyon ve Metot Yönetimi (Function Craftsmanship)

1. **Tek Sorumluluk (Do One Thing):** Bir fonksiyon yalnızca tek bir iş yapmalı, onu mükemmel yapmalı ve yalnızca onu yapmalıdır.
2. **Boyut Sınırı: Maksimum 15 - 25 Satır:** Ekranı dikey kaydırmadan tek bakışta anlaşılmalıdır. 25 satırı aşan metotlar SRP ihlalidir.
3. **Parametre Sayısı Kuralı:** İdeal: 0 veya 1 parametre. En fazla: 2 parametre. 4 veya daha fazla parametre **kesinlikle yasaktır**; `Command`, `Record` veya `Parameter Object` altında toplanmalıdır.
4. **Bayrak (Boolean Flag) Parametre Yasağı:** `bool isSpecial` gibi bayraklar yasaktır. İki ayrı açık isimli metot yazılmalıdır.
5. **Komut - Sorgu Ayrımı (CQS):** Bir metot ya durumu değiştirmeli (Command) ya da soruya cevap vermelidir (Query). Gizli yan etki (side effect) yasaktır.
6. **Guard Clauses & Fail-Fast (Max Girinti: 2):** İç içe derin `if-else` piramitleri yasaktır; hata durumları en başta `return` edilmelidir.

---

## 🏛️ 3. Sınıf Kapsamı ve Tasarımı (Class Craftsmanship)

1. **Sınıf Boyutu: Maksimum 200 - 300 Satır:** God Object, `CommonHelper`, `GeneralManager` gibi her işe bakan sınıflar yasaktır.
2. **Yüksek Bağdaşıklık (High Cohesion):** Sınıfın tüm metotları ortak alanları/bağımlılıkları kullanmalıdır.
3. **Demeter Yasası (Law of Demeter):** `order.Customer.Address.City.ZipCode` yerine `order.GetBillingZipCode()` (Tell, Don't Ask).
4. **Kapsülleme (Encapsulation):** Public field ve kontrolsüz public setter yasaktır. İç durum daima `private set` veya metotlarla korunur.

---

## 🧩 4. Kapsamlı Tasarım Kalıpları Kataloğu (Full GoF & Enterprise Encyclopedia)

Backend mühendisi, mimari şartnamede kararlaştırılan kalıpları aşağıdaki kanonik C# 14 / .NET 10 standartlarına göre uygular:

```text
       ┌─────────────────────────────────────────────────────────────┐
       │                KURUMSAL TASARIM KALIPLARI                   │
       ├──────────────────────────────┬──────────────────────────────┤
       │ 1. Yaratımsal (Creational)   │ 2. Yapısal (Structural)      │
       │ • Factory Method             │ • Adapter                    │
       │ • Abstract Factory           │ • Bridge                     │
       │ • Builder                    │ • Composite                  │
       │ • Prototype                  │ • Decorator                  │
       │ • Singleton (DI Scoped/Sing.)│ • Facade                     │
       │                              │ • Flyweight                  │
       │                              │ • Proxy                      │
       ├──────────────────────────────┼──────────────────────────────┤
       │ 3. Davranışsal (Behavioral)  │ 4. Kurumsal & Modern .NET    │
       │ • Chain of Responsibility    │ • Specification Pattern      │
       │ • Command (CQRS)             │ • Result Pattern (ROP)       │
       │ • Iterator & Async Streams   │ • Unit of Work & Repository  │
       │ • Mediator & Domain Events   │ • Strongly-Typed Options     │
       │ • Memento & Snapshot         │                              │
       │ • Observer                   │                              │
       │ • State                      │                              │
       │ • Strategy                   │                              │
       │ • Template Method            │                              │
       │ • Visitor                    │                              │
       └──────────────────────────────┴──────────────────────────────┘
```

---

### 🎨 BÖLÜM 4.1: Yaratımsal Kalıplar (Creational Patterns)

#### 1. Factory Method Pattern
* **Amaç:** Nesne yaratma mantığını istemciden soyutlayarak alt sınıflara veya statik metotlara devretmek.
* **Kullanım Yeri:** `Core/Entities` içinde Zengin Domain Modelleri ve Varlık inşası.
```csharp
// Core/Entities/Order.cs
public class Order : BaseEntity
{
    public OrderNumber Number { get; private set; }
    public OrderStatus Status { get; private set; }
    public Money TotalAmount { get; private set; }

    private Order() { }

    // Factory Method: İnvariyantları garanti altına alarak nesne üretir
    public static Result<Order> Create(Customer customer, IEnumerable<OrderItem> items)
    {
        ArgumentNullException.ThrowIfNull(customer);
        var itemList = items.ToList();
        if (itemList.Count == 0)
            return Result<Order>.Failure("Sipariş en az bir ürün içermelidir.");

        var order = new Order
        {
            Id = Guid.NewGuid(),
            Number = OrderNumber.Generate(),
            Status = OrderStatus.Pending,
            TotalAmount = Money.Sum(itemList.Select(i => i.Price))
        };
        return Result<Order>.Success(order);
    }
}
```

#### 2. Abstract Factory Pattern
* **Amaç:** Birbiriyle ilişkili veya bağımlı nesne ailelerini somut sınıflarını belirtmeden oluşturmak.
* **Kullanım Yeri:** Çoklu veri sağlayıcıları, UI temaları veya çoklu ödeme/kargo altyapıları (`Infrastructure`).
```csharp
// Core/Interfaces/INotificationFactory.cs
public interface INotificationFactory
{
    IMessageSender CreateSender();
    ITemplateFormatter CreateFormatter();
}

// Infrastructure/Factories/EmailNotificationFactory.cs
public class EmailNotificationFactory : INotificationFactory
{
    public IMessageSender CreateSender() => new SmtpMessageSender();
    public ITemplateFormatter CreateFormatter() => new HtmlTemplateFormatter();
}
```

#### 3. Builder Pattern
* **Amaç:** Çok sayıda parametreye, opsiyonel alanlara veya karmaşık adımlara sahip nesnelerin okunabilir inşası.
* **Kullanım Yeri:** Test Data Builder'lar, karmaşık sorgu filtreleri ve rapor parametreleri.
```csharp
// Core/Builders/UserProfileFilterBuilder.cs
public class UserProfileFilterBuilder
{
    private string? _searchTerm;
    private bool? _isActive = true;
    private int _page = 1;
    private int _pageSize = 20;

    public UserProfileFilterBuilder WithSearch(string? term) { _searchTerm = term?.Trim(); return this; }
    public UserProfileFilterBuilder OnlyActive(bool isActive) { _isActive = isActive; return this; }
    public UserProfileFilterBuilder Paginate(int page, int size) { _page = page; _pageSize = size; return this; }

    public UserProfileFilter Build() => new(_searchTerm, _isActive, _page, _pageSize);
}
```

#### 4. Prototype Pattern
* **Amaç:** Mevcut bir nesnenin derin veya sığ kopyasını oluşturarak maliyetli yaratım süreçlerinden kaçınmak.
* **Kullanım Yeri:** C# `record` ve `with` ifadeleriyle immutable durum kopyalama.
```csharp
// Core/Common/ReportConfiguration.cs
public record ReportConfiguration(string Title, string ExportFormat, bool IncludeCharts, DateTime GeneratedAt)
{
    public ReportConfiguration AsPdf() => this with { ExportFormat = "PDF", GeneratedAt = DateTime.UtcNow };
    public ReportConfiguration AsExcel() => this with { ExportFormat = "XLSX", GeneratedAt = DateTime.UtcNow };
}
```

#### 5. Singleton Pattern (ve Modern DI Yaşam Döngüsü)
* **Amaç:** Bir sınıftan uygulama ömrü boyunca yalnızca tek bir örneğin var olmasını garanti etmek.
* **Kural:** Statik global Singleton anti-pattern'i yerine ASP.NET Core Dependency Injection `AddSingleton<T>` kullanılır. Captive dependency (Singleton içine Scoped nesne enjeksiyonu) **kesinlikle yasaktır**.
```csharp
// Core/Interfaces/ICacheKeyGenerator.cs
public interface ICacheKeyGenerator
{
    string GenerateKey<T>(string id);
}

// Infrastructure/Services/DefaultCacheKeyGenerator.cs
public sealed class DefaultCacheKeyGenerator : ICacheKeyGenerator
{
    public string GenerateKey<T>(string id) => $"{typeof(T).Name.ToLowerInvariant()}:{id}";
}
// Program.cs: builder.Services.AddSingleton<ICacheKeyGenerator, DefaultCacheKeyGenerator>();
```

---

### 🏛️ BÖLÜM 4.2: Yapısal Kalıplar (Structural Patterns)

#### 6. Adapter Pattern
* **Amaç:** Uyumsuz bir üçüncü taraf API veya kütüphane arayüzünü projenin Core katmanının beklediği arayüze dönüştürmek.
* **Kullanım Yeri:** `Infrastructure/Adapters`
```csharp
// Core/Interfaces/ISmsService.cs
public interface ISmsService
{
    Task<Result> SendAsync(string phoneNumber, string message, CancellationToken ct = default);
}

// Infrastructure/Adapters/TwilioSmsAdapter.cs
public class TwilioSmsAdapter(TwilioRestClient twilioClient, IOptions<TwilioOptions> options) : ISmsService
{
    public async Task<Result> SendAsync(string phoneNumber, string message, CancellationToken ct = default)
    {
        try
        {
            var response = await twilioClient.SendAsync(options.Value.FromNumber, phoneNumber, message, ct);
            return response.IsOk ? Result.Success() : Result.Failure(response.ErrorText ?? "SMS gönderilemedi.");
        }
        catch (Exception ex)
        {
            return Result.Failure($"SMS sağlayıcı hatası: {ex.Message}");
        }
    }
}
```

#### 7. Bridge Pattern
* **Amaç:** Bir soyutlamayı uygulamasından ayırarak ikisinin de bağımsız olarak geliştirilmesini sağlamak.
* **Kullanım Yeri:** Mesaj bildirim mekanizmaları ve veri aktarım kanalları.
```csharp
// Core/Bridge/IMessageChannel.cs
public interface IMessageChannel
{
    Task SendRawAsync(string recipient, string title, string body, CancellationToken ct);
}

// Core/Bridge/NotificationAbstraction.cs
public abstract class Notification(IMessageChannel channel)
{
    public abstract Task DispatchAsync(string recipient, string content, CancellationToken ct);
}

public class UrgentAlertNotification(IMessageChannel channel) : Notification(channel)
{
    public override Task DispatchAsync(string recipient, string content, CancellationToken ct) =>
        channel.SendRawAsync(recipient, "[ACİL] Sistem Uyarısı", content, ct);
}
```

#### 8. Composite Pattern
* **Amaç:** Nesneleri ağaç yapıları halinde düzenleyerek tekil ve bileşik nesnelere aynı arayüz üzerinden işlem yapmak.
* **Kullanım Yeri:** Dinamik menüler, hiyerarşik izin matrisleri veya paket ürün fiyatlandırmaları.
```csharp
// Core/Composite/IPriceableItem.cs
public interface IPriceableItem
{
    Money GetPrice();
}

public class ProductItem(Money price) : IPriceableItem
{
    public Money GetPrice() => price;
}

public class ProductBundle : IPriceableItem
{
    private readonly List<IPriceableItem> _items = [];
    public void Add(IPriceableItem item) => _items.Add(item);
    public Money GetPrice() => Money.Sum(_items.Select(i => i.GetPrice()));
}
```

#### 9. Decorator Pattern
* **Amaç:** Mevcut kod yapısını değiştirmeden nesneye dinamik olarak ek sorumluluklar (Caching, Logging, Resilience) kazandırmak.
* **Kullanım Yeri:** `Infrastructure/Decorators`
```csharp
// Infrastructure/Decorators/CachedUserService.cs
public class CachedUserService(IUserService inner, IMemoryCache cache) : IUserService
{
    public async Task<Result<UserProfileViewModel>> GetProfileAsync(Guid id, CancellationToken ct = default)
    {
        var cacheKey = $"profile:{id}";
        if (cache.TryGetValue(cacheKey, out UserProfileViewModel? cached) && cached is not null)
            return Result<UserProfileViewModel>.Success(cached);

        var result = await inner.GetProfileAsync(id, ct);
        if (result.IsSuccess && result.Value is not null)
            cache.Set(cacheKey, result.Value, TimeSpan.FromMinutes(10));

        return result;
    }
}
```

#### 10. Facade Pattern
* **Amaç:** Karmaşık ve dağınık alt sistemler kümesine (envanter, ödeme, fatura, kargo) tek, sade ve anlaşılır bir giriş noktası sunmak.
* **Kullanım Yeri:** `Application/Facades`
```csharp
// Application/Facades/OrderCheckoutFacade.cs
public class OrderCheckoutFacade(
    IInventoryService inventory,
    IPaymentGateway payment,
    IInvoiceGenerator invoice,
    ISmsService sms)
{
    public async Task<Result<Guid>> CheckoutAsync(CheckoutCommand cmd, CancellationToken ct)
    {
        var stockResult = await inventory.ReserveStockAsync(cmd.Items, ct);
        if (!stockResult.IsSuccess) return Result<Guid>.Failure(stockResult.ErrorMessage!);

        var paymentResult = await payment.ChargeAsync(cmd.Total, cmd.Card, ct);
        if (!paymentResult.IsSuccess) return Result<Guid>.Failure(paymentResult.ErrorMessage!);

        await invoice.CreateAsync(cmd.UserId, cmd.Total, ct);
        await sms.SendAsync(cmd.Phone, "Siparişiniz başarıyla alındı.", ct);

        return Result<Guid>.Success(paymentResult.Value!);
    }
}
```

#### 11. Flyweight Pattern
* **Amaç:** Çok sayıda benzer nesnenin ortak verilerini paylaşarak bellek tüketimini minimize etmek.
* **Kullanım Yeri:** Sabit Lookup tabloları, para birimi sembolleri veya paylaşılan metadata havuzları.
```csharp
// Core/Flyweight/CurrencySymbolFactory.cs
public static class CurrencySymbolFactory
{
    private static readonly FrozenDictionary<string, string> Symbols = new Dictionary<string, string>
    {
        ["TRY"] = "₺", ["USD"] = "$", ["EUR"] = "€", ["GBP"] = "£"
    }.ToFrozenDictionary();

    public static string GetSymbol(string currencyCode) =>
        Symbols.GetValueOrDefault(currencyCode.ToUpperInvariant(), currencyCode);
}
```

#### 12. Proxy Pattern
* **Amaç:** Asıl nesneye erişimi kontrol etmek, geciktirmek (Lazy Loading) veya yetki denetimi yapmak.
* **Kullanım Yeri:** Güvenlik katmanı ve korumalı kaynak erişimi.
```csharp
// Infrastructure/Proxies/ProtectedReportServiceProxy.cs
public class ProtectedReportServiceProxy(IReportService inner, ICurrentUser currentUser) : IReportService
{
    public async Task<Result<ReportData>> GenerateAuditReportAsync(CancellationToken ct)
    {
        if (!currentUser.IsInRole("Auditor") && !currentUser.IsInRole("Admin"))
            return Result<ReportData>.Failure("Bu raporu üretmek için denetçi yetkisine sahip olmalısınız.");

        return await inner.GenerateAuditReportAsync(ct);
    }
}
```

---

### ⚡ BÖLÜM 4.3: Davranışsal Kalıplar (Behavioral Patterns)

#### 13. Chain of Responsibility Pattern
* **Amaç:** Bir isteği alıcılar zinciri boyunca ileterek her alıcının isteği işleyebilmesini veya bir sonrakine aktarabilmesini sağlamak.
* **Kullanım Yeri:** İstek doğrulama zincirleri, pipeline'lar ve ASP.NET Core Middleware.
```csharp
// Core/Pipelines/IOrderValidationStep.cs
public interface IOrderValidationStep
{
    IOrderValidationStep SetNext(IOrderValidationStep next);
    Task<Result> ValidateAsync(Order order, CancellationToken ct);
}

public abstract class BaseOrderValidationStep : IOrderValidationStep
{
    private IOrderValidationStep? _next;
    public IOrderValidationStep SetNext(IOrderValidationStep next) { _next = next; return next; }

    public virtual async Task<Result> ValidateAsync(Order order, CancellationToken ct)
    {
        return _next is not null ? await _next.ValidateAsync(order, ct) : Result.Success();
    }
}
```

#### 14. Command Pattern
* **Amaç:** Bir eylemi, parametrelerini ve yürütme mantığını bağımsız bir nesne (Command) içine kapsüllemek.
* **Kullanım Yeri:** CQRS komutları, PRG deseni ve asenkron işlem kuyrukları.
```csharp
// Core/Commands/UpdateUserProfileCommand.cs
public readonly record struct UpdateUserProfileCommand(
    Guid UserId,
    string FullName,
    string Email
);
```

#### 15. Interpreter Pattern
* **Amaç:** Belirli bir dil veya kural ifadesinin gramerini modelleyip çözümlemek.
* **Kullanım Yeri:** Dinamik filtre ayrıştırıcıları, özel indirim kural motorları.
```csharp
// Core/Interpreter/IExpression.cs
public interface IFilterExpression<T>
{
    bool Interpret(T context);
}

public class MinAgeExpression(int minAge) : IFilterExpression<User>
{
    public bool Interpret(User user) => user.Age >= minAge;
}
```

#### 16. Iterator Pattern & Async Streams
* **Amaç:** Bir koleksiyonun elemanlarına iç yapısını açığa çıkarmadan sırayla erişmek.
* **Kullanım Yeri:** C# 14 `IAsyncEnumerable<T>` ile büyük veri akışları (Chunking/Streaming).
```csharp
// Core/Interfaces/IDataStreamReader.cs
public interface IDataStreamReader
{
    IAsyncEnumerable<DataRecord> StreamRecordsAsync(CancellationToken ct);
}

// Infrastructure/Services/CsvDataStreamReader.cs
public class CsvDataStreamReader : IDataStreamReader
{
    public async IAsyncEnumerable<DataRecord> StreamRecordsAsync([EnumeratorCancellation] CancellationToken ct)
    {
        while (/* okunacak satır var */)
        {
            ct.ThrowIfCancellationRequested();
            yield return await ParseNextRecordAsync(ct);
        }
    }
}
```

#### 17. Mediator Pattern & Domain Events
* **Amaç:** Nesneler arasındaki doğrudan bağımlılıkları ortadan kaldırarak iletişimi merkezi bir aracı (Mediator) üzerinden yönetmek.
* **Kullanım Yeri:** In-Process Message Bus (MediatR) ve Domain Event fırlatma.
```csharp
// Core/Events/UserRegisteredEvent.cs
public record UserRegisteredEvent(Guid UserId, string Email) : IDomainEvent;

// Application/EventHandlers/SendWelcomeEmailHandler.cs
public class SendWelcomeEmailHandler(ISmsService sms) : IDomainEventHandler<UserRegisteredEvent>
{
    public async Task HandleAsync(UserRegisteredEvent notification, CancellationToken ct)
    {
        await sms.SendAsync(notification.Email, "Sistemimize hoş geldiniz!", ct);
    }
}
```

#### 18. Memento Pattern
* **Amaç:** Bir nesnenin kapsüllemesini bozmadan durumunu kaydedip daha sonra bu duruma geri dönebilmesini sağlamak.
* **Kullanım Yeri:** Denetim defteri (Audit Log Snapshot), form taslakları veya geri alma mekanizmaları.
```csharp
// Core/Memento/EditorMemento.cs
public record EditorMemento(string Content, DateTime Timestamp);

public class DocumentEditor
{
    public string Content { get; set; } = string.Empty;
    public EditorMemento SaveState() => new(Content, DateTime.UtcNow);
    public void Restore(EditorMemento memento) => Content = memento.Content;
}
```

#### 19. Observer Pattern
* **Amaç:** Bir nesnede durum değişikliği olduğunda bağımlı tüm abonelerine otomatik bildirim gitmesini sağlamak.
* **Kullanım Yeri:** Gerçek zamanlı SignalR bildirimleri veya Event Aggregator.
```csharp
// Core/Observer/IStockPriceObserver.cs
public interface IStockPriceObserver
{
    Task OnPriceChangedAsync(string symbol, decimal newPrice);
}

public class StockTicker
{
    private readonly List<IStockPriceObserver> _observers = [];
    public void Subscribe(IStockPriceObserver observer) => _observers.Add(observer);
    public async Task NotifyAsync(string symbol, decimal price)
    {
        foreach (var observer in _observers)
            await observer.OnPriceChangedAsync(symbol, price);
    }
}
```

#### 20. State Pattern
* **Amaç:** Bir nesnenin iç durumu değiştikçe davranışını değiştirmesini sağlamak; `switch-case` yerine durum nesneleri kullanmak.
* **Kullanım Yeri:** Sipariş, Talep, Fatura yaşam döngüsü (`Pending`, `Approved`, `Shipped`, `Cancelled`).
```csharp
// Core/States/IOrderState.cs
public interface IOrderState
{
    Result Cancel(Order order);
    Result Ship(Order order);
}

public class ShippedOrderState : IOrderState
{
    public Result Cancel(Order order) => Result.Failure("Kargolanmış sipariş iptal edilemez; iade süreci başlatılmalıdır.");
    public Result Ship(Order order) => Result.Failure("Sipariş zaten kargoya verilmiştir.");
}
```

#### 21. Strategy Pattern
* **Amaç:** Birbiri yerine kullanılabilen bir algoritma ailesi tanımlayıp her birini ayrı sınıflarda enkapsüle etmek.
* **Kullanım Yeri:** Dinamik fiyatlandırma, indirim, kargo ücreti ve doğrulama motorları.
```csharp
// Core/Interfaces/IDiscountStrategy.cs
public interface IDiscountStrategy
{
    bool AppliesTo(CustomerType customerType);
    decimal Calculate(decimal amount);
}

public class VipDiscountStrategy : IDiscountStrategy
{
    public bool AppliesTo(CustomerType customerType) => customerType == CustomerType.Vip;
    public decimal Calculate(decimal amount) => amount * 0.20m;
}
```

#### 22. Template Method Pattern
* **Amaç:** Bir algoritmanın ana iskeletini bir şablon metotta tanımlayıp, belirli adımların uygulanmasını alt sınıflara bırakmak.
* **Kullanım Yeri:** Veri içe aktarma motorları (Excel/CSV Parser) veya rapor oluşturucular.
```csharp
// Core/Templates/DataImporterTemplate.cs
public abstract class DataImporterTemplate
{
    public async Task<Result<int>> ImportAsync(Stream dataStream, CancellationToken ct)
    {
        var rawData = await ReadDataAsync(dataStream, ct);
        var parsed = ParseRecords(rawData);
        var validated = Validate(parsed);
        return await SaveToDatabaseAsync(validated, ct);
    }

    protected abstract Task<string> ReadDataAsync(Stream stream, CancellationToken ct);
    protected abstract List<DataRowDto> ParseRecords(string content);
    protected virtual List<DataRowDto> Validate(List<DataRowDto> rows) => rows.Where(r => r.IsValid).ToList();
    protected abstract Task<Result<int>> SaveToDatabaseAsync(List<DataRowDto> rows, CancellationToken ct);
}
```

#### 23. Visitor Pattern
* **Amaç:** Bir nesne yapısındaki elemanlar üzerinde yürütülecek operasyonları, sınıfların kendilerini değiştirmeden dışarıdan tanımlamak.
* **Kullanım Yeri:** Vergi hesaplama, HTML/PDF çıktı üretimi ve AST gezintisi.
```csharp
// Core/Visitor/IVisitor.cs
public interface IOrderElementVisitor
{
    void Visit(PhysicalProduct product);
    void Visit(DigitalProduct digital);
}

public interface IOrderElement
{
    void Accept(IOrderElementVisitor visitor);
}
```

---

### 🚀 BÖLÜM 4.4: Kurumsal & Modern .NET Desenleri (Enterprise Patterns)

#### 24. Specification Pattern
* **Amaç:** Domain varlıkları üzerindeki sorgulama ve filtreleme kurallarını LINQ bağımlılığı olmadan tekrar kullanılabilir sınıflarda toplamak.
```csharp
// Core/Common/ISpecification.cs
public interface ISpecification<T>
{
    Expression<Func<T, bool>> Criteria { get; }
    bool IsSatisfiedBy(T entity);
}

// Core/Specifications/ActiveHighValueCustomersSpec.cs
public class ActiveHighValueCustomersSpec : ISpecification<Customer>
{
    public Expression<Func<Customer, bool>> Criteria => 
        c => c.IsActive && c.TotalSpent >= 50000m;

    public bool IsSatisfiedBy(Customer entity) => 
        entity.IsActive && entity.TotalSpent >= 50000m;
}
```

#### 25. Result Pattern (Railway Oriented Programming)
* **Amaç:** Beklenen iş kuralı hatalarında `throw Exception` yerine dönüş tipli, güvenli akış sağlamak.
```csharp
// Core/Common/Result.cs
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

#### 26. Unit of Work & Repository Pattern (EF Core Entegrasyonu)
* **Amaç:** Çoklu veri tabanı işlemlerinde tek bir transaction sınırı (ACID) ve test edilebilir sorgulama soyutlaması kurmak.
```csharp
// Core/Interfaces/IUnitOfWork.cs
public interface IUnitOfWork : IDisposable
{
    Task<int> CommitAsync(CancellationToken ct = default);
}

// Infrastructure/Persistence/UnitOfWork.cs
public class UnitOfWork(AppDbContext dbContext) : IUnitOfWork
{
    public Task<int> CommitAsync(CancellationToken ct = default) => dbContext.SaveChangesAsync(ct);
    public void Dispose() => dbContext.Dispose();
}
```

#### 27. Strongly-Typed Options Pattern
* **Amaç:** Konfigürasyon değerlerini magic string (`_config["Key"]`) yerine tip güvenli sınıflarla bağlamak.
```csharp
// Infrastructure/Configuration/JwtOptions.cs
public class JwtOptions
{
    public const string SectionName = "JwtSettings";
    public string SecretKey { get; set; } = string.Empty;
    public int ExpiryMinutes { get; set; } = 60;
}
// Enjeksiyon: public class TokenService(IOptions<JwtOptions> options) { ... }
```

---

## 💻 5. Somut Kodlama Örnekleri (KÖTÜ vs İYİ)

### A. Metot Tasarımı, Guard Clauses ve Parametre Yönetimi
* **KÖTÜ (Anti-Pattern):**
  ```csharp
  // KÖTÜ: 5 parametreli, boolean flag var, iç içe derin if blokları, exception fırlatıyor
  public void CreateUser(string name, string email, string phone, int age, bool isVip)
  {
      if (!string.IsNullOrEmpty(name))
      {
          if (email.Contains("@"))
          {
              if (age >= 18)
              {
                  if (isVip) { /* VIP işlemleri */ }
                  else { /* Standart işlemler */ }
              }
              else throw new Exception("Yaş 18'den küçük olamaz");
          }
          else throw new Exception("Geçersiz email");
      }
      else throw new Exception("İsim boş");
  }
  ```
* **İYİ (Production-Grade & Clean Code):**
  ```csharp
  // İYİ: Command record, Guard clauses, Result deseni, CancellationToken
  public async Task<Result<Guid>> RegisterUserAsync(RegisterUserCommand cmd, CancellationToken ct = default)
  {
      if (string.IsNullOrWhiteSpace(cmd.FullName)) 
          return Result<Guid>.Failure("Ad Soyad alanı boş bırakılamaz.");
          
      if (!EmailValidator.IsValid(cmd.Email)) 
          return Result<Guid>.Failure("Geçersiz e-posta formatı.");
          
      if (cmd.Age < 18) 
          return Result<Guid>.Failure("Kullanıcı en az 18 yaşında olmalıdır.");

      var emailExists = await dbContext.Users
          .AnyAsync(u => u.Email == cmd.Email.ToLowerInvariant(), ct);
          
      if (emailExists)
          return Result<Guid>.Failure("Bu e-posta adresi zaten kullanımda.");

      var user = new User(cmd.FullName, cmd.Email, cmd.Phone, cmd.Age);
      dbContext.Users.Add(user);
      await dbContext.SaveChangesAsync(ct);

      return Result<Guid>.Success(user.Id);
  }
  ```

### B. İnce Controller (Skinny Controller) ve PRG Deseni
```csharp
[Authorize]
public class ProfileController(IUserService userService) : Controller
{
    [HttpGet]
    public async Task<IActionResult> Edit(CancellationToken ct)
    {
        var userId = User.GetUserId();
        var result = await userService.GetProfileAsync(userId, ct);
        if (!result.IsSuccess)
        {
            TempData["ErrorMessage"] = result.ErrorMessage;
            return RedirectToAction("Index", "Home");
        }

        return View(new UpdateProfileViewModel
        {
            FullName = result.Value!.FullName,
            Email = result.Value!.Email
        });
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Edit(UpdateProfileViewModel model, CancellationToken ct)
    {
        if (!ModelState.IsValid) return View(model);

        var userId = User.GetUserId();
        var command = new UpdateProfileCommand(model.FullName, model.Email);
        var result = await userService.UpdateProfileAsync(userId, command, ct);

        if (!result.IsSuccess)
        {
            ModelState.AddModelError(string.Empty, result.ErrorMessage!);
            return View(model);
        }

        TempData["SuccessMessage"] = "Profil bilgileriniz başarıyla güncellendi.";
        return RedirectToAction(nameof(Edit));
    }
}
```

---

## 🧹 6. Temiz Kod (Clean Code) Temel İlkeleri

1. **Niyet Belirten İsimlendirme:** Tek harfli (`x`, `d`) veya anlamsız kısaltmalar (`usr`, `temp`, `data`) yasaktır.
2. **İzci Kuralı (The Boy Scout Rule):** Her dokunduğun dosyayı bulduğundan daha temiz bırak.
3. **Yorum Satırı Kokusu:** Kötü kodu açıklamak için yorum yazılmaz; kod kendini anlatacak kadar açık hale getirilir.
4. **Sıfır Sihirli Sayı/Metin:** `if (status == 2)` yerine `OrderStatus.Approved` ve strongly-typed sabitler kullanılır.
5. **DRY & KISS & YAGNI:** Tekrar eden iş kuralı tekilleştirilir; varsayımsal gereksiz karmaşıklıklardan kaçınılır.

---

## 📋 7. Adım Adım Backend Geliştirme Protokolü (SOP)

```text
[Adım 1: Sözleşme ve Tasarım Kalıbı İncelemesi]
  ├── Mimarın IService, DTO ve seçtiği Tasarım Kalıbı (Strategy/Adapter/Decorator/vb.) sözleşmesini oku.
  └── Analistin Gherkin kabul kriterlerindeki sınır durumları çıkar.

[Adım 2: Domain Modeli, Tasarım Kalıbı ve İş Kuralları]
  ├── Seçilen tasarım kalıbını ilgili katmanda (Core/Infra) kurallara tam uyumlu olarak inşa et.
  ├── Guard clause'lar ile erken doğrulamaları yaz (Max girinti: 2).
  └── Metot boyutunu 15-25 satır sınırında tut.

[Adım 3: Veri Erişimi ve EF Core Optimizasyonu]
  ├── AsNoTracking + Select projeksiyonu uygula.
  └── CancellationToken'ı tüm asenkron çağrılara geçir.

[Adım 4: Controller Action Uygulaması (Skinny Controller)]
  ├── [HttpGet] ve [HttpPost] metodlarını ayır, [ValidateAntiForgeryToken] ekle.
  ├── ModelState doğrula ve PRG (Post-Redirect-Get) uygula.
  └── Asla doğrudan DbContext inject etme.

[Adım 5: İzci Kuralı & Derleme Kontrolü]
  ├── Dokunulan çevredeki formatting ve gereksiz using'leri temizle.
  └── 'dotnet build' çalıştır; sıfır hata ve sıfır uyarı ile tamamla.
```

---

## 🔍 8. Backend Geliştiricisinin 10 Maddelik Temiz Kod & Kalite Kapısı

| # | Kontrol Kriteri | Beklenen Standart | İhlal Durumunda |
| :--- | :--- | :--- | :--- |
| **1** | **Metot Uzunluğu** | Maksimum 15 - 25 satır | Aşıyorsa ➔ Alt metotlara böl |
| **2** | **Parametre Sayısı** | Maksimum 3 parametre (4+ parametre yasak) | 4+ ise ➔ Command/Record yap |
| **3** | **Bayrak Parametresi** | `bool flag` parametresi bulunamaz | Varsa ➔ İki açık metoda böl |
| **4** | **Guard Clauses** | İç içe `if-else` piramidi yasaktır (Max girinti: 2) | Derinlik varsa ➔ Guard clause ile erken dön |
| **5** | **Tasarım Kalıpları** | Şartnamedeki GoF/Enterprise kalıpları eksiksiz ve kanonik uygulandı mı? | Eksikse ➔ Deseni uygula |
| **6** | **Sınıf Sınırı & SRP** | Maksimum 250-300 satır; God object yasağı | Aşıyorsa ➔ SRP'ye göre böl |
| **7** | **Result Deseni** | İş kuralı akışında Exception fırlatılamaz | Fırlatılıyorsa ➔ Result dön |
| **8** | **Entity İzolasyonu** | Controller veya View asla doğrudan Entity bağlayamaz | Entity varsa ➔ ViewModel/Command yap |
| **9** | **AsNoTracking & CancellationToken** | Okuma sorgularında AsNoTracking ve CancellationToken zorunlu | Eksikse ➔ Ekle |
| **10**| **0 Compiler Warning** | `dotnet build` çıktısında sıfır sarı uyarı | Uyarı varsa ➔ RED |
