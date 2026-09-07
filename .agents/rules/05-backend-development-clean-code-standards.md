# Backend Geliştirme ve Temiz Kod (Clean Code) Kuralları

Bu kural, backend geliştiricilerinin (.NET 10 / C# 14) kod tabanında uygulayacağı **fonksiyon yönetimi**, **sınıf tasarımı**, **nesne yönelimli programlama (OOP)** ve **temiz kod (Clean Code)** anayasasını belirler. Tüm backend kodları bu kurallara uymak zorundadır.

---

## 📚 Dayandığı Literatür ve Standartlar
- **Clean Code: A Handbook of Agile Software Craftsmanship** (Robert C. Martin - Uncle Bob)
- **Refactoring: Improving the Design of Existing Code** (Martin Fowler)
- **Design Patterns: Elements of Reusable Object-Oriented Software** (Gang of Four - GoF)
- **Working Effectively with Legacy Code** (Michael Feathers)
- **Code Complete (2nd Edition)** (Steve McConnell)
- **C# Coding Conventions & Architecture Guides** (Microsoft)

---

## ⚡ BÖLÜM 1: Fonksiyon ve Metot Yönetimi (Function Craftsmanship)

### 1. Tek Bir İş Yapma Kuralı (Do One Thing)
- Bir fonksiyon yalnızca **tek bir iş yapmalı**, onu **mükemmel yapmalı** ve **yalnızca onu yapmalıdır**.
- Bir fonksiyon içinde birden fazla soyutlama seviyesi (Level of Abstraction) bulunamaz. (Örn: Hem HTTP isteği ayrıştırıp, hem SQL sorgusu hazırlayıp, hem de hash hesaplayan metotlar yasaktır).

### 2. Boyut Sınırı: Maksimum 15 - 25 Satır
- Bir metot dikey kaydırma çubuğuna (scroll) ihtiyaç duymadan tek bakışta anlaşılmalıdır.
- 25 satırı aşan metotlar SRP (Single Responsibility) ihlalidir; alt özel metotlara (`private helper`) bölünmelidir.

### 3. Parametre Sayısı Sınırları (Clean Code Metric)
- **İdeal:** 0 parametre (Niladic) veya 1 parametre (Monadic).
- **Kabul Edilebilir:** En fazla 2 parametre (Dyadic).
- **İnceleme Gerektirir:** 3 parametre (Triadic).
- **🔴 KESİN YASAK:** 4 veya daha fazla parametre (Polyadic).
  - *Kural:* 4 veya daha fazla parametre gerekiyorsa, bu parametreler bir `Command`, `Record` veya `Parameter Object` altında toplanmalıdır.
  ```csharp
  // KÖTÜ: 5 parametreli metot (Okuması ve testi kabus)
  public Task RegisterUser(string name, string email, string phone, int roleId, bool sendEmail);

  // İYİ: Niyet belirten Command record nesnesi
  public Task<Result<Guid>> RegisterUserAsync(RegisterUserCommand command, CancellationToken ct = default);
  ```

### 4. Bayrak (Boolean Flag) Parametre Yasağı
- Bir metoda `bool isSpecial`, `bool sendNotification` gibi bayrak parametreleri geçmek, o fonksiyonun en az iki farklı iş yaptığının açık kanıtıdır.
- Bayrak parametresi yerine iki ayrı, açık niyetli metot yazılmalıdır:
  ```csharp
  // KÖTÜ:
  public void ProcessOrder(Order order, bool isPriority);

  // İYİ:
  public void ProcessStandardOrder(Order order);
  public void ProcessPriorityOrder(Order order);
  ```

### 5. Komut - Sorgu Ayrımı (Command Query Separation - CQS)
- Bir metot ya bir durumu değiştirmelidir (Command) ya da bir soruya cevap vermelidir (Query).
- **Asla ikisini birden yapmamalıdır.**
- *Örnek İhlal:* `GetUser(Guid id)` çağrıldığında arka planda kullanıcının son giriş tarihini güncellemek veya oturum sayacını artırmak gibi gizli yan etkiler (Side Effects) **kesinlikle yasaktır**.

### 6. Erken Dönüş ve Koruma İfadeleri (Guard Clauses & Fail-Fast)
- İç içe girmiş `if-else` piramitleri (Arrow Anti-Pattern) yasaktır.
- Maksimum girinti (indentation) seviyesi **2** olmalıdır.
- Hata veya geçersiz durumlar metodun en başında kontrol edilip derhal dönülmelidir (`return` / `guard clause`):
  ```csharp
  // KÖTÜ: İç içe derin if piramidi
  public Result Process(User? user)
  {
      if (user != null)
      {
          if (user.IsActive)
          {
              if (user.HasSufficientBalance())
              {
                  // Asıl iş...
                  return Result.Success();
              }
              else { return Result.Failure("Yetersiz bakiye"); }
          }
          else { return Result.Failure("Kullanıcı pasif"); }
      }
      return Result.Failure("Kullanıcı bulunamadı");
  }

  // İYİ: Guard clauses ile düz ve temiz akış
  public Result Process(User? user)
  {
      if (user is null) return Result.Failure("Kullanıcı bulunamadı");
      if (!user.IsActive) return Result.Failure("Kullanıcı pasif");
      if (!user.HasSufficientBalance()) return Result.Failure("Yetersiz bakiye");

      // Asıl iş mantığı engelsiz akar...
      return Result.Success();
  }
  ```

---

## 🏛️ BÖLÜM 2: Sınıf Kapsamı ve Tasarımı (Class Craftsmanship)

### 1. Sınıf Boyutu ve Sorumluluk Sınırı
- Bir sınıf maksimum **200-300 satır** olmalıdır.
- **God Object / Helper / Manager Yasağı:** "Her işi yapan" devasa `CommonHelper`, `GeneralManager`, `Utils` sınıfları kesinlikle yasaktır.
- Sınıf ismi net bir sorumluluğu ifade etmelidir (Örn: `PasswordHasher`, `InvoicePdfGenerator`, `OrderCancellationValidator`).

### 2. Yüksek Bağdaşıklık (High Cohesion)
- Bir sınıfın tüm metotları, sınıfın alanlarını (fields / dependencies) ortaklaşa kullanmalıdır.
- Eğer bir sınıfın 3 metodu sadece `_repoA`'yı, diğer 3 metodu sadece `_serviceB`'yi kullanıyorsa, bu sınıf aslında iki ayrı sınıftır ve derhal bölünmelidir.

### 3. Demeter Yasası (Law of Demeter - En Az Bilgi İlkesi)
- Bir nesne sadece kendi doğrudan tanıdığı arkadaşlarının metotlarını çağırmalıdır.
- Tren kazası (Train Wreck) gibi zincirleme çağrılar yasaktır:
  ```csharp
  // KÖTÜ: Demeter yasası ihlali (İç yapıya aşırı bağımlılık)
  var zipCode = order.Customer.BillingAddress.City.ZipCode;

  // İYİ: İlgili nesneye emretme (Tell, Don't Ask)
  var zipCode = order.GetBillingZipCode();
  ```

### 4. Sorma, Emret (Tell, Don't Ask)
- Nesnelerin iç durumunu dışarı çekip dışarıda karar vermek yerine, nesneye ne yapması gerektiği emredilmelidir:
  ```csharp
  // KÖTÜ: Nesnenin iç verisini sorgulayıp dışarıdan durumu değiştirmek
  if (account.Balance >= amount)
  {
      account.Balance -= amount;
  }

  // İYİ: Nesneye emretmek ve invariyantı içeride korumak
  account.Withdraw(amount);
  ```

---

## 🧩 BÖLÜM 3: Nesne Yönelimli Programlama (OOP) ve SOLID Kuralları

### 1. Kapsülleme (Encapsulation) ve İç Durumun Korunması
- Sınıf değişkenleri (fields) daima `private` olmalıdır.
- Public getter olan alanların setter'ları mutlaka `private set` veya `init` olmalıdır.
- Bir domain nesnesi **asla geçersiz (invalid) bir durumda yaratılamaz ve var olamaz**. Durum doğrulaması nesnenin kendi sınırları içinde yapılmalıdır.

### 2. Kalıtım Yerine Bileşim (Composition over Inheritance)
- Yalnızca kod tekrarını önlemek için derin miras ağaçları (`BaseService -> GenericService -> CustomService`) kurmak yasaktır.
- Yeniden kullanılabilirlik (reusability) daima **Arayüzler (Interfaces)** ve **Bağımlılık Enjeksiyonu (Composition via DI)** ile sağlanmalıdır.

### 3. Tip Kontrolü Yerine Çok Biçimlilik (Polymorphism vs Switch/If)
- Tip veya enum ayrımı yaparak iş mantığı dallandırmak yerine Polymorphism veya Strateji Deseni (Strategy Pattern) kullanılmalıdır:
  ```csharp
  // KÖTÜ: Kodun her yerine yayılan switch-case veya if-else blokları
  public decimal CalculateDiscount(CustomerType type, decimal amount) => type switch
  {
      CustomerType.Standard => amount * 0.05m,
      CustomerType.Premium => amount * 0.15m,
      CustomerType.Vip => amount * 0.25m,
      _ => 0m
  };

  // İYİ: Strateji arayüzü ile açık-kapalı ilkesine (OCP) uygun mimari
  public interface IDiscountStrategy { decimal Calculate(decimal amount); }
  ```

### 4. Liskov Yerine Geçme İlkesi (LSP)
- Türetilen hiçbir sınıf, üst sınıfın veya arayüzün vaat ettiği davranışı kısıtlayamaz veya `throw new NotImplementedException()` atamaz. Eğer bir metodu uygulayamıyorsan, o sınıf o arayüzden türememelidir (Arayüz Ayrımı - ISP).

---

## 🧹 BÖLÜM 4: Temiz Kod (Clean Code) Temel Değişmezleri

### 1. Niyet Belirten İsimlendirme (Intent-Revealing Names)
- Değişken, fonksiyon ve sınıf adları şu 3 soruya net yanıt vermelidir: **Neden var? Ne yapar? Nasıl kullanılır?**
- Tek harfli veya anlamsız isimler yasaktır (`d`, `usr`, `temp`, `data`, `res`, `flag`).
- Kısaltma yerine açık isimler kullanılmalıdır (`btnSubmit` yerine `submitButton`, `ctx` yerine `dbContext`).

### 2. İzci Kuralı (The Boy Scout Rule)
> *"Her dokunduğun dosyayı, bulduğundan daha temiz bırak."*
- Bir dosyada bug düzeltirken veya yeni özellik eklerken; yakınındaki kötü isimlendirilmiş değişkeni düzelt, gereksiz using'leri temizle, formatting bozukluğunu gider. Kod tabanı zamanla çürümez, sürekli gençleşir.

### 3. Yorum Satırı Kokusu (Comments as Code Smell)
- Kötü kodu açıklamak için yorum yazılmaz; kod kendini anlatacak kadar açık hale getirilir.
- Yalnızca **"Neden"** sorusunun cevabı (örneğin üçüncü taraf bir API'nin garip bir davranışını baypas etmek veya yasal bir kuralı belgelemek için) yorum olarak yazılabilir. **"Ne"** yapıldığını anlatan yorumlar temizlenmelidir.

### 4. Sihirli Değerler Yasağı (No Magic Numbers or Strings)
- Kodun içinde `if (status == 3)` veya `timeout = 86400` gibi bağlamsız değerler bulunamaz.
- Bunlar anlamlı `enum` veya `const` değerlerine bağlanmalıdır (`OrderStatus.Shipped`, `TimeConstants.OneDayInSeconds`).

### 5. DRY (Don't Repeat Yourself) & YAGNI
- İş kuralı mantığı tek bir yerde yaşamalıdır.
- Ancak henüz ortada olmayan varsayımsal ihtiyaçlar için karmaşık altyapılar inşa etmek (YAGNI - You Aren't Gonna Need It) yasaktır. İhtiyaç doğduğunda refactor edilir.

---

## 🔍 BÖLÜM 5: Backend Temiz Kod Onay Kapısı (10 Madde)

| # | Kriter | Sınır / Standart | İhlal Durumu |
| :--- | :--- | :--- | :--- |
| **1** | **Metot Satır Sınırı** | Maksimum 25 satır | Aşıyorsa ➔ Parçala |
| **2** | **Parametre Sayısı** | Maksimum 3 parametre (4+ yasak) | 4+ ise ➔ Parameter Object / Command yap |
| **3** | **Bayrak Parametresi** | Metotta `bool flag` parametresi bulunamaz | Varsa ➔ İki ayrı metota böl |
| **4** | **Guard Clauses** | İç içe derin `if` blokları yasaktır (Max girinti: 2) | Derinlik varsa ➔ Guard clause ile ters çevir |
| **5** | **Sınıf Satır Sınırı** | Maksimum 250-300 satır | Aşıyorsa ➔ SRP doğrultusunda böl |
| **6** | **CQS İhlali** | Durum değiştiren metot veri dönmemeli / yan etki yapmamalı | Varsa ➔ Ayrıştır |
| **7** | **Kapsülleme** | Public field veya kontrolsüz `public set` bulunamaz | Varsa ➔ `private set` ve metot ile koru |
| **8** | **İsimlendirme** | Anlamsız kısaltma (`temp`, `data`, `res`) bulunamaz | Varsa ➔ Anlamlı isim ver |
| **9** | **Sihirli Değerler** | Kod içinde çıplak sayı/metin bulunamaz | Varsa ➔ `const` veya `enum` yap |
| **10**| **Yorum Kirliliği** | Kodu anlatan gereksiz yorumlar bulunamaz | Varsa ➔ Kodu netleştir, yorumu sil |
