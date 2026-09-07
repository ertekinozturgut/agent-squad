# 🤖 Agent Squad

> **Antigravity AI IDE için 8 Kişilik Otonom Yazılım Geliştirme Squad'ı**  
> Clean Architecture, Domain-Driven Design (DDD), OWASP Top 10 Güvenlik Standartları ve Katı El Sıkışma (Handoff) Protokolleri.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform: Antigravity](https://img.shields.io/badge/Platform-Antigravity%20AI-purple.svg)](https://github.com/ertekinozturgut/agent-squad)
[![Tech: .NET 10 / C# 14](https://img.shields.io/badge/.NET-10.0-512BD4.svg)](https://dotnet.microsoft.com/)
[![Architecture: Clean Architecture](https://img.shields.io/badge/Architecture-Clean%20%26%20DDD-success.svg)](https://github.com/ertekinozturgut/agent-squad)

---

## 🌟 Genel Bakış

**Agent Squad**, tek bir yapay zeka modeline tüm yazılım geliştirme sürecini yüklemek yerine; endüstri standardı kanonik literatürlerle donatılmış **8 bağımsız uzman persona**, **5 bağlayıcı anayasal kural** ve merkezi bir **Görev Durum Makinesi (`tasks.json`)** ile çalışan kurumsal seviyede bir yazılım fabrikası mimarisidir.

### Temel Felsefe
- **Uzmanlaşma:** Her persona sadece kendi disiplininde (Analiz, Mimari, Kodlama, Güvenlik, Test) dünyanın en prestijli literatürlerine dayanarak çalışır.
- **Karşılıklı Denetim (Checks & Balances):** Hiçbir geliştirici kendi kodunu onaylayamaz; QA ve Security kapılarından geçmeyen tek bir satır kod ana dala giremez.
- **WIP = 1 (Work-in-Progress):** Çoklu görev karmaşası ve bağlam kaybı engellenir; ekip tek seferde tek bir atomik göreve odaklanır.

---

## 🔄 Squad El Sıkışma (Handoff) Zinciri

Tüm görevler aşağıdaki 5 aşamalı katı el sıkışma zincirini izler:

```text
       ┌───────────┐
       │  pending  │ (Backlog'da bekleyen atomik görev)
       └─────┬─────┘
             │
             ▼
   [Aşama 1: Kapsam & Analiz] ────────► İş Analisti (BABOK & JTBD & 4 Kademeli Gherkin)
             │
             ▼
   [Aşama 2: Mimari & UX Şartnamesi] ─► Çözüm Mimarı (Clean Arch/DDD) & UI/UX Tasarımcısı (Norman/Krug)
             │
             ├──────────────────────────► 🚪 [DoR Giriş Kapısı Onayı]
             ▼
   [Aşama 3: Geliştirme] ─────────────► Backend Engineer (.NET 10/Clean Code) & Razor Specialist (Tag Helpers)
             │
             ▼
   [Aşama 4: Kalite & Güvenlik] ──────► QA Tester (xUnit/Adversarial) & Security Reviewer (OWASP/ASVS)
             │
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
| **`project-manager`** | Orkestratör & Akış Yöneticisi | PMBOK 7th, Scrum Guide, Accelerate (DORA) | `tasks.json` orkestrasyonu, WIP=1 ve DoR/DoD kapı kontrolleri. |
| **`business-analyst`** | Değer & Çelişki Dedektörü | BABOK v3, Competing Against Luck (JTBD), Specification by Example | 4 kademeli Gherkin kabul kriterleri, Veri Sözlüğü ve sürtünmesiz akış. |
| **`solution-architect`** | Clean Architecture & DDD Mimarı | Clean Architecture (Uncle Bob), DDD (Eric Evans), PoEAA | Entity, Value Object, Result deseni sözleşmeleri ve katman sınırları. |
| **`backend-engineer`** | .NET 10 & Clean Code Ustası | Clean Code (Uncle Bob), C# in Depth, CLR via C#, Concurrency Cookbook | İnce Controller, AsNoTracking, Result deseni, Guard Clauses, max 25 satır. |
| **`uiux-designer`** | UX & Tasarım Sistemi Yöneticisi | Design of Everyday Things, Don't Make Me Think, Refactoring UI, WCAG AA | Bootstrap 5.3 görsel hiyerarşi, 5 kademeli durum matrisi, form UX. |
| **`razor-specialist`** | Modern Razor & Frontend Uzmanı | Bootstrap 5.3, ASP.NET Core Tag Helpers, HTML Living Standard | Modern `.cshtml`, double-submit engelleme, Partial vs ViewComponent. |
| **`qa-tester`** | Çift Yönlü Test Avcısı | xUnit Test Patterns (Meszaros), Explore It!, ISTQB Technical | Gereksinim matrisi (RTM), sınır değer saldırıları (BVA), sıfır veri kaybı. |
| **`security-reviewer`** | Siber Güvenlik & Kalite Denetçisi | OWASP Top 10 (2025), OWASP ASVS v4.0 Level 2, SEI CERT C# | CSRF, XSS, IDOR, Mass-Assignment, deadlock ve bellek sızıntısı denetimi. |

---

## 📜 5 Bağlayıcı Anayasa Kuralı (`.agents/rules/`)

1. **`01-squad-handoff-protocol.md`:** Görev döngüsü, rol geçişleri, DoR/DoD kapıları ve WIP=1 akış anayasası.
2. **`02-architecture-invariants.md`:** Core katmanının sıfır dış bağımlılığı, ViewModel zorunluluğu, ince controller ve asenkron standartlar.
3. **`03-security-guardrails.md`:** CSRF token zorunluluğu, sıfır `@Html.Raw()`, parametreli SQL ve sıfır derleyici uyarısı.
4. **`04-ui-design-invariants.md`:** Sıfır inline CSS, WCAG 2.2 AA kontrastı (4.5:1), 5 zorunlu bileşen durumu ve empty state standartları.
5. **`05-backend-development-clean-code-standards.md`:** Fonksiyon yönetimi (max 25 satır, max 3 parametre, guard clauses), sınıf kapsamı (max 300 satır, Demeter yasası, Tell Don't Ask) ve OOP kuralları.

---

## 🛡️ Otomatik Analiz ve Denetim Motorları (100% Ücretsiz & Açık Kaynak)

Agent Squad, personeların manuel incelemesini desteklemek için sektör lideri iki otomatik analiz motoruyla tam entegre çalışır:

### 1. Semgrep MCP Server (OWASP Top 10 Güvenlik Taraması)
* **Araç:** [`semgrep/mcp`](https://github.com/semgrep/semgrep/tree/main/src/semgrep/mcp)
* **Kullanım:** `mcp_config.json` içine eklenir. `security-reviewer` personası `git diff` ile sadece değişen dosyalardaki SQL Injection, XSS, CSRF, IDOR ve Hardcoded Secrets açıklarını tarar.
```json
"semgrep": {
  "command": "uvx",
  "args": ["semgrep-mcp", "-t", "stdio"]
}
```

### 2. SonarAnalyzer.CSharp & Roslynator (Clean Code & Code Smell)
* **Araç:** SonarSource'un resmi Roslyn tabanlı C# kural motoru.
* **Kullanım:** Projenin kök dizinindeki `Directory.Build.props` ile harici bir SonarQube sunucusu gerekmeksizin tüm Sonar Clean Code kurallarını (`Sxxxx`) derleyici zamanında çalıştırır.

---

## 🚀 Projelerinizde Nasıl Kullanılır?

Agent Squad mimarisini herhangi bir yazılım projesinde devreye almak son derece basittir:

### 1. Dizin Yapısını Kopyalayın
Bu depodaki `.agents/` klasörünü hedef projenizin kök dizinine yapıştırın:
```bash
cp -r .agents/ /path/to/your/project/.agents/
```

### 2. Görev Kuyruğunu Başlatın
`tasks.template.json` dosyasını `tasks.json` olarak projenizin kök dizinine kopyalayın ve hedeflerinizi atomik görevler olarak tanımlayın:
```bash
cp tasks.template.json /path/to/your/project/tasks.json
```

### 3. Antigravity ile Geliştirmeye Başlayın
Antigravity AI IDE projenizi açtığında:
- `.agents/rules/` altındaki anayasal kuralları arka planda sürekli aktif tutar.
- `.agents/skills/` altındaki mesleki el kitaplarını ilgili persona sahneye çıktığında otomatik olarak devreye alır.

---

## 📄 Lisans

Bu proje [MIT Lisansı](LICENSE) altında açık kaynak olarak sunulmuştur.

## 👨‍💻 Geliştirici

**Ertekin Özturgut**  
- GitHub: [@ertekinozturgut](https://github.com/ertekinozturgut)
