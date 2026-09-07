---
name: backend-engineer
description: C# 14, .NET 10, ASP.NET Core MVC Controller/Action methodları, EF Core 10 veri erişimi, Result deseni, OOP ve Clean Code geliştirme kurallarını eksiksiz uygular.
---

# .NET 10 Backend Geliştirici Uzmanlık Rehberi (Clean Architecture & Craftsmanship Edition)

Bu rehber, projedeki backend geliştirmelerinin mimari değişmezlere uyumlu; asenkron, yüksek performanslı, nesne yönelimli programlama (OOP) ve **Temiz Kod (Clean Code)** standartlarında üretilmesini sağlayan kuralları içerir.

> [!IMPORTANT]
> Tüm geliştirmelerde proje anayasası olan [05-backend-development-clean-code-standards.md](file:///C:/Users/Ertekin/.gemini/antigravity-ide/scratch/DotNet10WebApp/.agents/rules/05-backend-development-clean-code-standards.md) kurallarına harfiyen uyulması zorunludur.

---

## 📚 1. Dayandığı Literatür ve Standartlar

1. **Clean Code: A Handbook of Agile Software Craftsmanship** (Robert C. Martin - Uncle Bob)
2. **Refactoring: Improving the Design of Existing Code** (Martin Fowler)
3. **C# in Depth (4th Edition)** (Jon Skeet) — Dil evrimi, tip güvenliği ve derleyici optimizasyonları
4. **CLR via C# (4th Edition)** (Jeffrey Richter) — Bellek yönetimi, GC ve thread-safety
5. **Concurrency in C# Cookbook (2nd Edition)** (Stephen Cleary) — TAP ve asenkron kalıplar
6. **Design Patterns: Elements of Reusable Object-Oriented Software** (GoF)

---

## ⚡ 2. Fonksiyon ve Metot Yönetimi (Function Craftsmanship)

1. **Tek Sorumluluk (Do One Thing):**
   - Bir fonksiyon yalnızca tek bir iş yapmalı, onu mükemmel yapmalı ve yalnızca onu yapmalıdır.
   - Fonksiyon içinde farklı soyutlama katmanları (Örn: HTTP header okuma + SQL sorgusu oluşturma + JSON serileştirme) karıştırılamaz.
2. **Boyut Sınırı: Maksimum 15 - 25 Satır:**
   - Bir metot ekranı kaydırmadan tek bakışta okunabilmelidir. 25 satırı aşan metotlar SRP ihlalidir; özel `private` alt metotlara bölünmelidir.
3. **Parametre Sayısı Kuralı (Niladic / Monadic / Dyadic):**
   - İdeal: 0 veya 1 parametre. En fazla: 2 parametre.
   - **🔴 4 veya Daha Fazla Parametre KESİN YASAK:** 4 ve üzeri parametre gerekiyorsa, parametreler bir `Command`, `Record` veya `Parameter Object` altında toplanmalıdır.
4. **Bayrak (Boolean Flag) Parametre Yasağı:**
   - Bir metoda `bool isSpecial`, `bool sendEmail` gibi parametre geçilemez. İki ayrı açık isimli metot yazılmalıdır (`ProcessStandardOrder`, `ProcessPriorityOrder`).
5. **Komut - Sorgu Ayrımı (CQS - Command Query Separation):**
   - Bir fonksiyon ya bir durumu değiştirmeli (Command) ya da soruya cevap vermelidir (Query).
   - Gizli yan etkiler (Side Effects) yasaktır. Örn: `GetUser(id)` metodu arkada sayacı artıramaz veya veritabanını güncelleyemez.
6. **Guard Clauses & Fail-Fast (Max Girinti: 2):**
   - İç içe girmiş derin `if-else` piramitleri yasaktır.
   - Hata ve geçersiz durumlar metodun en başında `guard clause` ile kontrol edilip derhal dönülmelidir (`return`).

---

## 🏛️ 3. Sınıf Kapsamı ve Tasarımı (Class Craftsmanship)

1. **Sınıf Boyutu: Maksimum 200 - 300 Satır:**
   - 300 satırı aşan sınıflar "God Object" kokusu taşır ve bölünmelidir.
   - `CommonHelper`, `GeneralManager`, `Utils` gibi her işe bakan torba sınıflar yasaktır. İsim sorumluluğu açıkça yansıtmalıdır (`PasswordHasher`, `InvoicePdfGenerator`).
2. **Yüksek Bağdaşıklık (High Cohesion):**
   - Sınıfın tüm metotları sınıfın alanlarını (fields / dependencies) ortaklaşa kullanmalıdır. İki bağımsız küme oluşturan metotlar varsa sınıf 2 ayrı sınıfa bölünmelidir.
3. **Demeter Yasası (Law of Demeter - En Az Bilgi İlkesi):**
   - Tren kazası gibi zincirleme çağrılar yasaktır:  
     `order.Customer.Address.City.ZipCode` yerine `order.GetBillingZipCode()` kullanılmalıdır.
4. **Sorma, Emret (Tell, Don't Ask):**
   - Nesnenin iç verisini dışarı çekip dışarıda karar vermek yerine nesneye emredilmelidir:  
     `if (acc.Balance >= amt) acc.Balance -= amt;` yerine `acc.Withdraw(amt);`.

---

## 🧩 4. Nesne Yönelimli Programlama (OOP) ve Clean Architecture Kuralları

1. **Kapsülleme (Encapsulation) & İnvariyant Koruma:**
   - Public field ve public setter yasaktır. İç durum daima metotlar veya `private set` ile korunur. Nesne asla geçersiz bir durumda yaratılamaz.
2. **Kalıtım Yerine Bileşim (Composition over Inheritance):**
   - Sırf kod paylaşmak için çok katmanlı miras ağaçları (`BaseService -> GenericService`) kurulmaz. Davranışlar arayüzler ve Dependency Injection ile birleştirilir.
3. **Çok Biçimlilik vs Switch/If (Polymorphism over Type-Checking):**
   - Kodun her yerine yayılan enum tabanlı `switch-case` dallanmaları yerine Polymorphism ve Strateji Deseni (Strategy Pattern) uygulanır.
4. **İş Kurallarında Exception Yasağı (Result Deseni):**
   - Beklenen iş kuralı durumlarında `throw new Exception()` yasaktır. Tüm servis metotları `Task<Result>` veya `Task<Result<T>>` döner.
5. **Primary Constructors & Modern C# 14 Sözdizimi:**
   - Bağımlılıklar sınıf tanımında primary constructor ile alınır.
   - Dizi/liste tanımlarında Collection Expressions (`["A", "B"]`) kullanılır.
   - Parametre doğrulamalarında `ArgumentNullException.ThrowIfNull(param)` kullanılır.

---

## 💻 5. Somut Kodlama Örnekleri (KÖTÜ vs İYİ)

### A. Metot Tasarımı, Guard Clauses ve Parametre Yönetimi
* **KÖTÜ (Anti-Pattern):**
  ```csharp
  // KÖTÜ: 
  // 1. 5 parametreli (Polyadic)
  // 2. Boolean flag var (isVip)
  // 3. İç içe derin if blokları (Arrow pattern)
  // 4. Exception ile iş akışı kontrol ediliyor
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
  // İYİ:
  // 1. Parametreler Command nesnesinde toplandı
  // 2. Erken dönüş (Guard clauses) ile sıfır derinlik
  // 3. Result deseni ile tipli dönüş
  // 4. CancellationToken ile asenkron kontrol
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

### B. EF Core 10 Veri Erişimi ve AsSplitQuery
```csharp
public async Task<Result<UserProfileViewModel>> GetProfileAsync(Guid id, CancellationToken ct = default)
{
    var profile = await dbContext.Users
        .AsNoTracking()
        .Where(u => u.Id == id && u.IsActive)
        .Select(u => new UserProfileViewModel
        {
            FullName = u.FullName,
            Email = u.Email
        })
        .FirstOrDefaultAsync(ct);

    if (profile is null)
    {
        return Result<UserProfileViewModel>.Failure("Kullanıcı bulunamadı veya hesap pasif durumda.");
    }

    return Result<UserProfileViewModel>.Success(profile);
}
```

### C. İnce Controller (Skinny Controller) ve PRG Deseni
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
[Adım 1: Sözleşme ve Gereksinim İncelemesi]
  ├── Mimarın IService ve DTO/Command sözleşmesini oku.
  └── Analistin Gherkin kabul kriterlerindeki sınır durumları çıkar.

[Adım 2: Domain Modeli ve İş Kuralları (Clean Code)]
  ├── Guard clause'lar ile erken doğrulamaları yaz (Max girinti: 2).
  ├── Parametreleri Command nesnesi altında topla (Max 3 parametre).
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
| **5** | **Sınıf Sınırı & SRP** | Maksimum 250-300 satır; God object yasağı | Aşıyorsa ➔ SRP'ye göre böl |
| **6** | **Result Deseni** | İş kuralı akışında Exception fırlatılamaz | Fırlatılıyorsa ➔ Result dön |
| **7** | **Entity İzolasyonu** | Controller veya View asla doğrudan Entity bağlayamaz | Entity varsa ➔ ViewModel/Command yap |
| **8** | **AsNoTracking & CancellationToken** | Okuma sorgularında AsNoTracking ve CancellationToken zorunlu | Eksikse ➔ Ekle |
| **9** | **0 Compiler Warning** | `dotnet build` çıktısında sıfır sarı uyarı | Uyarı varsa ➔ RED |
| **10**| **İzci Kuralı (Boy Scout)**| Dokunulan dosyadaki gereksiz using ve kötü isimler temizlendi mi? | Temizlenmediyse ➔ Refactor et |
