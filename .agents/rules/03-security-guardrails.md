# Web Güvenliği ve Kalite Korkulukları (Security Guardrails)

Bu kural, web uygulamasının güvenlik açıklarına karşı korunmasını ve kod tabanının sıfır hata toleransıyla inşa edilmesini garanti eder.

## 📚 Dayandığı Literatür ve Standartlar
- **OWASP Top 10 Web Application Security Risks** (The Open Web Application Security Project)
- **OWASP Application Security Verification Standard (ASVS v4.0)**
- **Secure by Design** (Dan Bergh Johnsson, Daniel Deogun, Daniel Sawano)
- **SEI CERT C# Coding Standard** (Software Engineering Institute - Carnegie Mellon)

---

## 1. Web Güvenliği Kırmızı Çizgileri

### 🛡️ Kural 1: CSRF Koruması (Anti-Forgery Tokens)
- Durum değiştiren tüm HTTP eylemleri (`[HttpPost]`, `[HttpPut]`, `[HttpDelete]`) Controller seviyesinde mutlaka `[ValidateAntiForgeryToken]` (veya `[AutoValidateAntiforgeryToken]`) özniteliğine sahip olmalıdır.
- Tüm Razor formlarında form Tag Helper'ı (`<form asp-action="...">`) veya `@Html.AntiForgeryToken()` zorunludur.

### 🛡️ Kural 2: XSS (Cross-Site Scripting) Engellemesi
- Razor motorunun varsayılan HTML kodlaması (HTML Encoding) esastır.
- `@Html.Raw()` kullanımı **kesinlikle yasaktır**. İstisnai durumlarda sadece güvenilir HTML sanitize kütüphaneleriyle temizlenmiş içerikler için Security Reviewer onayıyla kullanılabilir.

### 🛡️ Kural 3: Mass Assignment ve Aşırı Veri Bağlama Koruması
- Form post işlemlerinde doğrudan domain entity'leri parametre olarak alınamaz.
- Yalnızca ilgili form için gereken alanları içeren `ViewModel` bağlanmalı veya `[Bind("Field1,Field2")]` kısıtlaması kullanılmalıdır.

### 🛡️ Kural 4: SQL Injection Koruması
- EF Core LINQ sorgularında dinamik string birleştirme ile SQL oluşturulamaz (`string.Format`, `$""` ile raw SQL yasaktır).
- Parametreli sorgulama (`FromSqlInterpolated` veya standart LINQ) zorunludur.

---

## 2. Kod Kalitesi ve Derleme Standartları

### 🛡️ Kural 5: Sıfır Compiler Uyarısı (Zero Warnings as Errors)
- `.NET 10` derlemesinde hiçbir uyarı (warning) kabul edilmez.
- `#nullable enable` aktif olmalı ve null referans uyarıları derleme öncesinde giderilmelidir.

### 🛡️ Kural 6: Hassas Veri İzolasyonu (No Hardcoded Secrets)
- Kod tabanına veya git'e girecek dosyalara asla veritabanı şifresi, API anahtarı veya gizli anahtar (secret) yazılmaz.
- Tüm hassas konfigürasyonlar `appsettings.json`, Environment Variables veya .NET Secret Manager üzerinden okunmalıdır.
