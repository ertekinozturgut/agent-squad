# 📦 Tedarik Zinciri ve SBOM Güvenlik Politikası (Supply Chain & SLSA Policy)

> **Standartlar:** SLSA v1.0 (L2/L3) · NIST SP 800-218 (SSDF PS.3/PW.5) · UNECE R155 CSMS

---

## 1. Yetkili Paket Kaynakları (NuGet Feed Allowlist - R-SUP-003)
Projede üçüncü taraf bağımlılıklar yalnızca aşağıdaki onaylı ve doğrulanmış paket kaynaklarından indirilebilir:
- `https://api.nuget.org/v3/index.json`
- `https://pkgs.company.local/v3/index.json`

- **Kural:** Public kontrolsüz feed eklenemez.
- **İmza Doğrulaması:** `signatureValidationMode="require"` aktiftir (R-SUP-004).

---

## 2. Yazılım Malzeme Listesi (SBOM - R-SUP-001)
- **Format:** `CYCLONEDX` (JSON / XML).
- **Üretim:** CI derleme hattında otomatik oluşturulur:
  ```bash
  dotnet CycloneDX Company.sln --json --output ./artifacts/sbom/
  ```
- **CSMS Uyumu:** SBOM, UNECE R155 ve ISO 21434 gereği araç/yazılım bileşen envanteriyle eşleştirilir (R-AUT-006).

---

## 3. Lisans Uyumu ve Kopyaleft Engeli (R-SUP-005)
Yalnızca aşağıdaki izin verici (permissive) açık kaynak lisanslarına sahip paketler kullanılabilir:
- `MIT`
- `Apache-2.0`
- `BSD-2-Clause` / `BSD-3-Clause`
- `ISC`

**🔴 KESİN YASAK:** GPL, AGPL, LGPL (statik bağlama) ve SSPL gibi viral kopyaleft lisanslar şirketin mülki kodlarını riske attığı için PR kapısında otomatik reddedilir.

---

## 4. CI/CD Action ve Secret Güvenliği (R-SUP-006, R-SUP-007)
- **SHA Sabitleme (Aktif):** Tüm GitHub Actions iş akışları tag yerine sabit commit SHA ile çağrılmalıdır.
- **Fork İzolasyonu:** `pull_request_target` tetikleyicisi yasaktır; sırlar (secrets) PR işlerinde scope dışında tutulur.
