#!/usr/bin/env node

/**
 * Harpia & UDAP Agent Squad - SDLC Orchestrator Runner
 * 
 * Deterministik kabuk: Git feature branch yönetimi, tasks.json durum makinesi,
 * kademeli kalite kapıları (Tier 1/2/3), devre kesici (Circuit Breaker) ve
 * görev başına izole çalışma alanı (.agents/tasks/{taskId}/) yönetimini sağlar.
 */

import fs from 'node:fs';
import path from 'node:path';
import { execSync } from 'node:child_process';

const CWD = process.cwd();
const CONFIG_PATH = path.join(CWD, '.agents', 'squad.config.json');
const TASKS_PATH = path.join(CWD, 'tasks.json');

// 1. Konfigürasyon Yükleme
function loadConfig() {
  const defaults = {
    stack: 'dotnet',
    branching: {
      enabled: true,
      prefix: 'feature/',
      baseBranch: 'main',
      autoMergeOnDoD: true,
      deleteOnMerge: true
    },
    circuitBreaker: {
      maxRejections: 3,
      onTrip: 'block_and_report',
      rcaDirectory: '.agents/tasks/{taskId}'
    },
    tasksDirectory: '.agents/tasks',
    tieredGates: {
      tier1: { name: 'Derleme & Birim Testler', commands: { dotnet: 'dotnet test', nodejs: 'npm test' } },
      tier2: { name: 'Mimari & SAST', commands: { dotnet: 'dotnet test', nodejs: 'npm test' } },
      tier3: { name: 'Mutasyon (Stryker) & CodeQL', commands: { dotnet: 'dotnet stryker', nodejs: 'npx stryker run' } }
    }
  };

  if (fs.existsSync(CONFIG_PATH)) {
    try {
      const userConfig = JSON.parse(fs.readFileSync(CONFIG_PATH, 'utf-8'));
      return { ...defaults, ...userConfig };
    } catch (e) {
      console.warn(`[UYARI] squad.config.json okunamadı, varsayılanlar kullanılıyor: ${e.message}`);
    }
  }
  return defaults;
}

// 2. tasks.json Yükleme & Kaydetme
function loadTasks() {
  if (!fs.existsSync(TASKS_PATH)) {
    console.error(`[HATA] tasks.json bulunamadı: ${TASKS_PATH}`);
    process.exit(1);
  }
  return JSON.parse(fs.readFileSync(TASKS_PATH, 'utf-8'));
}

function saveTasks(tasks) {
  fs.writeFileSync(TASKS_PATH, JSON.stringify(tasks, null, 2) + '\n', 'utf-8');
}

// 3. Git Yardımcıları
function getCurrentBranch() {
  try {
    return execSync('git rev-parse --abbrev-ref HEAD', { stdio: ['ignore', 'pipe', 'ignore'] }).toString().trim();
  } catch {
    return 'unknown';
  }
}

function runGit(cmd) {
  try {
    return execSync(`git ${cmd}`, { stdio: ['ignore', 'pipe', 'pipe'] }).toString().trim();
  } catch (err) {
    throw new Error(`Git hatası (git ${cmd}): ${err.stderr?.toString() || err.message}`);
  }
}

// 4. Şablon Oluşturucu (.agents/tasks/{taskId}/)
function scaffoldTaskDir(taskId, title, config) {
  const taskDir = path.join(CWD, config.tasksDirectory || '.agents/tasks', taskId);
  if (!fs.existsSync(taskDir)) {
    fs.mkdirSync(taskDir, { recursive: true });
  }

  const specPath = path.join(taskDir, 'spec.md');
  if (!fs.existsSync(specPath)) {
    const specTemplate = `# Görev Şartnamesi: ${taskId} - ${title}

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
`;
    fs.writeFileSync(specPath, specTemplate, 'utf-8');
  }

  const archPath = path.join(taskDir, 'arch.md');
  if (!fs.existsSync(archPath)) {
    const archTemplate = `# Mimari ve Tasarım Şartnamesi: ${taskId}

## 1. Mimari Katman Sınırları & Modeller
- **Etkilenen Katmanlar:** [Domain / Application / Infrastructure / UI]
- **ViewModel / DTO Kontratı:** [Tanımlanacak tipler]
- **Sonuç Deseni:** Result<T> / IResult

## 2. Uygulanacak Kurumsal Tasarım Kalıpları (Design Patterns)
- **Kalıp Adı:** [Örn: Specification, Factory Method, Strategy, Decorator]
- **Uygulama Gerekçesi:** [Neden bu kalıp seçildi?]

## 3. DoR (Definition of Ready) Kontrol Listesi
- [ ] Gherkin senaryoları tam ve eksiksiz mi?
- [ ] Katman bağımlılıkları sözleşmeye (contract.yaml) uygun mu?
- [ ] PII alanları belirlendi mi?
`;
    fs.writeFileSync(archPath, archTemplate, 'utf-8');
  }

  return taskDir;
}

