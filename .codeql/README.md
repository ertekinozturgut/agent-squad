# CodeQL Özel Kontrol Paketi (C# Quality, SonarQube & Design Patterns)

Bu paket, .NET / C# projelerinde statik analizi ileri seviyeye taşıyan **35 adet özel CodeQL sorgusu (.ql)** ve **veri akışı model paketinden (.yml)** oluşur.

---

## 📂 Sorgu Paket Yapısı (`.codeql/queries/`)

```text
.codeql/
├── models/
│   ├── qlpack.yml
│   └── company-flow-model.yml       # Taint tracking & PII sızıntı modelleri
└── queries/
    ├── qlpack.yml
    ├── codeql-suites/
    │   └── csharp-quality-rules.qls # 35 sorguyu tek komutta çalıştıran suite
    ├── design-patterns/             # 8 Tasarım Kalıbı Kontrolü
    ├── sonarqube-quality/           # 11 SonarQube Temiz Kod & Hata Kontrolü
    └── senior-engineering/          # 16 Senior Yazılımcı Eşzamanlılık, EF Core & Güvenlik Kontrolü
```

---

## 🎯 35 CodeQL Kontrolü Kataloğu

### 1. 🧩 Tasarım Kalıpları (Design Patterns - 8 Kontrol)
| Kural Adı / Dosya | Şiddet | Açıklama ve Kural Standardı |
| :--- | :---: | :--- |
| `SingletonBrokenDoubleCheck.ql` | ERROR | Singleton çift kilit kontrolünde (double-checked locking) `volatile` eksikliği (Bellek yeniden sıralama hatası). |
| `RepositoryLeakingIQueryable.ql` | WARNING | Repository arayüzlerinin `IQueryable<T>` sızdırması; Specification pattern veya `IReadOnlyList<T>` zorunluluğu. |
| `ServiceLocatorAntiPattern.ql` | ERROR | `IServiceProvider.GetService()` ile Service Locator anti-deseni; doğrudan constructor injection zorunluluğu. |
| `ObserverMissingUnsubscribe.ql` | WARNING | `+=` ile event dinleyip `Dispose` içinde `-=` ile abonelikten çıkmayarak bellek sızıntısına yol açma. |
| `FactoryViolationConcreteReturn.ql` | WARNING | Factory Method'un arayüz/soyut sınıf yerine somut sınıf dönmesi (DIP ihlali). |
| `StrategyComplexSwitchSmell.ql` | WARNING | 6 veya daha fazla dallanma içeren dev `switch` blokları (Strategy / State deseni adayı kod kokusu). |
| `UnitOfWorkMultipleSaves.ql` | WARNING | Tek metot içinde birden fazla bağımsız `SaveChangesAsync()` çağrısı (Atomik Unit of Work ihlali). |
| `DecoratorBypassingInner.ql` | ERROR | Decorator sınıfının sarmaladığı iç bileşene (`inner`) çağrıyı delege etmemesi. |

---

### 2. 🧹 SonarQube Temiz Kod & Hata Yakalama (11 Kontrol)
| Kural Adı / Dosya | Şiddet | İlgili SonarQube Kuralı ve Kapsam |
| :--- | :---: | :--- |
| `EmptyCatchBlock.ql` | ERROR | **Sonar S2486 / S1166:** İstisnayı loglamadan yutan boş catch bloğu. |
| `ThrowExRethrow.ql` | ERROR | **Sonar S1144 / CA2200:** `throw ex;` ile orijinal çağrı yığını izini (stack trace) sıfırlama. |
| `MissingDisposeOnIDisposable.ql` | ERROR | **Sonar S2930 / CA2000:** `IDisposable` nesnenin `using` bloğuna alınmadan serbest bırakılması. |
| `PublicFieldEncapsulationViolation.ql` | WARNING | **Sonar S1104 / CA1051:** Public alanların kapsüllemeyi çiğnemesi (Property kullanımı zorunluluğu). |
| `NestedTernaryOperator.ql` | WARNING | **Sonar S3358:** İç içe üçlü koşul işleçleri (`? :`) ile bilişsel karmaşıklık artışı. |
| `RedundantNullCheck.ql` | WARNING | **Sonar S2583:** Zaten kontrol edilmiş veya non-null olan değişkende gereksiz null kontrolü. |
| `ConstantConditionInLoop.ql` | ERROR | **Sonar S2189:** İçinde `break`/`return` olmayan sabit koşullu sonsuz döngü. |
| `RawExceptionThrow.ql` | WARNING | **Sonar S112:** `throw new Exception()` veya `SystemException` ile ham istisna fırlatma. |
| `FatalExceptionCaught.ql` | ERROR | **Sonar S2142:** `OutOfMemoryException` veya `StackOverflowException` gibi ölümcül istisnaların yakalanması. |
| `BroadCatchBlock.ql` | WARNING | **Sonar S2221:** Yeniden fırlatılmayan genel `catch (Exception)` blokları. |
| `UnusedPrivateField.ql` | WARNING | **Sonar S1450 / S1068:** Sınıf içinde tanımlanıp hiç okunmayan ölü private alanlar. |

