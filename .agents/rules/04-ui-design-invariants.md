# Arayüz, Deneyim ve Razor Tasarım Değişmezleri (UI/UX & Razor Invariants)

Bu kural, .NET 10 projesinde **Bootstrap 5.3**, **Razor Views (.cshtml)** ve **Kullanıcı Deneyimi (UX)** standartlarının tavizsiz uygulanmasını güvence altına alır.

## 📚 Dayandığı Literatür ve Standartlar
- **The Design of Everyday Things** (Don Norman)
- **Don't Make Me Think, Revisited** (Steve Krug)
- **Refactoring UI** (Adam Wathan & Steve Schoger)
- **WCAG 2.2 Level AA (Web Content Accessibility Guidelines - W3C)**
- **Bootstrap 5.3 Design System & Official Guidelines**
- **ASP.NET Core Razor Engine & Tag Helpers Specification (Microsoft Learn)**

---

## 1. Tasarım Sistemi ve Görsel Bütünlük Kuralları

### 🎨 Kural 1: Satır İçi (Inline) CSS Kesinlikle Yasaktır
- `.cshtml` dosyaları içinde `<div style="color: red; margin-top: 10px;">` gibi keyfi satır içi stiller **asla kullanılamaz**.
- Tüm stil ve aralıklar Bootstrap 5.3 utility sınıflarından (`text-danger`, `mt-2`, `p-3`, `gap-2`) veya merkezi tasarım CSS dosyasından gelmelidir.

### 🎨 Kural 2: Keyfi Renk ve Piksel Yasağı (Design Tokens)
- Rastgele hex kodları (`#4A90E2`) veya piksel değerleri verilemez.
- Yalnızca anlamsal (semantic) Bootstrap tasarım token'ları kullanılmalıdır:
  - Birincil Eylemler: `btn-primary`, `text-primary`, `bg-primary-subtle`
  - Başarı & Onay: `alert-success`, `badge-success`, `text-success`
  - Tehlike & Hata: `alert-danger`, `text-danger`, `border-danger`
  - Nötr & Arka Plan: `bg-light`, `text-muted`, `border-secondary-subtle`

### 🎨 Kural 3: WCAG 2.2 AA Erişilebilirlik ve Kontrast Zorunluluğu
- Metin ile arka plan arasındaki renk kontrastı **en az 4.5:1** (büyük metinler için en az 3:1) olmak zorundadır.
- Placeholder asla form etiketi (`<label>`) yerine geçemez. Her form input'unun ilişkili bir `<label asp-for="...">` etiketi olmalıdır.
- Tüm ikonlu butonlarda ekran okuyucular için `aria-label` veya gizli metin (`<span class="visually-hidden">`) bulunmalıdır.

---

## 2. Razor & ASP.NET Core MVC Kodlama Standartları

### 💻 Kural 4: Modern Tag Helper Kullanımı Şarttır (Legacy Helper Yasağı)
- Eski nesil HTML Helper'lar (`@Html.TextBoxFor()`, `@Html.DropDownListFor()`) yerine her zaman ASP.NET Core Tag Helper'ları kullanılmalıdır:
  - Form: `<form asp-action="Edit" asp-controller="Profile" method="post">`
  - Input: `<input asp-for="Email" class="form-control" />`
  - Label: `<label asp-for="Email" class="form-label"></label>`
  - Validasyon: `<span asp-validation-for="Email" class="invalid-feedback d-block"></span>`
  - Özet: `<div asp-validation-summary="ModelOnly" class="alert alert-danger"></div>`

### 💻 Kural 5: Sıfır `@Html.Raw()` Toleransı (XSS Koruması)
- Razor sayfalarında `@Html.Raw()` kullanımı **kesinlikle yasaktır**. Tüm dinamik veriler Razor motorunun otomatik HTML encoding korumasından geçmelidir.

### 💻 Kural 6: Monolitik View Yasağı (Zorunlu Parçalama)
- 250 satırı aşan veya tekrar eden UI blokları (Örn: ürün kartı, kullanıcı rozeti, yorum listesi) ana sayfada tutulamaz:
  - Küçük şablonlar için: **`Partial View`** (`_UserCard.cshtml`)
  - Kendi veri bağımlılığı olan bileşenler için: **`ViewComponent`** (`NavigationMenuViewComponent`)

---

## 3. Kullanıcı Deneyimi (UX) ve Etkileşim Standartları

### ⚡ Kural 7: 5 Zorunlu Bileşen Durumu (Component States)
Arayüzdeki her buton ve etkileşimli eleman şu 5 durumu desteklemelidir:
1. `Default` (Varsayılan şık görünüm)
2. `Hover` (Üzerine gelindiğinde belirginleşme)
3. `Focus-visible` (Klavyeyle gezinenler için 2px mavi odak halkası)
4. `Disabled` (Tıklanamaz durum, opaklık düşüşü)
5. `Loading` (Tıklandığı anda form gönderilirken buton içine dönen `spinner-border-sm` eklenmesi ve butonun `disabled` olması).

### ⚡ Kural 8: Boş Durum (Empty State) Tasarımı
- Veri bulunmayan listelerde (Örn: *"Henüz ürün eklenmemiş"*) boş ve beyaz bir sayfa bırakılamaz.
- Ortalanmış bir illüstrasyon/ikon, açıklayıcı bir metin ve kullanıcıyı harekete geçirecek birincil eylem butonu içeren bir **Empty State** kartı gösterilmelidir.
