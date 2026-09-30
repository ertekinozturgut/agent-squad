# Görev Başına İzole Çalışma Alanı (.agents/tasks/{taskId}/)

Bu dizin, her bir görev için izole, hafif ve standartlaştırılmış şartname ve analiz dosyalarını barındırır.

## 🎯 Amaç ve $O(1)$ Sabit Token Tasarımı

1. **Bağlam Kirliliğini Önleme:** Projede 50 veya 500 görev bulunsa bile, ajanlar eski görevlerin detaylarını **asla okumaz**.
2. **Sabit Token Maliyeti:** Sıradaki ajan (örneğin Backend Developer veya QA Tester), yalnızca üzerinde çalıştığı görevin klasöründeki `spec.md` ve `arch.md` dosyalarını okur (~500 - 800 token).
3. **Denetlenebilirlik (Traceability):** Her görevin analizi, mimari kararları ve gerekirse devre kesici (RCA) raporu Git geçmişinde net bir şekilde izlenebilir.

---

## 📁 Standart Dosya Yapısı

```text
.agents/tasks/{taskId}/
├── spec.md          # İş Analisti: INVEST Kullanıcı Hikayesi, 4 Kademeli Gherkin, PII
├── arch.md          # Sistem Mimarı: Katman sınırları, ViewModel/DTO, Tasarım Kalıpları
├── qa-report.json   # (Opsiyonel) QA Tester: Mutant avı ve test çalıştırma özeti
└── rca-report.md    # (Devre Kesici) Max 3 ret sonrası otomatik üretilen Kök Neden Analizi
```

---

## ⚙️ Yaşam Döngüsü

1. `node .agents/runner/squad-runner.mjs next` komutu çalıştırıldığında bu dizin ve şablonlar otomatik üretilir.
2. İş Analisti `spec.md` dosyasını doldurur ve DoR gereksinimlerini tanımlar.
3. Sistem Mimarı `arch.md` dosyasını doldurur, uygulanacak GoF tasarım kalıbını ve sözleşmeyi belirtir.
4. Geliştirici bu iki dosyayı okuyarak kodlamaya başlar.
5. Görev kapandığında bu dosyalar nihai dokümantasyon olarak arşivlenir.
