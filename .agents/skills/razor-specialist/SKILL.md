---
name: razor-specialist
description: UI/UX şartnamesini ve ViewModel kontratını alarak modern ASP.NET Core Tag Helper'ları, Bootstrap 5.3 bileşenleri, Partial View'lar ve hem Unobtrusive hem Vanilla JS Validasyonu ile duyarlı .cshtml sayfaları kodlar.
---

# Razor & Bootstrap Uzmanlık Rehberi (Production-Grade Razor Edition)

Bu rehber, UI/UX şartnamesi ve mimari `ViewModel` kontratlarına %100 sadık kalarak modern, yüksek performanslı, erişilebilir ve güvenli `.cshtml` sayfaları geliştirme prosedürlerini içerir.

---

## 📚 1. Dayandığı Literatür ve Standartlar

1. **ASP.NET Core Razor Syntax & Tag Helpers Guidelines** (Microsoft Learn)
2. **Bootstrap 5.3 Official Documentation & Component Architecture**
3. **HTML Living Standard & WAI-ARIA 1.2** (WHATWG / W3C)
4. **CSS Secrets: Better Solutions to Everyday Web Problems** (Lea Verou)
5. **High Performance Browser Networking** (Ilya Grigorik) — Cache busting ve asset yükleme

---

## 🏗️ 2. Razor Mimarisinin Kırmızı Çizgileri

1. **İş Mantığı Yasağı:** View dosyaları (`.cshtml`) içinde asla iş mantığı, linq filtreleri veya veri tabanı/servis çağrısı (`@inject AppDbContext`) yapılamaz. View yalnızca hazır `ViewModel` verisini görselleştirir.
2. **Satır İçi Stil (Inline CSS) Yasağı:** `.cshtml` içinde `style="..."` yazmak kesinlikle yasaktır. Tüm görselleme Bootstrap sınıfları veya proje CSS dosyalarıyla yönetilir.
3. **Sıfır Çıplak HTML Form:** `<form action="...">` yerine mutlaka Tag Helper'lı `<form asp-action="..." method="post">` kullanılır (otomatik Antiforgery token üretimi için).
4. **Güçlü Tipli Model Bildirimi:** Her View dosyasının en üstünde `@model Namespace.ViewModel` bildirimi zorunludur. `dynamic` veya çıplak `ViewBag` bağımlılığı yasaktır.

---

## 💻 3. Tam Kapsamlı Üretim Seviyesi Şablon (Production Template)

Aşağıdaki şablon form hiyerarşisini, geri bildirim alertlerini, loading durumunu ve çift tıklama engellemesini eksiksiz uygular:

```cshtml
@model MyApp.Web.ViewModels.UpdateProfileViewModel
@{
    ViewData["Title"] = "Profil Düzenleme";
}

<div class="container py-4 py-md-5">
    <div class="row justify-content-center">
        <div class="col-12 col-md-8 col-lg-6">

            @* 1. Geri Bildirim ve Başarı / Hata Mesajları *@
            @if (TempData["SuccessMessage"] is string successMsg)
            {
                <div class="alert alert-success alert-dismissible fade show shadow-sm border-0 rounded-3 mb-4" role="alert">
                    <i class="bi bi-check-circle-fill me-2"></i>@successMsg
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Kapat"></button>
                </div>
            }

            <div asp-validation-summary="ModelOnly" class="alert alert-danger shadow-sm border-0 rounded-3 mb-4" role="alert"></div>

            @* 2. Ana Kart ve Form Bileşeni *@
            <div class="card shadow-sm border-0 rounded-4 p-4 p-md-5">
                
                @* Kart Başlığı ve İkonu *@
                <div class="d-flex align-items-center mb-4 pb-3 border-bottom">
                    <div class="bg-primary-subtle text-primary p-3 rounded-circle me-3">
                        <i class="bi bi-person-gear fs-3"></i>
                    </div>
                    <div>
                        <h4 class="fw-bold mb-0 text-dark">Profil Bilgileri</h4>
                        <small class="text-muted">Kişisel hesap ve iletişim detaylarınızı güncelleyin.</small>
                    </div>
                </div>

                @* Form Tanımı *@
                <form asp-action="Edit" asp-controller="Profile" method="post" id="profileForm" novalidate>
                    
                    @* Ad Soyad Alanı *@
                    <div class="mb-3">
                        <label asp-for="FullName" class="form-label fw-semibold text-secondary"></label>
                        <input asp-for="FullName" class="form-control rounded-3" placeholder="Adınızı ve soyadınızı giriniz" />
                        <span asp-validation-for="FullName" class="text-danger small mt-1 d-block"></span>
                    </div>

                    @* E-Posta Alanı *@
                    <div class="mb-4">
                        <label asp-for="Email" class="form-label fw-semibold text-secondary"></label>
                        <input asp-for="Email" class="form-control rounded-3" placeholder="ornek@example.com" />
                        <span asp-validation-for="Email" class="text-danger small mt-1 d-block"></span>
                        <div class="form-text text-muted">Resmi bildirimler bu adrese iletilecektir.</div>
                    </div>

                    @* Buton Grubu *@
                    <div class="d-flex justify-content-end gap-2 pt-3 border-top">
                        <a asp-action="Index" asp-controller="Home" class="btn btn-outline-secondary px-4 py-2 rounded-3">İptal</a>
                        <button type="submit" class="btn btn-primary px-4 py-2 rounded-3 shadow-sm" id="btnSubmit">
                            <span class="spinner-border spinner-border-sm me-2 d-none" id="btnSpinner" role="status" aria-hidden="true"></span>
                            <i class="bi bi-check2 me-1" id="btnIcon"></i>Değişiklikleri Kaydet
                        </button>
                    </div>
                </form>

            </div>
        </div>
    </div>
</div>

@section Scripts {
    <partial name="_ValidationScriptsPartial" />

    <script>
        document.addEventListener("DOMContentLoaded", function () {
            const form = document.getElementById("profileForm");
            const btnSubmit = document.getElementById("btnSubmit");
            const btnSpinner = document.getElementById("btnSpinner");
            const btnIcon = document.getElementById("btnIcon");

            form.addEventListener("submit", function (e) {
                // Hem jQuery Validate hem de modern HTML5 constraint validation desteği
                let isValid = true;
                if (window.jQuery && typeof window.jQuery(form).valid === "function") {
                    isValid = window.jQuery(form).valid();
                } else if (typeof form.checkValidity === "function") {
                    isValid = form.checkValidity();
                    if (!isValid) {
                        form.classList.add("was-validated");
                    }
                }

                if (isValid) {
                    btnSubmit.setAttribute("disabled", "disabled");
                    btnSpinner.classList.remove("d-none");
                    btnIcon.classList.add("d-none");
                }
            });
        });
    </script>
}
```

