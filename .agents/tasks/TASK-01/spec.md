# Görev Şartnamesi: TASK-01 - Görev Başlığı (Örn: Kullanıcı Kimlik Doğrulama Modülü)

## 1. INVEST Kullanıcı Hikayesi
**Rol:** Bir ... olarak
**İstek:** ... istiyorum
**Fayda:** Böylece ... elde edilsin.

## 2. 4 Kademeli Gherkin Kabul Kriterleri (DoR)

### Senaryo 1: Happy Path (Başarılı Akış)
- **Given** [Ön koşul]
- **When** [Eylem]
- **Then** [Beklenen sonuç]

### Senaryo 2: Validation (Giriş Doğrulama & Hata)
- **Given** [Geçersiz parametre]
- **When** [İşlem tetiklendiğinde]
- **Then** [Doğrulama hatası ve kullanıcı mesajı]

### Senaryo 3: Conflict & Edge Case (Sınır Değer & Çakışma)
- **Given** [Mükerrer veya sınır değer verisi]
- **When** [Eşzamanlı/çift gönderim yapıldığında]
- **Then** [İdempotent davranış veya çakışma yönetimi]

### Senaryo 4: Security & Abuse (Güvenlik & Yetkilendirme)
- **Given** [Yetkisiz veya kötü niyetli istek]
- **When** [Payload gönderildiğinde]
- **Then** [401/403/400 ret, loglama ve güvenli hata]

## 3. PII ve Veri Sınıflandırması
- [ ] Bu görevde kişisel veri (PII/KVKK) işleniyor mu? (Evet/Hayır)
- [ ] Hassas alanlar maskelendi veya şifrelendi mi?