// 5. Komut İşleyicileri
const commands = {
  status(config) {
    const tasks = loadTasks();
    const currentBranch = getCurrentBranch();
    console.log(`\n======================================================`);
    console.log(`  HARPIA & UDAP AGENT SQUAD - SDLC DURUM RAPORU`);
    console.log(`======================================================`);
    console.log(`Aktif Git Dalı: ${currentBranch}`);
    console.log(`Teknoloji Yığını: ${config.stack}`);
    console.log(`Toplam Görev: ${tasks.length}`);

    const inProgress = tasks.filter(t => t.status === 'in_progress' || t.status === 'changes_requested');
    const pending = tasks.filter(t => t.status === 'pending');
    const completed = tasks.filter(t => t.status === 'completed');
    const blocked = tasks.filter(t => t.status === 'blocked');

    console.log(`\nİstatistikler:`);
    console.log(`  - Devam Eden / Revizyonda: ${inProgress.length}`);
    console.log(`  - Bekleyen (Pending):     ${pending.length}`);
    console.log(`  - Tamamlanan (Completed):  ${completed.length}`);
    console.log(`  - Engellenen (Blocked):    ${blocked.length}`);

    if (inProgress.length > 0) {
      console.log(`\nAktif Görev(ler):`);
      inProgress.forEach(t => {
        console.log(`  [${t.id}] ${t.title}`);
        console.log(`    Durum: ${t.status} | Ret Sayısı: ${t.rejectionCount || 0}/3 | DoR: ${t.dorMet} | DoD: ${t.dodMet}`);
      });
    } else {
      console.log(`\nŞu anda çalışan aktif görev yok.`);
      if (pending.length > 0) {
        console.log(`Sıradaki görev: [${pending[0].id}] ${pending[0].title}`);
      }
    }
    console.log(`======================================================\n`);
  },

  next(config) {
    const tasks = loadTasks();
    let currentTask = tasks.find(t => t.status === 'in_progress' || t.status === 'changes_requested');

    if (!currentTask) {
      currentTask = tasks.find(t => t.status === 'pending');
      if (!currentTask) {
        console.log('[BİLGİ] Çalıştırılacak bekleyen görev kalmadı! Tüm görevler tamamlandı.');
        return;
      }
      currentTask.status = 'in_progress';
      saveTasks(tasks);
    }

    console.log(`\n🚀 [AKTİF GÖREV]: ${currentTask.id} - ${currentTask.title}`);

    // Branch yönetimi
    if (config.branching?.enabled) {
      const targetBranch = `${config.branching.prefix || 'feature/'}${currentTask.id}`;
      const currentBranch = getCurrentBranch();

      if (currentBranch !== targetBranch) {
        try {
          runGit(`checkout -b ${targetBranch}`);
          console.log(`[GIT] Yeni feature branch açıldı ve geçildi: ${targetBranch}`);
        } catch {
          try {
            runGit(`checkout ${targetBranch}`);
            console.log(`[GIT] Mevcut feature branch'e geçildi: ${targetBranch}`);
          } catch (e) {
            console.error(`[HATA] Git branch açılamadı: ${e.message}`);
          }
        }
      } else {
        console.log(`[GIT] Zaten hedef branch üzerindesiniz: ${targetBranch}`);
      }
    }

    // Görev klasörü ve şablonlar
    const taskDir = scaffoldTaskDir(currentTask.id, currentTask.title, config);
    console.log(`[SÖZLEŞME] Görev çalışma alanı hazır: ${taskDir}`);
    console.log(`  - Şartname: ${path.join(taskDir, 'spec.md')}`);
    console.log(`  - Mimari:   ${path.join(taskDir, 'arch.md')}`);
    console.log(`\nSıradaki Adım: İş Analisti (spec.md) ve Sistem Mimarı (arch.md) el sıkışmasını tamamlayın.\n`);
  },

  verify(config, args) {
    const tierArg = args.find(a => a.startsWith('--tier=') || a === '-t');
    let tier = 'tier1';
    if (tierArg) {
      tier = tierArg.startsWith('--tier=') ? tierArg.split('=')[1] : args[args.indexOf('-t') + 1];
    } else {
      const nextArg = args[args.indexOf('verify') + 1];
      if (nextArg && ['1', '2', '3', 'tier1', 'tier2', 'tier3'].includes(nextArg)) {
        tier = nextArg.startsWith('tier') ? nextArg : `tier${nextArg}`;
      }
    }

    const gateConfig = config.tieredGates?.[tier];
    if (!gateConfig) {
      console.error(`[HATA] Geçersiz veya tanımlanmamış kademe (tier): ${tier}`);
      process.exit(1);
    }

    const cmd = gateConfig.commands?.[config.stack] || gateConfig.commands?.custom;
    if (!cmd) {
      console.error(`[HATA] '${config.stack}' yığını için ${tier} komutu tanımlanmamış!`);
      process.exit(1);
    }

    console.log(`\n🔍 [KAPISI KOŞULUYOR]: ${tier.toUpperCase()} - ${gateConfig.name}`);
    console.log(`Komut: ${cmd}\n`);

    const startTime = Date.now();
    try {
      execSync(cmd, { stdio: 'inherit' });
      const duration = ((Date.now() - startTime) / 1000).toFixed(1);
      console.log(`\n✅ [BAŞARILI] ${tier.toUpperCase()} kapısı ${duration}s içinde başarıyla tamamlandı!\n`);
    } catch (err) {
      const duration = ((Date.now() - startTime) / 1000).toFixed(1);
      console.error(`\n❌ [BAŞARISIZ] ${tier.toUpperCase()} kapısı ${duration}s sonunda kırıldı!`);
      process.exit(1);
    }
  },

  reject(config, args) {
    const tasks = loadTasks();
    const currentTask = tasks.find(t => t.status === 'in_progress' || t.status === 'changes_requested');

    if (!currentTask) {
      console.error('[HATA] Reddedilecek aktif görev (in_progress/changes_requested) bulunamadı!');
      process.exit(1);
    }

    let reason = 'Belirtilmemiş ret gerekçesi.';
    const reasonIdx = args.findIndex(a => a === '--reason' || a === '-r');
    if (reasonIdx !== -1 && args[reasonIdx + 1]) {
      reason = args.slice(reasonIdx + 1).join(' ');
    }

    currentTask.rejectionCount = (currentTask.rejectionCount || 0) + 1;
    currentTask.reviewNotes = currentTask.reviewNotes || [];
    currentTask.reviewNotes.push(`[${new Date().toISOString()}] Ret #${currentTask.rejectionCount}: ${reason}`);

    const maxRejections = config.circuitBreaker?.maxRejections || 3;

    if (currentTask.rejectionCount >= maxRejections) {
      currentTask.status = 'blocked';
      saveTasks(tasks);

      // RCA Raporu Üret
      const taskDir = path.join(CWD, config.tasksDirectory || '.agents/tasks', currentTask.id);
      if (!fs.existsSync(taskDir)) fs.mkdirSync(taskDir, { recursive: true });

      const rcaPath = path.join(taskDir, 'rca-report.md');
      const rcaContent = `# Kök Neden Analizi ve Devre Kesici Raporu (RCA)

**Görev:** [${currentTask.id}] ${currentTask.title}
**Tarih:** ${new Date().toISOString()}
**Durum:** BLOCKED (Devre Kesici Tetiklendi)
**Ret Sayısı:** ${currentTask.rejectionCount} / ${maxRejections}

---

## 1. Başarısızlık Geçmişi
${currentTask.reviewNotes.map(n => `- ${n}`).join('\n')}

---

## 2. Devre Kesici Tetiklenme Sebebi
Görev, izin verilen maksimum ret döngüsü sınırını (${maxRejections}) aşmıştır.
Sonsuz döngüyü, token israfını ve kod tabanının bozulmasını engellemek için otonom akış durdurulmuştur.

---

## 3. İnsan Eskalasyonu ve Eylem Planı
- [ ] Geliştirici ve Mimar mimari şartnameyi yeniden gözden geçirmelidir.
- [ ] Kırılan test/mutant gerekçesi değerlendirilmelidir.
- [ ] Manuel onay verildikten sonra durum \`in_progress\` yapılarak akış devam ettirilebilir.
`;
      fs.writeFileSync(rcaPath, rcaContent, 'utf-8');

      console.log(`\n🚨 [DEVRE KESİCİ DEVREYE GİRDİ! - CIRCUIT BREAKER TRIPPED]`);
      console.log(`Görev ${maxRejections} kez reddedildi ve 'blocked' durumuna alındı.`);
      console.log(`RCA Raporu oluşturuldu: ${rcaPath}`);
      console.log(`Lütfen raporu inceleyip insan müdahalesiyle karara bağlayın.\n`);
    } else {
      currentTask.status = 'changes_requested';
      saveTasks(tasks);
      console.log(`\n⚠️ [REVİZYON TALEBİ] Görev 'changes_requested' durumuna alındı.`);
      console.log(`Kalan deneme hakkı: ${maxRejections - currentTask.rejectionCount}`);
      console.log(`Gerekçe: ${reason}\n`);
    }
  },

  complete(config) {
    const tasks = loadTasks();
    const currentTask = tasks.find(t => t.status === 'in_progress' || t.status === 'changes_requested');

    if (!currentTask) {
      console.error('[HATA] Tamamlanacak aktif görev bulunamadı!');
      process.exit(1);
    }

    currentTask.status = 'completed';
    currentTask.dodMet = true;
    saveTasks(tasks);

    console.log(`\n🎉 [GÖREV TAMAMLANDI]: ${currentTask.id} - ${currentTask.title}`);

    if (config.branching?.enabled) {
      const baseBranch = config.branching.baseBranch || 'main';
      const featureBranch = `${config.branching.prefix || 'feature/'}${currentTask.id}`;
      const currentBranch = getCurrentBranch();

      if (currentBranch === featureBranch) {
        try {
          console.log(`[GIT] ${baseBranch} dalına dönülüyor...`);
          runGit(`checkout ${baseBranch}`);

          if (config.branching.autoMergeOnDoD) {
            console.log(`[GIT] ${featureBranch} dalı ${baseBranch} içine merge ediliyor...`);
            runGit(`merge --no-ff -m "feat(${currentTask.id}): ${currentTask.title}" ${featureBranch}`);
            console.log(`[GIT] Başarıyla merge edildi.`);

            if (config.branching.deleteOnMerge) {
              runGit(`branch -d ${featureBranch}`);
              console.log(`[GIT] Feature branch silindi: ${featureBranch}`);
            }
          }
        } catch (err) {
          console.error(`[HATA] Git merge/checkout işlemi başarısız: ${err.message}`);
        }
      }
    }

    console.log(`\nDoD sağlandı, görev kapatıldı. Sıradaki göreve geçmek için 'node .agents/runner/squad-runner.mjs next' çalıştırın.\n`);
  }
};

// Ana Çalıştırıcı
function main() {
  const args = process.argv.slice(2);
  const command = args[0] || 'status';
  const config = loadConfig();

  if (commands[command]) {
    commands[command](config, args);
  } else {
    console.log(`
Kullanım: node .agents/runner/squad-runner.mjs <komut> [seçenekler]

Komutlar:
  status                     Genel SDLC durumunu ve aktif görevi gösterir.
  next                       Sıradaki göreve geçer, feature branch açar, şablonları hazırlar.
  verify --tier=<1|2|3>      Kademeli kalite kapısını çalıştırır (1: Build/Test, 2: SAST, 3: Stryker).
  reject --reason="<metin>"  Görevi reddeder, sayacı artırır (3. rette devre kesici devreye girer).
  complete                   Görevi tamamlar, DoD'yi onaylar ve ana dala temiz merge eder.
`);
  }
}

main();
