# Agent Squad v2: Ortam Kurulum ve Başlatma Kılavuzu (Bootstrap & Init Prompt)

Bu belge, `.agents/` klasörü yeni veya mevcut bir .NET projesine eklendiğinde, kök dizinde bulunması gereken tüm araçların, testlerin ve konfigürasyonların **otomatik olarak kurulmasını (scaffolding)** sağlayan ajan istemini (system prompt) ve başlatma yönergelerini içerir.

---

## 🏛️ Neden Bu Araçlar `.agents/` İçinde Değil de Proje Kökünde Kurulmalıdır?
1. **MSBuild ve .NET Hiyerarşisi:** `Directory.Build.props`, `.editorconfig` ve `nuget.config`, C# projelerinin (`src/`, `tests/`) derleme zamanında yukarı doğru aramasıyla bulunur. `.agents/` altında olurlarsa projeler bu kuralları göremez.
2. **CLI Araçlarının Sıfır Konfigürasyon Doğallığı:** `opengrep scan`, `dotnet stryker` ve `codeql` doğrudan kök dizindeki `.opengrep/rules.yaml` ve `stryker-config.json` dosyalarını varsayılan olarak okur.
3. **Gizli Dizin (.agents) Kısıtı:** Testlerin (`tests/`) ve denetim belgelerinin (`docs/`) nokta ile başlayan gizli bir klasör yerine standart açık dizinlerde bulunması CI/CD, IDE'ler ve denetçiler için zorunludur.

---

## 🎯 1. Kullanıcının Ajan'a Vereceği Başlatma İstemi (User Init Prompt)

Yeni bir projeye `.agents/` klasörünü kopyaladığınızda, Antigravity AI IDE sohbetine aşağıdaki istemi yazmanız yeterlidir:

```text
Bu projede agent-squad'ı başlat. .agents/INIT.md yönergelerini izleyerek hedef çözüm ve projelere uygun kök konfigürasyonlarını, ArchUnitNET testlerini, Opengrep kurallarını ve tasks.json dosyasını otomatik oluştur ve doğrula.
```

---

## 🤖 2. Ajan İçin Otomatik Başlatma Yönergesi (Agent Execution Specification)

Ajan, yukarıdaki komutu aldığında sırasıyla şu 4 adımı otonom olarak işletir:

### Adım 1: Proje ve Çözüm Tespiti
1. Kök dizindeki `*.sln` dosyasını tespit et (Örn: `MyProject.sln`).
2. Temel namespace prefix'ini belirle (Örn: `MyProject` veya `Company`).
3. Eğer çözüm dosyası yoksa, `dotnet new sln -n <KlasörAdı>` ile çözüm oluştur.

### Adım 2: Kök Dizin Dosyalarının Kurulumu (Scaffolding)
Ajan, `.agents/init.sh` scriptini çalıştırarak veya doğrudan şu dosyaları kök dizine kurar:
- **`Directory.Build.props`**: `SonarAnalyzer`, `Roslynator`, `BannedApiAnalyzers`, `VSTHRD`, `TreatWarningsAsErrors=true` (+ S2/S3 tanıları için `WarningsNotAsErrors`), `AnalysisLevel=10.0-recommended`, `RestorePackagesWithLockFile`, `NuGetAudit`.
- **`BannedSymbols.txt`**: `TimeProvider` zorunluluğu (`DateTime.Now/UtcNow` yasağı), `Task.Result`, MD5/SHA1/DES yasağı.
- **`.editorconfig`**: Roslyn analizör şiddet eşlemeleri.
- **`nuget.config`**: Paket kaynak eşleme (`packageSourceMapping`).
- **`stryker-config.json`**: Hedef çözümün `.sln` adıyla güncellenmiş mutasyon konfigürasyonu (`thresholds.break: 100` = 0 hayatta kalan mutant).
- **`.opengrep/rules.yaml`**: 72 adet UDAP statik güvenlik ve temiz kod kuralı (+ `.opengrep/fixtures/` öz-test korpusu).
- **`.semgrepignore`**: Opengrep varsayılan ignore listesini değiştirir; test disiplini kurallarının çalışabilmesi için `tests/` dizini kapsam İÇİNDE tutulur.
- **`.codeql/models/`**: CodeQL veri akışı ve taint modelleri.
- **`tests/ArchitectureTests/`**: Hedef namespace'e uyarlanmış bağımsız ArchUnitNET C# test projesi ve fixture sınıfları.
  > ⚠️ `ArchitectureRulesTests.ProductAssemblies()` metoduna hedef çözümün katman assembly'leri eklenmelidir; aksi halde mimari kurallar boş küme üzerinde çalışır ve sahte biçimde yeşil döner.
- **`tasks.json`**: `tasks.template.json` şablonundan türetilmiş aktif görev kuyruğu.
- **`docs/`**: 11 standarda bağlı izlenebilirlik matrisi ve SBOM politikası.

### Adım 3: Çözüme Bağlama ve Test Doğrulama
1. Test projesini çözüme ekle:
   ```bash
   dotnet sln add tests/ArchitectureTests/*.csproj
   ```
2. Kural kataloğu ile motor konfigürasyonları arasındaki tutarlılığı doğrula:
   ```bash
   bash .agents/verify.sh
   ```
   *(Beklenen sonuç: çıkış kodu 0; her `enforced_by` gerçek bir kapıya çözülür, her Opengrep kuralı kendi ihlal fixture'ında tetiklenir.)*
3. Paketleri geri yükle ve mimari testleri çalıştır:
   ```bash
   dotnet test tests/ArchitectureTests/
   ```

### Adım 4: Kullanıcıya Raporlama ve Göreve Hazırlık
Ajan, kurulumun tamamlandığını teyit eder ve ilk görevi almak üzere `tasks.json` dosyasını açar.

---

## 💻 3. Tek Komutla Otomatik Kurulum Scripti (`.agents/init.sh`)

Doğrudan terminalden veya ajan tarafından `bash .agents/init.sh [Namespace]` komutuyla çalıştırılabilen yerel kabuk scripti `.agents/init.sh` konumunda hazırdır.
