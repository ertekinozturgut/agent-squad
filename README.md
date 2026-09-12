# 🤖 Agent Squad

> **Antigravity AI IDE için 8 Kişilik Otonom Yazılım Geliştirme Squad'ı**  
> Clean Architecture, Domain-Driven Design (DDD), 23 GoF Tasarım Kalıbı, OWASP Top 10 Güvenlik Standartları ve Katı El Sıkışma (Handoff) Protokolleri.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform: Antigravity](https://img.shields.io/badge/Platform-Antigravity%20AI-purple.svg)](https://github.com/ertekinozturgut/agent-squad)
[![Tech: .NET 10 / C# 14](https://img.shields.io/badge/.NET-10.0-512BD4.svg)](https://dotnet.microsoft.com/)
[![Architecture: Clean Architecture](https://img.shields.io/badge/Architecture-Clean%20%26%20DDD-success.svg)](https://github.com/ertekinozturgut/agent-squad)
[![Design Patterns: 23 GoF](https://img.shields.io/badge/Design%20Patterns-Full%2023%20GoF%20%2B%20Enterprise-orange.svg)](.agents/skills/backend-engineer/SKILL.md)
[![Security: OWASP ASVS](https://img.shields.io/badge/Security-OWASP%20ASVS%20Level%202-red.svg)](.agents/rules/03-security-guardrails.md)
[![Quality: Zero Warnings](https://img.shields.io/badge/Quality-Zero%20Compiler%20Warnings-brightgreen.svg)](Directory.Build.props)

---

## 🌟 Genel Bakış

**Agent Squad**, tek bir yapay zeka modeline tüm yazılım geliştirme sürecini yüklemek yerine; endüstri standardı kanonik literatürlerle donatılmış **8 bağımsız uzman persona**, **5 bağlayıcı anayasal kural**, **tüm 23 Gang of Four (GoF) Tasarım Kalıbı** ve merkezi bir **Görev Durum Makinesi (`tasks.json` + `tasks.schema.json`)** ile çalışan kurumsal seviyede bir yapay zeka yazılım fabrikası mimarisidir.

### Temel Felsefe
- **Uzmanlaşma:** Her persona sadece kendi disiplininde (Analiz, Mimari, Kodlama, Güvenlik, Test) dünyanın en prestijli literatürlerine (BABOK, Uncle Bob, Evans, GoF, OWASP, Meszaros) dayanarak çalışır.
- **Karşılıklı Denetim (Checks & Balances):** Hiçbir geliştirici kendi kodunu onaylayamaz; QA ve Security kapılarından geçmeyen tek bir satır kod ana dala giremez.
- **WIP = 1 (Work-in-Progress):** Çoklu görev karmaşası ve bağlam kaybı engellenir; ekip tek seferde yalnızca tek bir atomik göreve odaklanır.
- **Tasarım Kalıpları Zorunluluğu:** Spagetti kod ve kontrolsüz switch/if-else dallanmaları yasaktır; her gereksinim için kanonik bir GoF/Enterprise deseni uygulanır.

---

## 🔄 Squad El Sıkışma (Handoff) Zinciri ve Durum Makinesi

Tüm görevler `tasks.json` üzerindeki durum makinesi doğrultusunda aşağıdaki 5 aşamalı katı el sıkışma zincirini izler:

```text
       ┌───────────┐
       │  pending  │ (Backlog'da bekleyen atomik görev)
       └─────┬─────┘
             │
             ▼
   [Aşama 1: Kapsam & Analiz] ────────► İş Analisti (BABOK v3 & JTBD & 4 Kademeli Gherkin)
             │
             ▼
   [Aşama 2: Mimari & UX Şartnamesi] ─► Çözüm Mimarı (Clean Arch/DDD/GoF) & UI/UX Tasarımcısı (Norman/Krug)
             │
             ├──────────────────────────► 🚪 [DoR Giriş Kapısı Onayı]
             ▼
   [Aşama 3: Geliştirme] ─────────────► Backend Engineer (.NET 10/Clean Code/23 GoF) & Razor Specialist
             │
             ▼
   [Aşama 4: Kalite & Güvenlik] ──────► QA Tester (xUnit/Adversarial) & Security Reviewer (OWASP/ASVS)
             │                          │
             │                          ├────── (Red / Revizyon Gerekli) ─────► ┌───────────────────┐
             │                          │                                       │ changes_requested │
             │                          │                                       └─────────┬─────────┘
             │                          │                                                 │ (Düzeltildi)
             │                          │ ◄───────────────────────────────────────────────┘
             ├──────────────────────────► 🚪 [DoD Çıkış Kapısı Onayı]
             ▼
      ┌───────────┐
      │ completed │ ──► Sıradaki 'pending' göreve geçiş
      └───────────┘
```

---

## 🧠 8 Personanın Uzmanlık Alanları

| Persona | Rol & Uzmanlık | Dayandığı Kanonik Literatür | Temel Çıktı & Sorumluluk |
| :--- | :--- | :--- | :--- |
| **`project-manager`** | Orkestratör & Akış Yöneticisi | PMBOK 7th, Scrum Guide, Accelerate (DORA) | `tasks.json` durum makinesi, WIP=1, revizyon döngüsü (`changes_requested`, `blocked`) ve DoR/DoD kontrolleri. |
| **`business-analyst`** | Değer & Çelişki Dedektörü | BABOK v3, Competing Against Luck (JTBD), Specification by Example | 4 kademeli Gherkin kabul kriterleri (`Happy`, `Validation`, `Conflict`, `Security`), Veri Sözlüğü ve sürtünmesiz akış. |
| **`solution-architect`** | Clean Architecture & DDD Mimarı | Clean Architecture (Uncle Bob), DDD (Eric Evans), Design Patterns (GoF) | Zengin Domain modelleri, Result sözleşmesi, katman sınırları ve Kurumsal Tasarım Kalıpları seçim rehberi. |
| **`backend-engineer`** | .NET 10 & 23 GoF Kalıbı Ustası | Clean Code (Uncle Bob), C# in Depth, GoF, Concurrency Cookbook | İnce Controller, AsNoTracking, 23 GoF Deseni, Result deseni, Guard Clauses, max 25 satır metotlar. |
| **`uiux-designer`** | UX & Tasarım Sistemi Yöneticisi | Design of Everyday Things, Don't Make Me Think, Refactoring UI, WCAG AA | Bootstrap 5.3 görsel hiyerarşi, 5 kademeli durum matrisi (`Hover`, `Focus`, `Loading` vb.), sıfır satır içi CSS. |
| **`razor-specialist`** | Modern Razor & Frontend Uzmanı | Bootstrap 5.3, ASP.NET Core Tag Helpers, HTML Living Standard | Modern `.cshtml`, double-submit engelleme, Partial vs ViewComponent, hem jQuery hem Vanilla JS validasyonu. |
| **`qa-tester`** | Çift Yönlü Test Avcısı | xUnit Test Patterns (Meszaros), Explore It!, ISTQB Technical | Gereksinim matrisi (RTM), sınır değer saldırıları (BVA), tasarım kalıbı testleri, sıfır veri kaybı denetimi. |
| **`security-reviewer`** | Siber Güvenlik & Kalite Denetçisi | OWASP Top 10 (2025), OWASP ASVS v4.0 Level 2, SEI CERT C# | CSRF, XSS, IDOR, Mass-Assignment, deadlock, bellek sızıntısı ve SonarAnalyzer / Semgrep denetimi. |

---

## 🏛️ Kapsamlı Tasarım Kalıpları Kataloğu (Full GoF & Enterprise)

`backend-engineer` ve `solution-architect` el kitapları, aşağıdaki **23 Gang of Four (GoF)** ve **4 Kurumsal .NET** tasarım kalıbını somut C# 14 / .NET 10 Clean Architecture kodlarıyla içerir:

| Kategori | Tasarım Kalıpları | Kullanım Alanı & Çözüm |
| :--- | :--- | :--- |
| **Yaratımsal (Creational)** | **Factory Method, Abstract Factory, Builder, Prototype, Singleton** | Varlık invariyantlarının korunması (`Order.Create`), test builder'ları, immutable konfigürasyon kopyalama ve DI singleton yönetimi. |
| **Yapısal (Structural)** | **Adapter, Bridge, Composite, Decorator, Facade, Flyweight, Proxy** | Dış API izolasyonu (Twilio/Stripe), cross-cutting caching/logging, alt sistem orkestrasyonu, bellek optimizasyonu ve yetki denetimi. |
| **Davranışsal (Behavioral)** | **Strategy, Chain of Responsibility, Command, Interpreter, Iterator, Mediator, Memento, Observer, State, Template Method, Visitor** | Dinamik iş kuralı dallanması, validasyon boru hatları, CQRS komutları, büyük veri akışları (`IAsyncEnumerable`), yaşam döngüsü durumları ve domain event'ler. |
| **Kurumsal .NET (Enterprise)** | **Specification, Result (ROP), Unit of Work & Repository, Strongly-Typed Options** | Tekrar kullanılabilir LINQ sorgu kriterleri, exceptionsız akış yönetimi, ACID işlem sınırları ve tip güvenli `IOptions<T>` yapılandırması. |

---

## 📜 5 Bağlayıcı Anayasa Kuralı (`.agents/rules/`)

1. **`01-squad-handoff-protocol.md`:** Görev döngüsü, rol geçişleri, DoR/DoD kapıları, `changes_requested` revizyon mekanizması ve WIP=1 akış anayasası.
2. **`02-architecture-invariants.md`:** Core katmanının sıfır dış bağımlılığı, ViewModel zorunluluğu, ince controller'lar, asenkron standartlar ve Tasarım Kalıpları değişmezleri.
3. **`03-security-guardrails.md`:** CSRF token zorunluluğu, sıfır `@Html.Raw()`, parametreli SQL ve derleyici seviyesinde sıfır uyarı politikası.
4. **`04-ui-design-invariants.md`:** Sıfır inline CSS, WCAG 2.2 AA kontrastı (4.5:1), 5 zorunlu bileşen durumu ve responsive empty state standartları.
5. **`05-backend-development-clean-code-standards.md`:** Fonksiyon yönetimi (max 25 satır, max 3 parametre, guard clauses), sınıf kapsamı (max 300 satır, Demeter yasası, Tell Don't Ask) ve OOP/Tasarım Kalıpları kuralları.

---

## 🛡️ Otomatik Analiz ve Denetim Motorları (100% Ücretsiz & Açık Kaynak)

Agent Squad, personeların manuel incelemesini desteklemek için sektör lideri iki otomatik analiz motoruyla tam entegre çalışır:

### 1. Semgrep MCP Server (OWASP Top 10 Güvenlik Taraması)
* **Araç:** [`semgrep/mcp`](https://github.com/semgrep/semgrep/tree/main/src/semgrep/mcp)
* **Kullanım:** Hazır şablon `mcp_config.template.json` dosyası `mcp_config.json` olarak eklenir. `security-reviewer` personası `git diff` ile değişen dosyalardaki SQL Injection, XSS, CSRF, IDOR ve Hardcoded Secrets açıklarını otomatik tarar.
```json
{
  "mcpServers": {
    "semgrep": {
      "command": "uvx",
      "args": ["semgrep-mcp", "-t", "stdio"]
    }
  }
}
```

### 2. SonarAnalyzer.CSharp & Roslynator (Clean Code & Zero Warnings)
* **Araç:** SonarSource'un resmi Roslyn tabanlı C# kural motoru.
* **Kullanım:** Projenin kök dizinindeki `Directory.Build.props` ile harici bir SonarQube sunucusu gerekmeksizin tüm Sonar Clean Code kurallarını (`Sxxxx`) derleyici zamanında çalıştırır.
* **Katı Politika:** `<TreatWarningsAsErrors>true</TreatWarningsAsErrors>` devrede olduğu için en ufak bir derleyici veya kod kokusu uyarısında derleme başarısız sayılır.

---

## 🚀 Projelerinizde Nasıl Kullanılır?

Agent Squad mimarisini herhangi bir yazılım projesinde devreye almak son derece basittir:

### 1. Dizin Yapısını Kopyalayın
Bu depodaki `.agents/` klasörünü hedef projenizin kök dizinine yapıştırın:
```bash
cp -r .agents/ /path/to/your/project/.agents/
```

### 2. Görev Kuyruğunu ve Şemasını Başlatın
`tasks.template.json` ve `tasks.schema.json` dosyalarını projenizin kök dizinine kopyalayın ve hedeflerinizi atomik görevler olarak tanımlayın:
```bash
cp tasks.template.json /path/to/your/project/tasks.json
cp tasks.schema.json /path/to/your/project/tasks.schema.json
```
*(İsteğe bağlı)* Semgrep MCP güvenlik tarayıcısını etkinleştirmek için:
```bash
cp mcp_config.template.json /path/to/your/project/mcp_config.json
```

### 3. Antigravity AI IDE ile Geliştirmeye Başlayın
Antigravity AI IDE projenizi açtığında:
- `.agents/rules/` altındaki anayasal kuralları arka planda sürekli aktif tutar.
- `.agents/skills/` altındaki mesleki el kitaplarını ilgili persona sahneye çıktığında otomatik olarak devreye alır.
- `tasks.json` dosyasını `tasks.schema.json` üzerinden doğrular; görevlerin DoR/DoD kapılarını ve revizyon döngülerini yönetir.

---

## 📄 Lisans

Bu proje [MIT Lisansı](LICENSE) altında açık kaynak olarak sunulmuştur.

## 👨‍💻 Geliştirici

**Ertekin Özturgut**  
- GitHub: [@ertekinozturgut](https://github.com/ertekinozturgut)
