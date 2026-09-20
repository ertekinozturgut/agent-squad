using System;
using System.Collections.Generic;
using ArchUnitNET.Domain;
using ArchUnitNET.Fluent;
using ArchUnitNET.Loader;
using ArchUnitNET.xUnit;
using Xunit;
using static ArchUnitNET.Fluent.ArchRuleDefinition;

namespace Company.ArchitectureTests
{
    /// <summary>
    /// UDAP .NET v2 mimari değişmezleri.
    /// Test metot adları <c>.agents/rules_registry.yaml</c> içindeki
    /// <c>enforced_by: ArchUnitNET.&lt;MetotAdı&gt;</c> değerleriyle BİREBİR aynı olmalıdır;
    /// <c>bash .agents/verify.sh</c> bu eşleşmeyi doğrular.
    /// </summary>
    public class ArchitectureRulesTests
    {
        private const string Domain = "Company.Domain";
        private const string Application = "Company.Application";
        private const string Infrastructure = "Company.Infrastructure";
        private const string Api = "Company.Api";
        private const string Endpoints = "Company.Api.Endpoints";
        private const string Features = "Company.Features";
        private const string SharedKernel = "Company.SharedKernel";
        private const string Integration = "Company.Integration";
        private const string PiiNamespace = "Company.Domain.Pii";
        private const string IntegrationTests = "Company.IntegrationTests";

        /// <summary>
        /// Mimari grafiği, çözümün ÜRÜN assembly'lerinden kurulur.
        /// Yalnızca test assembly'si yüklenirse her kural boş küme üzerinde çalışır ve
        /// sessizce geçer; bu yüzden ürün assembly'leri <see cref="ProductAssemblies"/>
        /// üzerinden açıkça eklenir. Hedef projeye uyarlarken bu listeyi güncelleyin.
        /// </summary>
        private static readonly Architecture Architecture = BuildArchitecture();

        private static Architecture BuildArchitecture()
        {
            var loader = new ArchLoader();
            var assemblies = ProductAssemblies();

            if (assemblies.Count == 0)
            {
                throw new InvalidOperationException(
                    "Mimari testler hiçbir ürün assembly'si bulamadı. " +
                    "ProductAssemblies() metoduna hedef çözümün Domain/Application/Infrastructure/Api " +
                    "assembly'lerini ekleyin; aksi halde tüm mimari kuralları boş küme üzerinde " +
                    "çalışır ve sahte biçimde 'yeşil' döner.");
            }

            foreach (var assembly in assemblies)
            {
                loader.LoadAssemblies(assembly);
            }

            return loader.Build();
        }

        /// <summary>
        /// Denetlenecek ürün assembly'leri. Her katmandan bir marker tip kullanılır;
        /// böylece assembly adı değişse bile derleme zamanında referans korunur.
        /// Hedef projeye uyarlarken bu tipleri kendi marker tiplerinizle değiştirin.
        /// </summary>
        private static IReadOnlyList<System.Reflection.Assembly> ProductAssemblies()
        {
            return new[]
            {
                typeof(SampleDomainEntity).Assembly,
            };
        }

        // R-ARCH-001: Domain dış katmanlara bağımlı olamaz
        [Fact]
        public void DomainLayerMustNotDependOnExternalLayers()
        {
            IArchRule rule = Types().That().ResideInNamespace(Domain)
                .Should().NotDependOnAny(
                    Types().That().ResideInNamespace(Application)
                        .Or().ResideInNamespace(Infrastructure)
                        .Or().ResideInNamespace(Api)
                ).Because("R-ARCH-001: Domain saf iş kurallarını barındırır ve dış katmanlara bağımlı olamaz.");

            rule.Check(Architecture);
        }

