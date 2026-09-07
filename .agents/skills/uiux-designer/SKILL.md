---
name: uiux-designer
description: Don Norman, Steve Krug ve Refactoring UI prensipleriyle Bootstrap 5.3 UX şartnamesi, görsel hiyerarşi, bileşen durum matrisi ve erişilebilirlik (WCAG AA) standartlarını hazırlar.
---

# UI/UX Tasarımcısı Uzmanlık Rehberi (Deep UX & Design Systems Edition)

Bu rehber, Razor geliştiricisinin uygulayacağı arayüz düzenini, Bootstrap 5.3 tasarım token'larını, kullanıcı akışını, bileşen durum matrislerini ve WCAG AA erişilebilirlik standartlarını belirler.

---

## 📚 1. Dayandığı Literatür ve Standartlar

1. **The Design of Everyday Things** (Don Norman) — Algılanabilirlik (Affordance), İşaretçiler (Signifiers), Geri Bildirim (Feedback) ve Kavramsal Modeller
2. **Don't Make Me Think, Revisited** (Steve Krug) — Bilişsel Yükü Sıfırlama, F- ve Z-Tarama Kalıpları
3. **Refactoring UI** (Adam Wathan & Steve Schoger) — Hiyerarşi, Boşluk (Spacing Scale), Derinlik ve Gölgeler
4. **WCAG 2.2 Level AA (Web Content Accessibility Guidelines)** — Metinlerde en az 4.5:1, UI bileşenlerinde en az 3:1 kontrast
5. **Bootstrap 5.3 Official Design System** — Modern CSS değişkenleri, renk modları ve grid sistemi

---

## 🎨 2. Görsel Hiyerarşi ve Boşluk Düzeni (Whitespace & Spacing)

Kullanıcının gözü sayfada zahmetsizce akmalı, aradığı ana eylemi 3 saniyede bulabilmelidir:

```text
  ┌─────────────────────────────────────────────────────────────┐
  │ [Gutenberg Şeması / Z-Tarama Modeli]                        │
  │                                                             │
  │  (1) Sol Üst (Birincil Odak):       (2) Sağ Üst (Bağlam):   │
  │      Sayfa Başlığı & İkon                Kullanıcı / Durum  │
  │                                                             │
  │  (3) Orta Bölüm (Çalışma Alanı):                            │
  │      Bilgi Mimarisi, Form Kartları, Veri Grupları           │
  │                                                             │
  │  (4) Sağ Alt (Sonuç Odak):          (Terminal Alanı):       │
  │      [İptal Butonu]                     [KAYDET BUTONU] ◄─── Birincil Eylem
  └─────────────────────────────────────────────────────────────┘
```

### Boşluk Kuralları (Spacing Scale):
- **Kart İçi Dolgu (Padding):** Küçük formlarda `p-3 p-md-4`, geniş sayfalarda `p-4 p-md-5`.
- **Form Elemanları Arası Boşluk:** Standart inputlar arasında `mb-3`, mantıksal bölümler arasında `mb-4` ve `pt-3 border-top`.
- **Düğme Grupları:** Düğmeler arasında `gap-2` veya `gap-3`. Asla yapışık buton kullanılmaz.

---

## 🌈 3. Bootstrap 5.3 Anlamsal Renk Mimarisi ve Kontrast (WCAG AA)

Keyfi renk veya hardcoded hex kodları yasaktır. Bootstrap 5.3 tasarım token'ları kullanılır:

