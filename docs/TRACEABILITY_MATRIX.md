# 📋 UDAP .NET v2 — Standart İzlenebilirlik Matrisi (Traceability Matrix)

> **Rapor Tarihi:** 13 Eylül 2026  
> **Toplam Kural:** 175  
> **Kapsanan Standartlar:** ASVS 5.0 · ISO 25010:2023 · CWE · OWASP Top 10 · API Top 10 · KVKK/GDPR · ISO 21434 · UNECE R155 · ASPICE v4.0 · SLSA · SSDF · MSFDG

---

## 1. Denetim Beyanı ve Kapsam Sınırları (Reality Check)

> [!IMPORTANT]
> **Statik Analiz Kapsam Beyanı:**
> Statik analiz araçları (ArchUnitNET, Opengrep, CodeQL, Roslyn) OWASP ASVS v5.0 gereksinimlerinin yaklaşık **%55'ini** kapsayabilir.
> İş mantığı doğrulaması, oturum davranışı ve yetkilendirme kararları tasarım incelemesi (Solution Architect) ve dinamik testler (QA Tester, Stryker) gerektirir.
> Bu tablo yalnızca kod düzeyinde doğrulanabilen ve izlenebilen teknik tedbirleri kanıtlar.

---

## 2. Standart İzlenebilirlik Tablosu