---

## 🧩 4. ViewComponent vs Partial View Kullanım Kuralı

- **Partial View (`_Partial.cshtml`):**
  - Kendi verisini çekmez; ana sayfadan ona gönderilen modeli render eder.
  - *Kullanım Alanı:* Kart tasarımları, ortak tablo satırları, modal gövdeleri.
  - *Çağrı:* `<partial name="_UserCard" model="item" />`
- **ViewComponent:**
  - Kendi C# sınıfı ve Dependency Injection yeteneği vardır; bağımsız olarak veri tabanından veya cache'den veri çeker.
  - *Kullanım Alanı:* Üst menü profil özeti, sepet sayacı, dinamik bildirim çubuğu.
  - *Çağrı:* `@await Component.InvokeAsync("NavigationUserSummary")`

---

## 📋 5. Adım Adım Razor Kodlama Protokolü (SOP)

```text
[Adım 1: Sözleşme & Şartname İnceleme]
  ├── Mimarın ViewModel sınıfını kontrol et (@model bildirimini hazırla).
  └── UI/UX tasarımcısının grid ve renk token'larını incele.

[Adım 2: Sayfa İskeleti ve Form Kodlaması]
  ├── 'asp-controller' ve 'asp-action' ile form Tag Helper'ı oluştur.
  ├── Tüm alanlara 'asp-for' ve 'asp-validation-for' bağla.
  └── Kart yapısını 'rounded-4' ve 'shadow-sm' ile yapılandır.

[Adım 3: Geri Bildirim ve Durum Yönetimi]
  ├── 'TempData' alert kutusunu ve 'ModelOnly' validasyon özetini yerleştir.
  └── Butona spinner ve çift tıklama engelleyici JS dinleyicisini ekle.

[Adım 4: Script & Doğrulama Entegrasyonu]
  ├── '@section Scripts' içinde '_ValidationScriptsPartial' çağrısını ekle.
  └── Statik dosya linklerine 'asp-append-version="true"' iliştir.

[Adım 5: Görsel Doğrulama & Teslim]
  └── Sayfayı derle ve QA ile UI/UX tasarımcısına teslim et.
```

---

## 🔍 6. Razor Uzmanının 10 Maddelik Kalite Kapısı

| # | Kontrol Maddesi | Beklenen Standart | İhlal Durumunda |
| :--- | :--- | :--- | :--- |
| **1** | **Güçlü Tipli Model** | Sayfa tepesinde güçlü tipli `@model` bildirimi var mı? | Yoksa ➔ RED |
| **2** | **Satır İçi CSS Yasağı** | HTML içinde `style="..."` niteliği var mı? | Varsa ➔ RED |
| **3** | **Tag Helper Formu** | Form `<form asp-action="..." method="post">` şeklinde mi? | Çıplak formsa ➔ RED |
| **4** | **Validasyon Etiketleri**| Her input'un altında `asp-validation-for` span'ı var mı? | Eksikse ➔ Ekle |
| **5** | **Double Submit Önleme** | Form gönderilirken buton disable olup spinner gösteriyor mu? | Göstermiyorsa ➔ Ekle |
| **6** | **Toast / Alert UX** | İşlem sonucunda `TempData` mesajını gösteren dismissible alert var mı? | Yoksa ➔ Ekle |
| **7** | **İş Mantığı Yasağı** | Razor içinde C# ile hesaplama veya DB erişimi var mı? | Varsa ➔ KESİN RED |
| **8** | **Mobil Uyum (Grid)** | Sayfa `col-12 col-md-8 col-lg-6` gibi responsive grid kullanıyor mu? | Sabit genişlikse ➔ RED |
| **9** | **Client Validasyon** | Script bölümünde hem jQuery Validate hem de Vanilla JS uyumlu doğrulama var mı? | Eksikse ➔ Ekle |
| **10**| **Cache Busting** | Statik script ve css çağrılarında `asp-append-version="true"` var mı? | Yoksa ➔ Ekle |