---

### 3. 🚀 Senior Yazılımcı Standartları (Eşzamanlılık, EF Core, Güvenlik - 16 Kontrol)
| Kural Adı / Dosya | Şiddet | Senior Mühendislik İlkesi ve Açıklama |
| :--- | :---: | :--- |
| `SyncBlockingTaskResult.ql` | ERROR | **R-NET-001:** `.Result`, `.Wait()`, `.GetAwaiter().GetResult()` ile thread pool starvation ve deadlock riski. |
| `AsyncVoidMethod.ql` | ERROR | **R-NET-002:** Await edilemeyen ve process crash'e yol açan `async void` metotlar. |
| `AwaitInsideLock.ql` | ERROR | **R-NET-006:** `lock` bloğu içinde `await` çalıştırma (Monitor deadlock). |
| `LockOnThisOrType.ql` | ERROR | **CA2002:** `lock(this)` veya `lock(typeof(...))` ile dıştan kilitlenmeye açık senkronizasyon. |
| `NewHttpClientInstance.ql` | ERROR | **R-NET-022:** `new HttpClient()` açarak işletim sistemi soketlerini tüketme (Socket Exhaustion). |
| `CancellationTokenDropped.ql` | WARNING | **R-NET-004:** Metoda gelen `CancellationToken`'ın alt asenkron çağrılara iletilmeyip zincirin kırılması. |
| `EfCoreMissingAsNoTracking.ql` | WARNING | **R-NET-010:** Salt okunur sorgularda `.AsNoTracking()` kullanılmayarak bellek ve CPU israfı yapılması. |
| `EfCoreUnpagedToList.ql` | ERROR | **R-NET-017:** Sayfalama (`Skip/Take`) olmaksızın veritabanından sınırsız `ToListAsync()` çekilmesi (OOM riski). |
| `DateTimeNowDirectUsage.ql` | ERROR | **R-NET-050:** `DateTime.Now/UtcNow` doğrudan çağrısı; test edilebilir `TimeProvider` soyutlaması zorunluluğu. |
| `SensitiveDataLogged.ql` | ERROR | **R-PII-001 / CWE-532:** Şifre, token, TCKN gibi hassas verilerin log formatlarına doğrudan yazılması. |
| `InsecureRandomUsage.ql` | ERROR | **R-CRY-003 / CWE-338:** Güvenlik/kripto akışlarında tahmin edilebilir `System.Random` kullanımı. |
| `RawSqlStringInterpolation.ql` | ERROR | **R-INJ-001 / CWE-89:** `FromSqlRaw` veya `ExecuteSqlRaw` içinde string interpolasyonu ile SQL Injection riski. |
| `UnvalidatedRedirect.ql` | ERROR | **CWE-601:** `Url.IsLocalUrl()` doğrulaması yapılmadan kullanıcı parametresiyle açık yönlendirme (Open Redirect). |
| `HardcodedSecretLiteral.ql` | ERROR | **CWE-798:** Kaynak kodda sabit API key, gizli anahtar veya parola tanımlama. |
| `ThreadSleepInAsyncContext.ql` | ERROR | **R-TST-003:** Asenkron metot içinde thread havuzu worker'ını kilitleyen `Thread.Sleep()` kullanımı. |
| `UnboundedChannelUsage.ql` | WARNING | **R-NET-073:** `Channel.CreateUnbounded` ile backpressure olmaksızın sınırsız kuyruk şişmesi riski. |

---

## ⚡ Çalıştırma Komutları

```bash
# 1. Veritabanını oluştur:
codeql database create codeql-db --language=csharp --command="dotnet build"

# 2. Tüm 35 kuralı içeren suite'i çalıştır:
codeql database analyze codeql-db .codeql/queries/codeql-suites/csharp-quality-rules.qls \
    --format=sarif-latest --output=codeql-results.sarif
```