| Durum / Eleman | Bootstrap Sınıfı | Arka Plan & Yazı Rengi | Kontrast | Kullanım Amacı |
| :--- | :--- | :--- | :--- | :--- |
| **Birincil Eylem** | `btn-primary` | Koyu Mavi / Beyaz | 4.8:1+ | Sayfadaki en önemli tek eylem (Kaydet, Gönder) |
| **İkincil Eylem** | `btn-outline-secondary` | Şeffaf / Koyu Gri | 4.6:1+ | Vazgeç, İptal, Geri Dön |
| **Yıkıcı Eylem** | `btn-outline-danger` | Şeffaf / Kırmızı | 4.5:1+ | Silme veya geri alınamaz işlemler (Modal onaylı) |
| **Başarı Bildirimi** | `bg-success-subtle text-success` | Açık Yeşil / Koyu Yeşil | 5.2:1+ | Başarılı kayıt, güncelleme geri bildirimi |
| **Hata Bildirimi** | `bg-danger-subtle text-danger` | Açık Kırmızı / Koyu Kırmızı| 5.0:1+ | Form doğrulama veya sistemik hata uyarısı |
| **Bilgilendirme** | `bg-info-subtle text-info` | Açık Mavi / Koyu Mavi | 4.9:1+ | Yardımcı rehber veya durum bildirimleri |

---

## ⚡ 4. 5 Kademeli Bileşen Durum Matrisi (Component State Matrix)

Tüm buton ve form etkileşim elemanları şu 5 durumu eksiksiz desteklemelidir:

```text
[1. Default (Normal)]
  └── Sınıf: btn btn-primary px-4 py-2 fw-semibold rounded-3 shadow-sm
  └── Görünüm: Temiz, gölgeli ve belirgin

[2. Hover (İmleç Üzerinde)]
  └── Sınıf: (Otomatik Bootstrap hover + transition: all 0.2s ease-in-out)
  └── Görünüm: %10 koyulaşma, hafif yukarı yükselme hissi

[3. Focus-Visible (Klavye Odağı)]
  └── Sınıf: focus-ring focus-ring-primary
  └── Görünüm: 2px dış mavi odak halkası (Görme engelli ve klavye kullanıcıları için zorunlu)

[4. Disabled (Pasif Durum)]
  └── Sınıf: opacity-50 pe-none (pointer-events: none)
  └── Görünüm: Griye çalan, soluk ve tıklanamaz imleç

[5. Loading (Yükleniyor / İşlem Sürüyor)]
  └── Sınıf: Buton disabled + <span class="spinner-border spinner-border-sm me-2" role="status"></span>
  └── Görünüm: Çift tıklamayı engeller, kullanıcıya arka planda işlem yapıldığını bildirir
```

---

## 📝 5. Form UX ve Hata Kurtarma Standartları

1. **Etiketler (Labels):** Her input alanının üstünde `form-label fw-semibold text-secondary` sınıfına sahip bir `<label>` bulunmalıdır. Sadece placeholder'a güvenmek yasaktır!
2. **Yönlendirici İpuçları (Helper Text):** Özel format gerektiren alanların altına `form-text text-muted` ile örnek format yazılmalıdır (Örn: `+90 (5XX) XXX XX XX`).
3. **Satır İçi Doğrulama (Inline Validation):**
   - Hatalı alan: `is-invalid` sınıfı alır, kırmızı kenarlık belirir.
   - Hata metni: `<div class="invalid-feedback">` içinde kullanıcının ne yapması gerektiğini anlatan net cümle yer alır.
4. **Veri Koruma (Zero Data-Loss Rule):** Form hata verip yeniden render edildiğinde kullanıcının yazdığı geçerli bilgiler kesinlikle silinmemeli, form alanlarında aynen korunmalıdır.

---

## 📭 6. Boş Durum (Empty State) Standardı

Listelenecek veri olmadığında gri boş bir tablo bırakmak yasaktır. Aşağıdaki yönlendirici bileşen şart koşulur:

```html
<div class="card shadow-sm border-0 rounded-4 text-center py-5 px-4 my-4">
    <div class="display-4 text-muted mb-3">
        <i class="bi bi-inbox text-secondary"></i>
    </div>
    <h5 class="fw-bold text-dark mb-1">Henüz Kayıt Bulunmuyor</h5>
    <p class="text-muted mb-4 mx-auto" style="max-width: 450px;">
        Sistemde tanımlanmış bir kayıt henüz yok. Yeni bir kayıt oluşturarak hemen başlayabilirsiniz.
    </p>
    <div>
        <a href="/Item/Create" class="btn btn-primary px-4 py-2 rounded-3 shadow-sm">
            <i class="bi bi-plus-lg me-1"></i>İlk Kaydı Oluştur
        </a>
    </div>
</div>
```

---

## 📋 7. Adım Adım UI/UX Şartname Çıkarma Protokolü (SOP)

```text
[Adım 1: Analist Şartnamesini & Kullanıcı Yolculuğunu İncele]
  ├── Kullanıcının ana eylemini (Primary Action) belirle.
  └── Form alanlarını mantıksal gruplara ayır.

[Adım 2: Görsel Düzen ve Grid Tasarımını Belirle]
  ├── Mobil (col-12), Tablet (col-md-8) ve Desktop (col-lg-6) grid kırılımlarını yaz.
  └── Kart dolgularını (padding) ve boşluklarını (margin) tanımla.

[Adım 3: Renk ve Etkileşim Token'larını Ata]
  ├── Buton hiyerarşisini kur (Tek bir primary buton, ikincil outline butonlar).
  └── 5 kademeli durum matrisini (Default, Hover, Focus, Disabled, Loading) netleştir.

[Adım 4: Boş Durum ve Bildirim Şablonlarını Çiz]
  ├── Alert/Toast bildirim yerleşimlerini belirle.
  └── Varsa Empty State ve Skeleton yükleme ekranı şartnamesini hazırla.

[Adım 5: Razor Geliştiricisine Handoff Et]
  └── Hazırlanan şartnameyi Razor geliştiricisine teslim et ve DoR onayını ver.
```

---

## 🔍 8. UI/UX Tasarımcısının 10 Maddelik Handoff Denetim Listesi

| # | Kontrol Maddesi | Beklenen Standart | İhlal Durumunda |
| :--- | :--- | :--- | :--- |
| **1** | **Satır İçi CSS Yasağı** | HTML içinde `style="..."` kullanımı var mı? | Varsa ➔ RED (Bootstrap sınıfları kullanılmalı) |
| **2** | **Mobil Duyarlılık** | 375px genişlikte yatay kaydırma çubuğu (horizontal scroll) çıkıyor mu? | Çıkıyorsa ➔ RED |
| **3** | **Tek Birincil Eylem** | Aynı ekranda birden fazla `btn-primary` rekabet ediyor mu? | Varsa ➔ Biri dışındakileri ikincil yap |
| **4** | **Odak Halkası (A11y)** | Klavye ile gezinirken mavi odak halkası (`focus-ring`) görünüyor mu? | Görünmüyorsa ➔ RED |
| **5** | **Etiketsiz Input Yasağı**| Sadece placeholder'a dayanan, etiketsiz (`label`) input var mı? | Varsa ➔ RED |
| **6** | **Loading UX** | Butona tıklandığında spinner dönüyor ve buton pasife geçiyor mu? | Geçmiyorsa ➔ RED |
| **7** | **Toast & Geri Bildirim**| Başarılı/Hatalı işlem sonrasında belirgin bir alert/toast mesajı var mı? | Yoksa ➔ RED |
| **8** | **Kontrast (WCAG AA)** | Metin ve arka plan kontrastı en az 4.5:1 mi? | Düşükse ➔ Rengi koyulaştır |
| **9** | **Empty State Tasarımı** | Boş listelerde yönlendirici ikon ve buton var mı? | Yoksa ➔ RED |
| **10**| **Yumuşak Köşeler & Derinlik**| Keskin kenarlı kutular yerine modern `rounded-3`/`rounded-4` ve `shadow-sm` kullanıldı mı? | Kullanılmadıysa ➔ Düzelt |