        // R-ARCH-002: Application yalnızca Domain'e bağımlı
        [Fact]
        public void ApplicationLayerMustDependOnlyOnDomain()
        {
            IArchRule rule = Types().That().ResideInNamespace(Application)
                .Should().NotDependOnAny(
                    Types().That().ResideInNamespace(Infrastructure)
                        .Or().ResideInNamespace(Api)
                ).Because("R-ARCH-002: Application orkestrasyonu altyapı ve sunum somutlamalarını tanıyamaz.");

            rule.Check(Architecture);
        }

        // R-ARCH-003: Domain'de framework tipi yok
        [Fact]
        public void DomainMustNotReferenceFrameworkTypes()
        {
            IArchRule rule = Types().That().ResideInNamespace(Domain)
                .Should().NotDependOnAny(
                    Types().That().ResideInNamespace("Microsoft.EntityFrameworkCore")
                        .Or().ResideInNamespace("Microsoft.AspNetCore")
                        .Or().ResideInNamespace("Microsoft.Extensions.Configuration")
                        .Or().ResideInNamespace("System.Data")
                        .Or().ResideInNamespace("Azure.Messaging")
                ).Because("R-ARCH-003: Framework bağımlılığı Domain'i teknoloji sağlayıcısına kilitler.");

            rule.Check(Architecture);
        }

        // R-ARCH-004: Api katmanı Infrastructure'a doğrudan erişemez
        [Fact]
        public void ApiMustNotDirectlyAccessInfrastructure()
        {
            IArchRule rule = Types().That().ResideInNamespace(Api)
                .Should().NotDependOnAny(
                    Types().That().ResideInNamespace(Infrastructure)
                ).Because("R-ARCH-004: Sunum katmanı yalnızca Application soyutlamalarıyla konuşur.");

            rule.Check(Architecture);
        }

        // R-ARCH-005: Domain tipleri Api imzalarında görünemez (mass-assignment / CWE-915)
        [Fact]
        public void DomainTypesMustNotAppearInApiSignatures()
        {
            IArchRule rule = Types().That().ResideInNamespace(Endpoints)
                .Should().NotDependOnAny(
                    Types().That().ResideInNamespace(Domain)
                ).Because("R-ARCH-005: Endpoint imzaları yalnızca Request/Response DTO kullanabilir; " +
                          "Domain entity'lerinin dışarıya sızması mass-assignment riskidir (CWE-915).");

            rule.Check(Architecture);
        }

        // R-MOD-001: Feature -> Feature bağımlılığı yok (dikey dilim izolasyonu)
        [Theory]
        [MemberData(nameof(FeaturePairs))]
        public void FeaturesMustNotDependOnEachOther(string source, string target)
        {
            IArchRule rule = Types().That().ResideInNamespace($"{Features}.{source}")
                .Should().NotDependOnAny(
                    Types().That().ResideInNamespace($"{Features}.{target}")
                ).Because($"R-MOD-001: '{source}' dikey dilimi '{target}' dilimine doğrudan bağımlı olamaz; " +
                          "iletişim SharedKernel sözleşmeleri veya entegrasyon olayları üzerinden kurulur.");

            rule.Check(Architecture);
        }

        /// <summary>
        /// Dikey dilimler. Hedef projeye uyarlarken <c>.agents/contract.yaml</c> içindeki
        /// <c>features</c> listesiyle aynı tutun.
        /// </summary>
        private static readonly string[] FeatureSlices = { "Orders", "Customers", "Vehicles", "Campaigns" };

        public static TheoryData<string, string> FeaturePairs()
        {
            var data = new TheoryData<string, string>();
            foreach (var source in FeatureSlices)
            {
                foreach (var target in FeatureSlices)
                {
                    if (!string.Equals(source, target, StringComparison.Ordinal))
                    {
                        data.Add(source, target);
                    }
                }
            }

            return data;
        }

        // R-MOD-004: SharedKernel hiçbir feature'a bağımlı olamaz
        [Fact]
        public void SharedKernelMustNotDependOnFeatures()
        {
            IArchRule rule = Types().That().ResideInNamespace(SharedKernel)
                .Should().NotDependOnAny(
                    Types().That().ResideInNamespace(Features)
                ).Because("R-MOD-004: SharedKernel tüm dilimlerin altında yer alır; " +
                          "bir dilime bağımlı olması döngüsel bağımlılık yaratır.");

            rule.Check(Architecture);
        }