| Standart Ailesi | Gereksinim / Madde | Kural ID | Şiddet | Araç / Sahip | Doğrulama Mekanizması | Fixture | Kural Açıklaması |
|---|---|---|---|---|---|---|---|
| Automotive SPICE v4.0 | `SWE.1-6` | **R-AUT-005** | `S2` | process | `process.aspice-requirements-traceability` | Yes | Gereksinim → kod → test izlenebilirliği |
| Automotive SPICE v4.0 | `SWE.1-6` | **R-NET-019** | `S1` | process | `process.model-changes-require-migrations` | Yes | Migration'sız model değişikliği yok |
| Automotive SPICE v4.0 | `SWE.1-6` | **R-NET-040** | `S1` | opengrep | `opengrep.propagate-correlation-id` | Yes | Dış çağrılarda correlation ID taşınır |
| Automotive SPICE v4.0 | `SWE.1-6` | **R-NET-049** | `S1` | archunit | `ArchUnitNET.MessageContractMustHaveVersionField` | Yes | Mesaj sözleşmesinde version alanı zorunlu |
| Automotive SPICE v4.0 | `SWE.1-6` | **R-TDD-004** | `S2` | opengrep | `opengrep.fact-skip-must-have-reason` | Yes | Skip gerekçesiz olamaz |
| Automotive SPICE v4.0 | `SWE.1-6` | **R-TST-007** | `S1` | process | `process.s1-fixture-proven-verification` | Yes | Her S1 kuralın pozitif+negatif+boş fixture'ı var |
| Automotive SPICE v4.0 | `SWE.2` | **R-AUT-004** | `S2` | process | `process.architecture-decision-records` | Yes | Her mimari karar için gerekçe kaydı (ADR) |
| ISO/IEC 25010:2023 | `Compatibility/Coexistence` | **R-NET-055** | `S1` | process | `process.message-contract-backward-compatible` | Yes | Mesaj sözleşmesi geriye uyumlu (alan silinemez) |
| ISO/IEC 25010:2023 | `Compatibility/Replaceability` | **R-NET-049** | `S1` | archunit | `ArchUnitNET.MessageContractMustHaveVersionField` | Yes | Mesaj sözleşmesinde version alanı zorunlu |
| ISO/IEC 25010:2023 | `Flexibility/Replaceability` | **R-ARCH-003** | `S1` | archunit | `ArchUnitNET.DomainMustNotReferenceFrameworkTypes` | Yes | Domain'de framework tipi yok |
| ISO/IEC 25010:2023 | `Flexibility/Replaceability` | **R-CFG-006** | `S2` | opengrep | `opengrep.no-debug-directives-in-business-logic` | Yes | Feature flag'ler merkezî; #if DEBUG iş mantığı barındıramaz |
| ISO/IEC 25010:2023 | `Maintainability/Analysability` | **R-ARCH-007** | `S1` | archunit | `ArchUnitNET.NoCircularNamespaceDependencies` | Yes | Döngüsel namespace bağımlılığı yok |
| ISO/IEC 25010:2023 | `Maintainability/Analysability` | **R-NET-040** | `S1` | opengrep | `opengrep.propagate-correlation-id` | Yes | Dış çağrılarda correlation ID taşınır |
| ISO/IEC 25010:2023 | `Maintainability/Analysability` | **R-NET-085** | `S2` | opengrep | `opengrep.structured-logging-no-interpolation` | Yes | Yapılandırılmış loglama; string interpolasyonu yasak |
| ISO/IEC 25010:2023 | `Maintainability/Analysability` | **R-OBS-001** | `S2` | opengrep | `opengrep.activity-source-on-external-calls` | Yes | Her dış çağrı bir Activity/span açar |
| ISO/IEC 25010:2023 | `Maintainability/Analysability` | **R-OBS-002** | `S1` | opengrep | `opengrep.traceparent-propagation` | Yes | Trace context (W3C traceparent) propagate edilir |
| ISO/IEC 25010:2023 | `Maintainability/Analysability` | **R-OBS-004** | `S3` | opengrep | `opengrep.metric-names-convention` | Yes | Metrik adları konvansiyona uyar |
| ISO/IEC 25010:2023 | `Maintainability/Analysability` | **R-SEC-003** | `S2` | opengrep | `opengrep.no-throw-raw-exception` | Yes | Ham Exception fırlatılamaz |
| ISO/IEC 25010:2023 | `Maintainability/Analysability` | **R-SOLID-007** | `S2` | roslyn | `ArchUnitNET.ConstructorParameterCountLimit` | Yes | Constructor ≤ 5 bağımlılık |
| ISO/IEC 25010:2023 | `Maintainability/Analysability` | **R-SOLID-008** | `S2` | roslyn | `SonarAnalyzer.CSharp.S1541` | Yes | Metot siklomatik karmaşıklık ≤ 10 |
| ISO/IEC 25010:2023 | `Maintainability/Analysability` | **R-SOLID-009** | `S2` | roslyn | `SonarAnalyzer.CSharp.S3776` | Yes | Bilişsel karmaşıklık ≤ 15 |
| ISO/IEC 25010:2023 | `Maintainability/Analysability` | **R-SOLID-010** | `S3` | opengrep | `opengrep.class-and-method-length-limits` | Yes | Sınıf ≤ 400 satır, metot ≤ 60 satır |
| ISO/IEC 25010:2023 | `Maintainability/Analysability` | **R-SOLID-011** | `S3` | roslyn | `SonarAnalyzer.CSharp.S134` | Yes | İç içe koşul derinliği ≤ 3 |
| ISO/IEC 25010:2023 | `Maintainability/Analysability` | **R-TST-004** | `S3` | opengrep | `opengrep.test-naming-convention` | Yes | Test isimlendirmesi Metot_Senaryo_BeklenenSonuç |
| ISO/IEC 25010:2023 | `Maintainability/Modifiability` | **R-ARCH-006** | `S2` | archunit | `ArchUnitNET.CrossLayerCallsMustUseInterfaces` | Yes | Katmanlar arası geçiş yalnızca arayüz üzerinden |
| ISO/IEC 25010:2023 | `Maintainability/Modifiability` | **R-AUTH-007** | `S2` | opengrep | `opengrep.roles-from-constants` | Yes | Rol string'i literal olamaz, sabitten gelir |
| ISO/IEC 25010:2023 | `Maintainability/Modifiability` | **R-CFG-007** | `S3` | opengrep | `opengrep.env-var-names-from-constants` | Yes | Ortam değişkeni adları sabitten gelir |
| ISO/IEC 25010:2023 | `Maintainability/Modifiability` | **R-NET-023** | `S2` | opengrep | `opengrep.strongly-typed-options` | Yes | Konfigürasyon IOptions<T> ile okunur |
| ISO/IEC 25010:2023 | `Maintainability/Modifiability` | **R-NET-062** | `S1` | process | `process.analysis-level-pinned` | Yes | AnalysisLevel sabit sürüm |
| ISO/IEC 25010:2023 | `Maintainability/Modifiability` | **R-SOLID-003** | `S1` | archunit | `ArchUnitNET.ConstructorMustNotDependOnConcreteClasses` | Yes | Constructor'da somut sınıf yok |
| ISO/IEC 25010:2023 | `Maintainability/Modularity` | **R-ARCH-001** | `S1` | archunit | `ArchUnitNET.DomainLayerMustNotDependOnExternalLayers` | Yes | Domain dış katmanlara bağımlı olamaz |
| ISO/IEC 25010:2023 | `Maintainability/Modularity` | **R-ARCH-002** | `S1` | archunit | `ArchUnitNET.ApplicationLayerMustDependOnlyOnDomain` | Yes | Application yalnızca Domain'e bağımlı |
| ISO/IEC 25010:2023 | `Maintainability/Modularity` | **R-ARCH-004** | `S1` | archunit | `ArchUnitNET.ApiMustNotDirectlyAccessInfrastructure` | Yes | Api katmanı Infrastructure'a doğrudan erişemez |
| ISO/IEC 25010:2023 | `Maintainability/Modularity` | **R-ARCH-010** | `S3` | process | `ArchUnitNET.RequireAssemblyMarkerType` | Yes | Assembly başına tek sorumluluk (marker tip zorunlu) |
| ISO/IEC 25010:2023 | `Maintainability/Modularity` | **R-AUTH-008** | `S2` | archunit | `ArchUnitNET.NoHttpContextUserInDomain` | Yes | HttpContext.User doğrudan Domain'e taşınamaz |
| ISO/IEC 25010:2023 | `Maintainability/Modularity` | **R-MOD-001** | `S1` | archunit | `ArchUnitNET.FeaturesMustNotDependOnEachOther` | Yes | Feature → Feature bağımlılığı yok |
| ISO/IEC 25010:2023 | `Maintainability/Modularity` | **R-MOD-003** | `S2` | process | `ArchUnitNET.SharedCodeMustBeInSharedKernel` | Yes | Paylaşılan kod yalnızca Common/SharedKernel altında |
| ISO/IEC 25010:2023 | `Maintainability/Modularity` | **R-MOD-004** | `S1` | archunit | `ArchUnitNET.SharedKernelMustNotDependOnFeatures` | Yes | SharedKernel hiçbir feature'a bağımlı olamaz |
| ISO/IEC 25010:2023 | `Maintainability/Modularity` | **R-NET-015** | `S2` | opengrep | `opengrep.entity-type-configuration-classes` | Yes | Entity konfigürasyonları IEntityTypeConfiguration ile yapılır |
| ISO/IEC 25010:2023 | `Maintainability/Modularity` | **R-NET-044** | `S1` | archunit | `ArchUnitNET.ExternalDtosMustNotLeakToDomain` | Yes | Dış servis DTO'su Domain'e sızamaz |
| ISO/IEC 25010:2023 | `Maintainability/Modularity` | **R-NET-053** | `S2` | archunit | `ArchUnitNET.NoEnvironmentInDomain` | Yes | Environment.MachineName, Process.Id Domain'de yasak |
| ISO/IEC 25010:2023 | `Maintainability/Modularity` | **R-SOLID-001** | `S2` | archunit | `ArchUnitNET.HandlerMustHaveSinglePublicMethod` | Yes | Handler tek public metot |
| ISO/IEC 25010:2023 | `Maintainability/Modularity` | **R-SOLID-006** | `S2` | roslyn | `ArchUnitNET.InterfaceMethodCountLimit` | Yes | Interface ≤ 5 metot |
| ISO/IEC 25010:2023 | `Maintainability/Modularity` | **R-SUP-005** | `S2` | process | `process.license-compliance-check` | Yes | Lisans uyumu denetlenir (kopyaleft engeli) |
| ISO/IEC 25010:2023 | `Maintainability/Testability` | **R-NET-050** | `S1` | roslyn | `Microsoft.CodeAnalysis.BannedApiAnalyzers` | Yes | DateTime.Now/UtcNow yasak; TimeProvider |
| ISO/IEC 25010:2023 | `Maintainability/Testability` | **R-NET-052** | `S2` | opengrep | `opengrep.no-guid-newguid-in-domain` | Yes | Guid.NewGuid() Domain'de yasak, enjekte edilir |
| ISO/IEC 25010:2023 | `Maintainability/Testability` | **R-NET-054** | `S1` | archunit | `ArchUnitNET.DomainMustNotAccessFileSystemOrNetwork` | Yes | Dosya sistemi ve ağ erişimi Domain'de yasak |
| ISO/IEC 25010:2023 | `Maintainability/Testability` | **R-SOLID-013** | `S2` | archunit | `ArchUnitNET.StaticClassesMustNotContainBusinessLogic` | Yes | static yardımcı sınıflar iş mantığı barındıramaz |
| ISO/IEC 25010:2023 | `Maintainability/Testability` | **R-TDD-001** | `S1` | stryker | `stryker.coverage-threshold` | Yes | Test coverage oranı hedeflenen eşiğin altında olamaz |
| ISO/IEC 25010:2023 | `Maintainability/Testability` | **R-TDD-002** | `S2` | process | `ArchUnitNET.TestIsolationIntegrity` | Yes | Test sınıfları üretim koduna doğrudan referans dışında yan etki oluşturamaz |
| ISO/IEC 25010:2023 | `Maintainability/Testability` | **R-TDD-003** | `S1` | stryker | `opengrep.test-must-contain-assertion` | Yes | Assertion'sız test yok |
| ISO/IEC 25010:2023 | `Maintainability/Testability` | **R-TP-001** | `S1` | archunit | `ArchUnitNET.CriticalClassesMustHaveTests` | Yes | Kritik sınıfın testi var |
| ISO/IEC 25010:2023 | `Maintainability/Testability` | **R-TST-002** | `S1` | process | `process.red-gate-tdd` | Yes | Yeni testler implementasyon öncesi kırmızı olmalı |
| ISO/IEC 25010:2023 | `Maintainability/Testability` | **R-TST-003** | `S1` | opengrep | `opengrep.no-thread-sleep-in-tests` | Yes | Testte Thread.Sleep yasak |
| ISO/IEC 25010:2023 | `Maintainability/Testability` | **R-TST-006** | `S1` | archunit | `ArchUnitNET.IntegrationTestsMustNotCallExternalServices` | Yes | Integration testleri gerçek dış servise gidemez |
| ISO/IEC 25010:2023 | `Maintainability/Testability` | **R-TST-008** | `S2` | process | `process.new-code-coverage-gate` | Yes | Kapsam yeni kodda ≥ %80 |
| ISO/IEC 25010:2023 | `Performance/ResourceUtilization` | **R-NET-003** | `S2` | roslyn | `Microsoft.CodeAnalysis.NetAnalyzers.CA2007` | Yes | Kütüphanede ConfigureAwait(false) |
| ISO/IEC 25010:2023 | `Performance/ResourceUtilization` | **R-NET-010** | `S2` | opengrep | `opengrep.readonly-query-asnotracking` | Yes | Salt okunur sorguda AsNoTracking() |
| ISO/IEC 25010:2023 | `Performance/ResourceUtilization` | **R-NET-011** | `S2` | roslyn | `opengrep.prefer-select-projection-over-include` | Yes | Uygulama katmanında Include yerine projeksiyon |
| ISO/IEC 25010:2023 | `Performance/ResourceUtilization` | **R-NET-016** | `S2` | opengrep | `opengrep.no-sync-savechanges` | Yes | Senkron SaveChanges yasak |
| ISO/IEC 25010:2023 | `Performance/ResourceUtilization` | **R-NET-021** | `S2` | opengrep | `opengrep.foreign-keys-and-indexes-explicit` | Yes | SQL indeksleme ve yabancı anahtar kısıtları açık tanımlı |
| ISO/IEC 25010:2023 | `Performance/ResourceUtilization` | **R-NET-025** | `S3` | opengrep | `opengrep.prefer-batch-operations` | Yes | Toplu işlemlerde AddRange/ExecuteUpdate tercih edilir |
| ISO/IEC 25010:2023 | `Performance/ResourceUtilization` | **R-OBS-006** | `S2` | opengrep | `opengrep.no-high-cardinality-metric-tags` | Yes | Log/metrik/trace'te kardinalite patlaması yok (id etiket olamaz) |
| ISO/IEC 25010:2023 | `Reliability/Analysability` | **R-SEC-001** | `S2` | opengrep | `opengrep.meaningful-exception-logging` | Yes | Boş catch yerine anlamlı loglama |
| ISO/IEC 25010:2023 | `Reliability/Analysability` | **R-SEC-002** | `S2` | opengrep | `opengrep.no-throw-ex-rethrow` | Yes | Exception türünü değiştirmeden throw e yasağı |
| ISO/IEC 25010:2023 | `Reliability/Availability` | **R-NET-001** | `S1` | roslyn | `Microsoft.VisualStudio.Threading.Analyzers.VSTHRD002` | Yes | .Result / .Wait() / GetAwaiter().GetResult() yasak |
| ISO/IEC 25010:2023 | `Reliability/Availability` | **R-OBS-003** | `S2` | archunit | `ArchUnitNET.HealthChecksConfigured` | Yes | Health check endpoint'i tanımlı (liveness + readiness) |
| ISO/IEC 25010:2023 | `Reliability/Concurrency` | **R-NET-071** | `S2` | opengrep | `opengrep.parallel-no-async-lambda` | Yes | Parallel.ForEach içinde async lambda yok |
| ISO/IEC 25010:2023 | `Reliability/Concurrency` | **R-NET-072** | `S2` | opengrep | `opengrep.threadstatic-asynclocal-audit` | Yes | ThreadStatic / AsyncLocal gerekçe ister |
| ISO/IEC 25010:2023 | `Reliability/FaultTolerance` | **R-CFG-001** | `S2` | archunit | `ArchUnitNET.OptionsValidationOnStart` | Yes | Startup'ta konfigürasyon doğrulaması (ValidateOnStart) |
| ISO/IEC 25010:2023 | `Reliability/FaultTolerance` | **R-NET-002** | `S1` | roslyn | `Microsoft.VisualStudio.Threading.Analyzers.VSTHRD100` | Yes | async void yalnızca event handler |
| ISO/IEC 25010:2023 | `Reliability/FaultTolerance` | **R-NET-004** | `S1` | opengrep | `opengrep.cancellation-token-propagation` | Yes | CancellationToken imzada ve zincirde |
| ISO/IEC 25010:2023 | `Reliability/FaultTolerance` | **R-NET-006** | `S1` | opengrep | `opengrep.no-await-in-lock` | Yes | lock içinde await yok |
| ISO/IEC 25010:2023 | `Reliability/FaultTolerance` | **R-NET-009** | `S1` | roslyn | `Microsoft.CodeAnalysis.CSharp.CS4014` | Yes | Awaitsiz Task dönüşü yok (fire-and-forget) |
| ISO/IEC 25010:2023 | `Reliability/FaultTolerance` | **R-NET-041** | `S1` | opengrep | `opengrep.message-handler-idempotency` | Yes | Mesaj işleyicide idempotency anahtarı zorunlu |
| ISO/IEC 25010:2023 | `Reliability/FaultTolerance` | **R-NET-042** | `S1` | opengrep | `opengrep.require-retry-policy` | Yes | Retry politikası olmayan dış çağrı yasak |
| ISO/IEC 25010:2023 | `Reliability/FaultTolerance` | **R-NET-046** | `S2` | archunit | `ArchUnitNET.CircuitBreakerConfigured` | Yes | Circuit breaker tanımlı (Polly pipeline) |
| ISO/IEC 25010:2023 | `Reliability/FaultTolerance` | **R-NET-047** | `S1` | opengrep | `opengrep.retry-only-idempotent-calls` | Yes | Retry yalnızca idempotent operasyonlarda |
| ISO/IEC 25010:2023 | `Reliability/FaultTolerance` | **R-NET-048** | `S2` | opengrep | `opengrep.backoff-with-jitter` | Yes | Exponential backoff + jitter zorunlu |
| ISO/IEC 25010:2023 | `Reliability/FaultTolerance` | **R-NET-057** | `S2` | opengrep | `opengrep.poison-message-handling` | Yes | Poison message limiti tanımlı |
| ISO/IEC 25010:2023 | `Reliability/FaultTolerance` | **R-NET-070** | `S1` | opengrep | `opengrep.semaphore-released-in-finally` | Yes | SemaphoreSlim / Mutex finally ile bırakılır |
| ISO/IEC 25010:2023 | `Reliability/FaultTolerance` | **R-NET-080** | `S2` | opengrep | `opengrep.catch-specific-exception-types` | Yes | catch yalnızca spesifik tip; catch (Exception) yeniden fırlatmalı |
| ISO/IEC 25010:2023 | `Reliability/FaultTolerance` | **R-NET-081** | `S3` | opengrep | `opengrep.exception-filters-no-side-effects` | Yes | Exception filtreleri yan etki içeremez |
| ISO/IEC 25010:2023 | `Reliability/FaultTolerance` | **R-SEC-004** | `S1` | opengrep | `opengrep.do-not-swallow-operationcanceled` | Yes | OperationCanceledException yutulamaz |
| ISO/IEC 25010:2023 | `Reliability/FaultTolerance` | **R-SEC-005** | `S1` | opengrep | `opengrep.do-not-catch-fatal-exceptions` | Yes | Kritik sistem istisnaları yakalanıp yutulamaz |
| ISO/IEC 25010:2023 | `Reliability/FaultTolerance` | **R-SEC-007** | `S1` | opengrep | `opengrep.no-empty-catch` | Yes | Boş catch bloğu yok |
| ISO/IEC 25010:2023 | `Reliability/FaultTolerance` | **R-SOLID-004** | `S1` | opengrep | `opengrep.no-notimplemented-exception` | Yes | NotImplementedException üretimde yok |
| ISO/IEC 25010:2023 | `Reliability/FaultTolerance` | **R-TST-001** | `S1` | stryker | `stryker.zero-survived-mutants-on-diff` | Yes | Değişen dosyalarda hayatta kalan mutant = 0 |
| ISO/IEC 25010:2023 | `Reliability/Integrity` | **R-NET-018** | `S2` | archunit | `ArchUnitNET.TransactionBoundaryExplicit` | Yes | Transaction sınırı açıkça tanımlı (UoW dışında SaveChanges yok) |
| ISO/IEC 25010:2023 | `Reliability/Integrity` | **R-NET-056** | `S1` | archunit | `ArchUnitNET.OutboxPatternEnforced` | Yes | Outbox pattern: dış çağrı ile DB yazımı aynı transaction'da olamaz |
| ISO/IEC 25010:2023 | `Reliability/Integrity` | **R-TDD-005** | `S1` | process | `process.test-diff-shield` | Yes | Test diff kalkanı |
| ISO/IEC 25010:2023 | `Reliability/Integrity` | **R-TST-005** | `S2` | opengrep | `opengrep.tests-order-independent` | Yes | Testler birbirine bağımlı olamaz (sıra bağımsız) |
| ISO/IEC 25010:2023 | `Reliability/Recoverability` | **R-NET-043** | `S1` | process | `process.dead-letter-queue-handling` | Yes | Dead-letter işleme yolu tanımlı |
| ISO/IEC 25010:2023 | `Reliability/ResourceUtilization` | **R-NET-007** | `S1` | roslyn | `Microsoft.CodeAnalysis.NetAnalyzers.CA2000` | Yes | IDisposable / IAsyncDisposable using ile tüketilir |
| ISO/IEC 25010:2023 | `Reliability/ResourceUtilization` | **R-NET-073** | `S2` | opengrep | `opengrep.bounded-collections` | Yes | Sınırsız kuyruk / koleksiyon büyümesi yok |
| ISO/IEC 25010:2023 | `Reliability/Testability` | **R-NET-020** | `S2` | opengrep | `opengrep.no-inmemory-db-in-integration-tests` | Yes | InMemory database üretim testinde test doubles yerine kullanılamaz |
| ISO/SAE 21434 & R155 | `CSMS/AuditLogging` | **R-NET-083** | `S1` | opengrep | `opengrep.security-events-logged` | Yes | Güvenlik olayları (auth başarısız, yetki reddi) loglanır |
| ISO/SAE 21434 & R155 | `CSMS/CommunicationChannel` | **R-AUT-002** | `S1` | archunit | `ArchUnitNET.TelematicsFlowDocumentedChannel` | Yes | Telematik/araç verisi akışı belgelenmiş kanaldan geçer |
| ISO/SAE 21434 & R155 | `CSMS/DataProtection` | **R-AUT-001** | `S1` | codeql | `codeql.csharp.security.AutomotivePiiTracking` | Yes | Araç tanımlayıcıları (VIN, şasi, motor no) PII sınıfında işlenir |
| ISO/SAE 21434 & R155 | `CSMS/ThirdPartyInventory` | **R-AUT-006** | `S1` | process | `process.r155-sbom-inventory-match` | Yes | Üçüncü taraf bileşen envanteri güncel (SBOM ile eşleşir) |
| ISO/SAE 21434 & R155 | `CSMS/VulnerabilityManagement` | **R-AUT-003** | `S1` | process | `process.vulnerability-management-trace` | Yes | Güvenlik açığı yönetimi kaydı zorunlu (CVE → issue → düzeltme izi) |
| KVKK / GDPR | `m.12 veri güvenliği` | **R-AUT-001** | `S1` | codeql | `codeql.csharp.security.AutomotivePiiTracking` | Yes | Araç tanımlayıcıları (VIN, şasi, motor no) PII sınıfında işlenir |
| KVKK / GDPR | `m.12 veri güvenliği` | **R-NET-031** | `S1` | codeql | `codeql.csharp.security.CompanyFlowModelPiiLog` | Yes | PII alanı log çağrısına parametre olarak geçirilemez |
| KVKK / GDPR | `m.12 veri güvenliği` | **R-OBS-005** | `S1` | archunit | `ArchUnitNET.CriticalOperationsAuditLoggingRequired` | Yes | Kritik iş akışları için audit kaydı zorunlu |
| KVKK / GDPR | `m.12 veri güvenliği` | **R-PII-001** | `S1` | codeql | `codeql.csharp.security.PiiLoggingSink` | Yes | PII alanı log çağrısına parametre olarak geçemez |
| KVKK / GDPR | `m.12 veri güvenliği` | **R-PII-002** | `S1` | codeql | `codeql.csharp.security.PiiInExceptionMessage` | Yes | PII alanı exception mesajına konulamaz |
| KVKK / GDPR | `m.12 veri güvenliği` | **R-PII-005** | `S2` | opengrep | `opengrep.pii-in-cache-key` | Yes | PII alanı cache anahtarında kullanılamaz |
| KVKK / GDPR | `m.12 veri güvenliği` | **R-PII-006** | `S1` | codeql | `opengrep.pii-in-url-query` | Yes | PII alanı URL query string'inde taşınamaz |
| KVKK / GDPR | `m.12 veri güvenliği` | **R-PII-008** | `S2` | opengrep | `opengrep.tostring-no-pii` | Yes | ToString() override'ı PII sızdıramaz |
| KVKK / GDPR | `m.4 genel ilkeler` | **R-PII-009** | `S1` | opengrep | `opengrep.no-real-pii-in-tests` | Yes | Test fixture'larında gerçek PII kullanılamaz |
| KVKK / GDPR | `m.5 işleme şartları` | **R-PII-010** | `S1` | codeql | `codeql.csharp.security.PiiInTelemetry` | Yes | Analitik/telemetri olaylarına PII eklenemez |
| KVKK / GDPR | `m.6 özel nitelikli veri` | **R-PII-003** | `S1` | archunit | `ArchUnitNET.PiiTypesMustHaveSensitiveDataAttribute` | Yes | PII içeren tipler [SensitiveData] ile işaretli olmalı |
| KVKK / GDPR | `m.7 kişisel verilerin silinmesi, yok edilmesi` | **R-PII-007** | `S2` | process | `process.kvkk-data-retention-policy` | Yes | PII içeren tablo/entity için saklama süresi tanımlı |
| KVKK / GDPR | `m.8/9 veri aktarımı` | **R-PII-004** | `S1` | codeql | `codeql.csharp.security.PiiInExternalClientPayload` | Yes | PII alanı üçüncü taraf istemci payload'ına maskesiz gidemez |
| MITRE CWE | `CWE-1050` | **R-NET-012** | `S1` | opengrep | `opengrep.no-lazy-loading` | Yes | Lazy loading kapalı |
| MITRE CWE | `CWE-1104` | **R-NET-065** | `S1` | process | `process.no-vulnerable-nuget-packages` | Yes | dotnet list package --vulnerable temiz |
| MITRE CWE | `CWE-117` | **R-NET-084** | `S1` | codeql | `codeql.csharp.security.LogInjection` | Yes | Log injection: kullanıcı girdisi ham loglanamaz |
| MITRE CWE | `CWE-1333` | **R-INJ-008** | `S2` | opengrep | `opengrep.regex-injection-and-redos` | Yes | Regex kullanıcı girdisinden derlenemez (ReDoS) |
| MITRE CWE | `CWE-1339` | **R-NET-059** | `S2` | opengrep | `opengrep.prefer-datetimeoffset` | Yes | Zaman dilimi açıkça belirtilir (DateTimeOffset tercih) |
| MITRE CWE | `CWE-1357` | **R-SUP-003** | `S1` | process | `process.nuget-source-allowlist` | Yes | NuGet kaynağı allowlist; yalnızca onaylı feed |
| MITRE CWE | `CWE-209` | **R-CFG-005** | `S1` | opengrep | `opengrep.no-detailed-errors-in-prod` | Yes | Detaylı hata sayfası üretimde kapalı |
| MITRE CWE | `CWE-209` | **R-NET-082** | `S1` | archunit | `ArchUnitNET.GlobalExceptionHandlerRequired` | Yes | Global exception handler zorunlu, stack trace dışarı sızmaz |
| MITRE CWE | `CWE-209` | **R-PII-002** | `S1` | codeql | `codeql.csharp.security.PiiInExceptionMessage` | Yes | PII alanı exception mesajına konulamaz |
| MITRE CWE | `CWE-209` | **R-SEC-006** | `S2` | codeql | `opengrep.no-exception-leak-to-client` | Yes | Hata detayları istemciye sızdırılamaz |
| MITRE CWE | `CWE-209` | **R-SEC-008** | `S1` | codeql | `codeql.csharp.security.ExceptionInformationLeak` | Yes | Exception mesajı istemciye dönemez |
| MITRE CWE | `CWE-22` | **R-INJ-003** | `S1` | codeql | `codeql.csharp.security.PathTraversal` | Yes | Path traversal: dosya yolu girdiden türetilemez |
| MITRE CWE | `CWE-248` | **R-NET-002** | `S1` | roslyn | `Microsoft.VisualStudio.Threading.Analyzers.VSTHRD100` | Yes | async void yalnızca event handler |
| MITRE CWE | `CWE-269` | **R-SUP-007** | `S1` | opengrep | `opengrep.ci-secrets-and-pr-target` | Yes | CI secret'ları job scope'unda; pull_request_target yasak |
| MITRE CWE | `CWE-295` | **R-CRY-005** | `S1` | roslyn | `opengrep.no-certificate-validation-bypass` | Yes | Sertifika doğrulaması bypass edilemez |
| MITRE CWE | `CWE-316` | **R-CRY-008** | `S2` | opengrep | `opengrep.key-material-not-string` | Yes | Anahtar malzemesi bellekte string tutulamaz |
| MITRE CWE | `CWE-319` | **R-AUTH-005** | `S1` | opengrep | `opengrep.jwt-require-https-metadata` | Yes | RequireHttpsMetadata = false yasak |
| MITRE CWE | `CWE-319` | **R-CRY-009** | `S1` | opengrep | `opengrep.no-http-plain-url` | Yes | http:// şemalı URL literal'i yasak |
| MITRE CWE | `CWE-326` | **R-CRY-006** | `S1` | opengrep | `opengrep.tls-min-version` | Yes | TLS sürümü sabitlenmiş ve ≥ 1.2 |
| MITRE CWE | `CWE-327` | **R-CRY-001** | `S1` | roslyn | `Microsoft.CodeAnalysis.NetAnalyzers.CA5350` | Yes | MD5, SHA1, DES, RC2, TripleDES yasak |
| MITRE CWE | `CWE-327` | **R-CRY-002** | `S1` | roslyn | `Microsoft.CodeAnalysis.NetAnalyzers.CA5358` | Yes | ECB modu yasak |
| MITRE CWE | `CWE-328` | **R-CRY-001** | `S1` | roslyn | `Microsoft.CodeAnalysis.NetAnalyzers.CA5350` | Yes | MD5, SHA1, DES, RC2, TripleDES yasak |
| MITRE CWE | `CWE-329` | **R-CRY-007** | `S1` | opengrep | `opengrep.no-static-iv` | Yes | IV/nonce sabit olamaz |
| MITRE CWE | `CWE-338` | **R-CRY-003** | `S1` | roslyn | `Microsoft.CodeAnalysis.NetAnalyzers.CA5394` | Yes | Random kriptografik amaçla kullanılamaz |
| MITRE CWE | `CWE-345` | **R-NET-058** | `S1` | opengrep | `opengrep.webhook-signature-verification` | Yes | Webhook imza doğrulaması zorunlu |
| MITRE CWE | `CWE-347` | **R-AUTH-004** | `S1` | opengrep | `opengrep.jwt-validation-parameters` | Yes | JWT doğrulamada ValidateIssuer, ValidateAudience, ValidateLifetime açık |
| MITRE CWE | `CWE-352` | **R-AUTH-009** | `S1` | roslyn | `SonarAnalyzer.CSharp.S4507` | Yes | Antiforgery token durum değiştiren endpoint'lerde |
| MITRE CWE | `CWE-359` | **R-NET-031** | `S1` | codeql | `codeql.csharp.security.CompanyFlowModelPiiLog` | Yes | PII alanı log çağrısına parametre olarak geçirilemez |
| MITRE CWE | `CWE-359` | **R-PII-001** | `S1` | codeql | `codeql.csharp.security.PiiLoggingSink` | Yes | PII alanı log çağrısına parametre olarak geçemez |
| MITRE CWE | `CWE-362` | **R-NET-024** | `S2` | opengrep | `opengrep.optimistic-concurrency-handling` | Yes | Optimistic concurrency token'ı olan entity'de güncelleme kontrolü |
| MITRE CWE | `CWE-362` | **R-NET-072** | `S2` | opengrep | `opengrep.threadstatic-asynclocal-audit` | Yes | ThreadStatic / AsyncLocal gerekçe ister |
| MITRE CWE | `CWE-390` | **R-SEC-001** | `S2` | opengrep | `opengrep.meaningful-exception-logging` | Yes | Boş catch yerine anlamlı loglama |
| MITRE CWE | `CWE-390` | **R-SEC-005** | `S1` | opengrep | `opengrep.do-not-catch-fatal-exceptions` | Yes | Kritik sistem istisnaları yakalanıp yutulamaz |
| MITRE CWE | `CWE-390` | **R-SEC-007** | `S1` | opengrep | `opengrep.no-empty-catch` | Yes | Boş catch bloğu yok |
| MITRE CWE | `CWE-396` | **R-NET-080** | `S2` | opengrep | `opengrep.catch-specific-exception-types` | Yes | catch yalnızca spesifik tip; catch (Exception) yeniden fırlatmalı |
| MITRE CWE | `CWE-397` | **R-SEC-003** | `S2` | opengrep | `opengrep.no-throw-raw-exception` | Yes | Ham Exception fırlatılamaz |
| MITRE CWE | `CWE-400` | **R-INJ-010** | `S2` | codeql | `opengrep.deserialization-depth-limit` | Yes | Deserialization boyut/derinlik limiti tanımlı |
| MITRE CWE | `CWE-400` | **R-NET-004** | `S1` | opengrep | `opengrep.cancellation-token-propagation` | Yes | CancellationToken imzada ve zincirde |
| MITRE CWE | `CWE-400` | **R-NET-045** | `S1` | opengrep | `opengrep.httpclient-timeout-configured` | Yes | Timeout'suz HttpClient yasak |
| MITRE CWE | `CWE-404` | **R-NET-007** | `S1` | roslyn | `Microsoft.CodeAnalysis.NetAnalyzers.CA2000` | Yes | IDisposable / IAsyncDisposable using ile tüketilir |
| MITRE CWE | `CWE-404` | **R-NET-022** | `S1` | opengrep | `opengrep.no-new-httpclient` | Yes | new HttpClient() yasak; IHttpClientFactory |
| MITRE CWE | `CWE-476` | **R-NET-064** | `S1` | process | `process.nullable-reference-types-enabled` | Yes | Nullable enable |
| MITRE CWE | `CWE-489` | **R-CFG-002** | `S1` | opengrep | `opengrep.no-developerexceptionpage-in-prod` | Yes | Geliştirme ayarları üretimde etkin olamaz (DeveloperExceptionPage) |
| MITRE CWE | `CWE-502` | **R-INJ-006** | `S1` | codeql | `opengrep.typenamehandling-prohibited` | Yes | TypeNameHandling / polimorfik deserialization yasak |
| MITRE CWE | `CWE-524` | **R-PII-005** | `S2` | opengrep | `opengrep.pii-in-cache-key` | Yes | PII alanı cache anahtarında kullanılamaz |
| MITRE CWE | `CWE-532` | **R-NET-031** | `S1` | codeql | `codeql.csharp.security.CompanyFlowModelPiiLog` | Yes | PII alanı log çağrısına parametre olarak geçirilemez |
| MITRE CWE | `CWE-532` | **R-PII-001** | `S1` | codeql | `codeql.csharp.security.PiiLoggingSink` | Yes | PII alanı log çağrısına parametre olarak geçemez |
| MITRE CWE | `CWE-532` | **R-PII-008** | `S2` | opengrep | `opengrep.tostring-no-pii` | Yes | ToString() override'ı PII sızdıramaz |
| MITRE CWE | `CWE-543` | **R-NET-014** | `S1` | opengrep | `opengrep.no-singleton-dbcontext` | Yes | DbContext Singleton kaydedilemez |
| MITRE CWE | `CWE-598` | **R-PII-006** | `S1` | codeql | `opengrep.pii-in-url-query` | Yes | PII alanı URL query string'inde taşınamaz |
| MITRE CWE | `CWE-611` | **R-INJ-005** | `S1` | opengrep | `opengrep.xml-reader-dtd-disabled` | Yes | XXE: XML okuyucuda DTD kapalı |
| MITRE CWE | `CWE-639` | **R-AUTH-003** | `S1` | process | `process.idor-resource-ownership-check` | Yes | Kaynak sahipliği kontrolü olmadan id ile erişim yok |
| MITRE CWE | `CWE-643` | **R-INJ-007** | `S1` | codeql | `codeql.csharp.security.LdapXpathInjection` | Yes | LDAP/XPath sorgularında kaçış zorunlu |
| MITRE CWE | `CWE-667` | **R-NET-070** | `S1` | opengrep | `opengrep.semaphore-released-in-finally` | Yes | SemaphoreSlim / Mutex finally ile bırakılır |
| MITRE CWE | `CWE-670` | **R-SOLID-004** | `S1` | opengrep | `opengrep.no-notimplemented-exception` | Yes | NotImplementedException üretimde yok |
| MITRE CWE | `CWE-703` | **R-NET-009** | `S1` | roslyn | `Microsoft.CodeAnalysis.CSharp.CS4014` | Yes | Awaitsiz Task dönüşü yok (fire-and-forget) |
| MITRE CWE | `CWE-703` | **R-NET-081** | `S3` | opengrep | `opengrep.exception-filters-no-side-effects` | Yes | Exception filtreleri yan etki içeremez |
| MITRE CWE | `CWE-703` | **R-SEC-002** | `S2` | opengrep | `opengrep.no-throw-ex-rethrow` | Yes | Exception türünü değiştirmeden throw e yasağı |
| MITRE CWE | `CWE-703` | **R-SEC-007** | `S1` | opengrep | `opengrep.no-empty-catch` | Yes | Boş catch bloğu yok |
| MITRE CWE | `CWE-770` | **R-NET-017** | `S1` | opengrep | `opengrep.no-unpaged-tolist` | Yes | Sayfalama olmadan ToListAsync() yasak |
| MITRE CWE | `CWE-770` | **R-NET-073** | `S2` | opengrep | `opengrep.bounded-collections` | Yes | Sınırsız kuyruk / koleksiyon büyümesi yok |
| MITRE CWE | `CWE-78` | **R-INJ-002** | `S1` | codeql | `codeql.csharp.security.CommandInjection` | Yes | Komut çalıştırma kullanıcı girdisiyle beslenemez |
| MITRE CWE | `CWE-798` | **R-AUTH-006** | `S1` | codeql | `codeql.csharp.security.HardcodedJwtSecret` | Yes | Simetrik JWT anahtarı koddan gelemez |
| MITRE CWE | `CWE-798` | **R-NET-032** | `S1` | process | `process.gitleaks-secret-detection` | Yes | appsettings içinde sır yok |
| MITRE CWE | `CWE-829` | **R-SUP-006** | `S1` | opengrep | `opengrep.ci-action-pinned-by-sha` | Yes | CI action/workflow SHA ile pinlenir, tag ile değil |
| MITRE CWE | `CWE-833` | **R-NET-001** | `S1` | roslyn | `Microsoft.VisualStudio.Threading.Analyzers.VSTHRD002` | Yes | .Result / .Wait() / GetAwaiter().GetResult() yasak |
| MITRE CWE | `CWE-833` | **R-NET-006** | `S1` | opengrep | `opengrep.no-await-in-lock` | Yes | lock içinde await yok |
| MITRE CWE | `CWE-862` | **R-AUTH-001** | `S1` | archunit | `ArchUnitNET.EndpointAuthorizationRequired` | Yes | Her endpoint [Authorize] veya açık [AllowAnonymous] taşır |
| MITRE CWE | `CWE-89` | **R-INJ-001** | `S1` | codeql | `codeql.csharp.security.SqlInjection` | Yes | SQL string birleştirme yasak; parametreli sorgu |
| MITRE CWE | `CWE-89` | **R-NET-013** | `S1` | codeql | `codeql.csharp.security.EfFromSqlRawInjection` | Yes | FromSqlRaw yalnızca parametreli |
| MITRE CWE | `CWE-90` | **R-INJ-007** | `S1` | codeql | `codeql.csharp.security.LdapXpathInjection` | Yes | LDAP/XPath sorgularında kaçış zorunlu |
| MITRE CWE | `CWE-915` | **R-ARCH-005** | `S1` | archunit | `ArchUnitNET.DomainTypesMustNotAppearInApiSignatures` | Yes | Domain tipleri Api imzalarında görünemez |
| MITRE CWE | `CWE-916` | **R-CRY-004** | `S1` | opengrep | `opengrep.secure-password-hashing` | Yes | Parola hash'i PBKDF2/Argon2/bcrypt; ham SHA yasak |
| MITRE CWE | `CWE-918` | **R-INJ-004** | `S1` | codeql | `codeql.csharp.security.Ssrf` | Yes | SSRF: dış URL girdiden türetilemez |
| MITRE CWE | `CWE-942` | **R-CFG-003** | `S1` | opengrep | `opengrep.cors-no-wildcard-with-credentials` | Yes | CORS AllowAnyOrigin + credentials kombinasyonu yasak |
| Microsoft Framework Design Guidelines | `FrameworkDesignGuidelines/CompositionOverInheritance` | **R-SOLID-012** | `S3` | archunit | `ArchUnitNET.InheritanceDepthLimit` | Yes | Kalıtım derinliği ≤ 3; kompozisyon tercih edilir |
| Microsoft Framework Design Guidelines | `FrameworkDesignGuidelines/DeveloperExperience` | **R-NET-063** | `S2` | process | `process.treat-warnings-as-errors-ci` | Yes | TreatWarningsAsErrors yalnızca CI |
| Microsoft Framework Design Guidelines | `FrameworkDesignGuidelines/Encapsulation` | **R-ARCH-009** | `S3` | archunit | `ArchUnitNET.PreferInternalOverPublic` | Yes | internal varsayılan; public gerekçe ister |
| Microsoft Framework Design Guidelines | `FrameworkDesignGuidelines/Globalization` | **R-NET-051** | `S2` | roslyn | `Microsoft.CodeAnalysis.NetAnalyzers.CA1304` | Yes | Kültüre duyarlı işlemler açık |
| Microsoft Framework Design Guidelines | `FrameworkDesignGuidelines/Inheritance` | **R-SOLID-005** | `S2` | roslyn | `SonarAnalyzer.CSharp.S2325` | Yes | Sınıflar varsayılan olarak sealed olmalıdır |
| Microsoft Framework Design Guidelines | `FrameworkDesignGuidelines/Naming` | **R-NET-005** | `S3` | roslyn | `Microsoft.VisualStudio.Threading.Analyzers.VSTHRD200` | Yes | Task dönen metot adı Async ile biter |
| Microsoft Framework Design Guidelines | `FrameworkDesignGuidelines/PublicApiSurface` | **R-ARCH-008** | `S2` | roslyn | `PublicApiAnalyzers.RS0016` | Yes | Public API yüzeyi izlenir (istenmeyen genişleme yok) |
| Microsoft Framework Design Guidelines | `FrameworkDesignGuidelines/ValueTask` | **R-NET-008** | `S1` | roslyn | `Microsoft.CodeAnalysis.NetAnalyzers.CA2012` | Yes | ValueTask birden fazla kez await edilemez |
| NIST SP 800-218 SSDF | `PS.3` | **R-NET-061** | `S1` | process | `process.packages-lock-enforced` | Yes | packages.lock.json + --locked-mode |
| NIST SP 800-218 SSDF | `PS.3` | **R-SUP-001** | `S1` | process | `process.generate-sbom` | Yes | SBOM üretilir (CycloneDX/SPDX) |
| NIST SP 800-218 SSDF | `RV.2` | **R-AUT-003** | `S1` | process | `process.vulnerability-management-trace` | Yes | Güvenlik açığı yönetimi kaydı zorunlu (CVE → issue → düzeltme izi) |
| OWASP API Top 10:2023 | `API10:2023` | **R-INJ-004** | `S1` | codeql | `codeql.csharp.security.Ssrf` | Yes | SSRF: dış URL girdiden türetilemez |
| OWASP API Top 10:2023 | `API10:2023` | **R-NET-017** | `S1` | opengrep | `opengrep.no-unpaged-tolist` | Yes | Sayfalama olmadan ToListAsync() yasak |
| OWASP API Top 10:2023 | `API10:2023-BOLA` | **R-AUTH-001** | `S1` | archunit | `ArchUnitNET.EndpointAuthorizationRequired` | Yes | Her endpoint [Authorize] veya açık [AllowAnonymous] taşır |
| OWASP API Top 10:2023 | `API10:2023-BOLA` | **R-AUTH-003** | `S1` | process | `process.idor-resource-ownership-check` | Yes | Kaynak sahipliği kontrolü olmadan id ile erişim yok |
| OWASP ASVS v5.0 | `V1` | **R-INJ-001** | `S1` | codeql | `codeql.csharp.security.SqlInjection` | Yes | SQL string birleştirme yasak; parametreli sorgu |
| OWASP ASVS v5.0 | `V11` | **R-CRY-001** | `S1` | roslyn | `Microsoft.CodeAnalysis.NetAnalyzers.CA5350` | Yes | MD5, SHA1, DES, RC2, TripleDES yasak |
| OWASP ASVS v5.0 | `V11` | **R-CRY-004** | `S1` | opengrep | `opengrep.secure-password-hashing` | Yes | Parola hash'i PBKDF2/Argon2/bcrypt; ham SHA yasak |
| OWASP ASVS v5.0 | `V12` | **R-AUTH-005** | `S1` | opengrep | `opengrep.jwt-require-https-metadata` | Yes | RequireHttpsMetadata = false yasak |
| OWASP ASVS v5.0 | `V12` | **R-CFG-004** | `S2` | opengrep | `opengrep.security-headers-configured` | Yes | Güvenlik başlıkları tanımlı (HSTS, CSP, X-Content-Type-Options) |
| OWASP ASVS v5.0 | `V12` | **R-CRY-005** | `S1` | roslyn | `opengrep.no-certificate-validation-bypass` | Yes | Sertifika doğrulaması bypass edilemez |
| OWASP ASVS v5.0 | `V12` | **R-CRY-006** | `S1` | opengrep | `opengrep.tls-min-version` | Yes | TLS sürümü sabitlenmiş ve ≥ 1.2 |
| OWASP ASVS v5.0 | `V12` | **R-CRY-009** | `S1` | opengrep | `opengrep.no-http-plain-url` | Yes | http:// şemalı URL literal'i yasak |
| OWASP ASVS v5.0 | `V13` | **R-CFG-002** | `S1` | opengrep | `opengrep.no-developerexceptionpage-in-prod` | Yes | Geliştirme ayarları üretimde etkin olamaz (DeveloperExceptionPage) |
| OWASP ASVS v5.0 | `V13` | **R-NET-032** | `S1` | process | `process.gitleaks-secret-detection` | Yes | appsettings içinde sır yok |
| OWASP ASVS v5.0 | `V14` | **R-NET-031** | `S1` | codeql | `codeql.csharp.security.CompanyFlowModelPiiLog` | Yes | PII alanı log çağrısına parametre olarak geçirilemez |
| OWASP ASVS v5.0 | `V14` | **R-PII-001** | `S1` | codeql | `codeql.csharp.security.PiiLoggingSink` | Yes | PII alanı log çağrısına parametre olarak geçemez |
| OWASP ASVS v5.0 | `V14` | **R-PII-004** | `S1` | codeql | `codeql.csharp.security.PiiInExternalClientPayload` | Yes | PII alanı üçüncü taraf istemci payload'ına maskesiz gidemez |
| OWASP ASVS v5.0 | `V14` | **R-PII-006** | `S1` | codeql | `opengrep.pii-in-url-query` | Yes | PII alanı URL query string'inde taşınamaz |
| OWASP ASVS v5.0 | `V15` | **R-ARCH-001** | `S1` | archunit | `ArchUnitNET.DomainLayerMustNotDependOnExternalLayers` | Yes | Domain dış katmanlara bağımlı olamaz |
| OWASP ASVS v5.0 | `V15` | **R-ARCH-004** | `S1` | archunit | `ArchUnitNET.ApiMustNotDirectlyAccessInfrastructure` | Yes | Api katmanı Infrastructure'a doğrudan erişemez |
| OWASP ASVS v5.0 | `V16` | **R-NET-031** | `S1` | codeql | `codeql.csharp.security.CompanyFlowModelPiiLog` | Yes | PII alanı log çağrısına parametre olarak geçirilemez |
| OWASP ASVS v5.0 | `V16` | **R-NET-082** | `S1` | archunit | `ArchUnitNET.GlobalExceptionHandlerRequired` | Yes | Global exception handler zorunlu, stack trace dışarı sızmaz |
| OWASP ASVS v5.0 | `V16` | **R-NET-083** | `S1` | opengrep | `opengrep.security-events-logged` | Yes | Güvenlik olayları (auth başarısız, yetki reddi) loglanır |
| OWASP ASVS v5.0 | `V16` | **R-NET-084** | `S1` | codeql | `codeql.csharp.security.LogInjection` | Yes | Log injection: kullanıcı girdisi ham loglanamaz |
| OWASP ASVS v5.0 | `V16` | **R-NET-086** | `S3` | opengrep | `opengrep.log-level-convention` | Yes | Log seviyeleri tanımlı politikaya uyar (hata ≠ Information) |
| OWASP ASVS v5.0 | `V16` | **R-OBS-005** | `S1` | archunit | `ArchUnitNET.CriticalOperationsAuditLoggingRequired` | Yes | Kritik iş akışları için audit kaydı zorunlu |
| OWASP ASVS v5.0 | `V16` | **R-PII-001** | `S1` | codeql | `codeql.csharp.security.PiiLoggingSink` | Yes | PII alanı log çağrısına parametre olarak geçemez |
| OWASP ASVS v5.0 | `V16` | **R-SEC-006** | `S2` | codeql | `opengrep.no-exception-leak-to-client` | Yes | Hata detayları istemciye sızdırılamaz |
| OWASP ASVS v5.0 | `V16` | **R-SEC-008** | `S1` | codeql | `codeql.csharp.security.ExceptionInformationLeak` | Yes | Exception mesajı istemciye dönemez |
| OWASP ASVS v5.0 | `V2` | **R-INJ-009** | `S2` | archunit | `ArchUnitNET.InputModelValidationRequired` | Yes | Her public endpoint girdi modeli doğrulama attribute'u taşır |
| OWASP ASVS v5.0 | `V3` | **R-CFG-003** | `S1` | opengrep | `opengrep.cors-no-wildcard-with-credentials` | Yes | CORS AllowAnyOrigin + credentials kombinasyonu yasak |
| OWASP ASVS v5.0 | `V3` | **R-CFG-004** | `S2` | opengrep | `opengrep.security-headers-configured` | Yes | Güvenlik başlıkları tanımlı (HSTS, CSP, X-Content-Type-Options) |
| OWASP ASVS v5.0 | `V4` | **R-ARCH-005** | `S1` | archunit | `ArchUnitNET.DomainTypesMustNotAppearInApiSignatures` | Yes | Domain tipleri Api imzalarında görünemez |
| OWASP ASVS v5.0 | `V4` | **R-AUTH-009** | `S1` | roslyn | `SonarAnalyzer.CSharp.S4507` | Yes | Antiforgery token durum değiştiren endpoint'lerde |
| OWASP ASVS v5.0 | `V4` | **R-NET-058** | `S1` | opengrep | `opengrep.webhook-signature-verification` | Yes | Webhook imza doğrulaması zorunlu |
| OWASP ASVS v5.0 | `V5` | **R-INJ-003** | `S1` | codeql | `codeql.csharp.security.PathTraversal` | Yes | Path traversal: dosya yolu girdiden türetilemez |
| OWASP ASVS v5.0 | `V8` | **R-AUTH-001** | `S1` | archunit | `ArchUnitNET.EndpointAuthorizationRequired` | Yes | Her endpoint [Authorize] veya açık [AllowAnonymous] taşır |
| OWASP ASVS v5.0 | `V8` | **R-AUTH-002** | `S2` | opengrep | `opengrep.allow-anonymous-comment-justification` | Yes | [AllowAnonymous] gerekçe yorumu ister |
| OWASP ASVS v5.0 | `V9` | **R-AUTH-004** | `S1` | opengrep | `opengrep.jwt-validation-parameters` | Yes | JWT doğrulamada ValidateIssuer, ValidateAudience, ValidateLifetime açık |
| OWASP ASVS v5.0 | `V9` | **R-AUTH-006** | `S1` | codeql | `codeql.csharp.security.HardcodedJwtSecret` | Yes | Simetrik JWT anahtarı koddan gelemez |
| OWASP Top 10:2021 | `A03:2021` | **R-INJ-001** | `S1` | codeql | `codeql.csharp.security.SqlInjection` | Yes | SQL string birleştirme yasak; parametreli sorgu |
| OWASP Top 10:2021 | `A03:2021` | **R-INJ-002** | `S1` | codeql | `codeql.csharp.security.CommandInjection` | Yes | Komut çalıştırma kullanıcı girdisiyle beslenemez |
| OWASP Top 10:2021 | `A05:2021` | **R-INJ-005** | `S1` | opengrep | `opengrep.xml-reader-dtd-disabled` | Yes | XXE: XML okuyucuda DTD kapalı |
| OWASP Top 10:2021 | `A06:2021` | **R-NET-065** | `S1` | process | `process.no-vulnerable-nuget-packages` | Yes | dotnet list package --vulnerable temiz |
| OWASP Top 10:2021 | `A08:2021` | **R-INJ-006** | `S1` | codeql | `opengrep.typenamehandling-prohibited` | Yes | TypeNameHandling / polimorfik deserialization yasak |
| SLSA v1.0 | `L2` | **R-NET-060** | `S1` | process | `process.central-package-management` | Yes | Central Package Management aktif |
| SLSA v1.0 | `L2` | **R-NET-061** | `S1` | process | `process.packages-lock-enforced` | Yes | packages.lock.json + --locked-mode |
| SLSA v1.0 | `L2` | **R-SUP-001** | `S1` | process | `process.generate-sbom` | Yes | SBOM üretilir (CycloneDX/SPDX) |
| SLSA v1.0 | `L2` | **R-SUP-004** | `S2` | process | `process.nuget-package-signature-validation` | Yes | Paket imza doğrulaması açık |
| SLSA v1.0 | `L3` | **R-SUP-002** | `S2` | process | `process.sign-build-artifacts` | Yes | Build artefaktı imzalanır |
| SLSA v1.0 | `L3` | **R-SUP-006** | `S1` | opengrep | `opengrep.ci-action-pinned-by-sha` | Yes | CI action/workflow SHA ile pinlenir, tag ile değil |