        // R-PII-003: PII içeren tipler [SensitiveData] ile işaretli olmalı
        [Fact]
        public void PiiTypesMustHaveSensitiveDataAttribute()
        {
            IArchRule rule = Classes().That().ResideInNamespace(PiiNamespace)
                .Should().HaveAnyAttributes(typeof(Company.Common.SensitiveDataAttribute))
                .Because("R-PII-003: KVKK m.12 gereği kişisel veri taşıyan her tip, " +
                         "maskeleme ve denetim altyapısının tanıyabilmesi için [SensitiveData] taşımalıdır.");

            rule.Check(Architecture);
        }

        // R-AUTH-001: Her endpoint [Authorize] veya açık [AllowAnonymous] taşır
        [Fact]
        public void EndpointAuthorizationRequired()
        {
            IArchRule rule = Classes().That().ResideInNamespace(Endpoints)
                .Should().HaveAnyAttributes(
                    typeof(Company.Api.Attributes.AuthorizeAttribute),
                    typeof(Company.Api.Attributes.AllowAnonymousAttribute))
                .Because("R-AUTH-001: Zero trust gereği her endpoint yetkilendirme kararını açıkça beyan eder; " +
                         "anonim erişim ancak [AllowAnonymous] ile gerekçelendirilerek açılabilir.");

            rule.Check(Architecture);
        }

        // R-AUTH-008: HttpContext / kullanıcı bağlamı Domain'de kullanılamaz
        [Fact]
        public void NoHttpContextUserInDomain()
        {
            IArchRule rule = Types().That().ResideInNamespace(Domain)
                .Should().NotDependOnAny(
                    Types().That().ResideInNamespace("Microsoft.AspNetCore.Http")
                        .Or().ResideInNamespace("System.Security.Claims")
                ).Because("R-AUTH-008: Yetkilendirme kararları Application katmanında verilir; " +
                          "Domain web bağlamını tanıyamaz.");

            rule.Check(Architecture);
        }

        // R-NET-044: Dış sistem DTO'ları Domain'e sızamaz
        [Fact]
        public void ExternalDtosMustNotLeakToDomain()
        {
            IArchRule rule = Types().That().ResideInNamespace(Domain)
                .Should().NotDependOnAny(
                    Types().That().ResideInNamespace(Integration)
                ).Because("R-NET-044: Üçüncü taraf sözleşmeleri anti-corruption layer'da çevrilir; " +
                          "Domain dış sistem DTO'sunu tanıyamaz.");

            rule.Check(Architecture);
        }

        // R-NET-054: Dosya sistemi ve ağ erişimi Domain'de yasak
        [Fact]
        public void DomainMustNotAccessFileSystemOrNetwork()
        {
            IArchRule rule = Types().That().ResideInNamespace(Domain)
                .Should().NotDependOnAny(
                    Types().That().ResideInNamespace("System.IO")
                        .Or().ResideInNamespace("System.Net.Http")
                        .Or().ResideInNamespace("System.Net.Sockets")
                ).Because("R-NET-054: Saf domain kuralı IO ve ağ yan etkilerini yasaklar.");

            rule.Check(Architecture);
        }

        // R-TST-006: Entegrasyon testleri gerçek dış servise gidemez
        [Fact]
        public void IntegrationTestsMustNotCallExternalServices()
        {
            IArchRule rule = Types().That().ResideInNamespace(IntegrationTests)
                .Should().NotDependOnAny(
                    Types().That().ResideInNamespace("System.Net.Http")
                        .Or().ResideInNamespace("System.Net.Sockets")
                ).Because("R-TST-006: Entegrasyon testleri gerçek dış servise çıkamaz; " +
                          "Testcontainers veya sahte sunucu kullanılmalıdır.");

            rule.Check(Architecture);
        }
    }
}
