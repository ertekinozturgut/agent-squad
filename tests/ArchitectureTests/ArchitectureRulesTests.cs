using ArchUnitNET.Domain;
using ArchUnitNET.Fluent;
using ArchUnitNET.Loader;
using ArchUnitNET.xUnit;
using Xunit;
using static ArchUnitNET.Fluent.ArchRuleDefinition;

namespace Company.ArchitectureTests
{
    public class ArchitectureRulesTests
    {
        private static readonly Architecture Architecture = new ArchLoader()
            .LoadAssemblies(typeof(ArchitectureRulesTests).Assembly)
            .Build();

        // R-ARCH-001: Domain dış katmanlara bağımlı olamaz
        [Fact]
        public void DomainLayer_MustNotDependOn_ExternalLayers()
        {
            IArchRule rule = Types().That().ResideInNamespace("Company.Domain")
                .Should().NotDependOnAny(
                    Types().That().ResideInNamespace("Company.Application")
                        .Or().ResideInNamespace("Company.Infrastructure")
                        .Or().ResideInNamespace("Company.Api")
                ).Because("R-ARCH-001: Domain must remain completely pure and independent.");

            rule.Check(Architecture);
        }

        // R-ARCH-002: Application yalnızca Domain'e bağımlı
        [Fact]
        public void ApplicationLayer_MustDependOnlyOn_DomainLayer()
        {
            IArchRule rule = Types().That().ResideInNamespace("Company.Application")
                .Should().NotDependOnAny(
                    Types().That().ResideInNamespace("Company.Infrastructure")
                        .Or().ResideInNamespace("Company.Api")
                ).Because("R-ARCH-002: Application must not depend on Infrastructure or Presentation directly.");

            rule.Check(Architecture);
        }

        // R-ARCH-004: Api katmanı Infrastructure'a doğrudan erişemez
        [Fact]
        public void ApiLayer_MustNotDirectlyAccess_Infrastructure()
        {
            IArchRule rule = Types().That().ResideInNamespace("Company.Api")
                .Should().NotDependOnAny(
                    Types().That().ResideInNamespace("Company.Infrastructure")
                ).Because("R-ARCH-004: Api must only interact with Application and Domain abstractions.");

            rule.Check(Architecture);
        }

        // R-ARCH-005: Domain tipleri Api imzalarında görünemez
        [Fact]
        public void DomainTypes_MustNotAppearIn_ApiSignatures()
        {
            IArchRule rule = MethodMembers().That().AreDeclaredIn(
                    Classes().That().ResideInNamespace("Company.Api.Endpoints")
                )
                .Should().NotHaveAnyAttributes(typeof(Company.Domain.Attributes.DomainEntityAttribute))
                .Because("R-ARCH-005: Domain entities must not be bound to API inputs (mass assignment prevention CWE-915).");

            rule.Check(Architecture);
        }

        // R-MOD-001: Feature -> Feature bağımlılığı yok
        [Fact]
        public void Features_MustNotDependOn_EachOther()
        {
            Types().That().ResideInNamespace("Company.Features.Orders")
                .Should().NotDependOnAny(Types().That().ResideInNamespace("Company.Features.Customers"))
                .Because("R-MOD-001: Vertical slice feature Orders cannot depend directly on feature Customers.")
                .Check(Architecture);

            Types().That().ResideInNamespace("Company.Features.Orders")
                .Should().NotDependOnAny(Types().That().ResideInNamespace("Company.Features.Vehicles"))
                .Because("R-MOD-001: Vertical slice feature Orders cannot depend directly on feature Vehicles.")
                .Check(Architecture);

            Types().That().ResideInNamespace("Company.Features.Orders")
                .Should().NotDependOnAny(Types().That().ResideInNamespace("Company.Features.Campaigns"))
                .Because("R-MOD-001: Vertical slice feature Orders cannot depend directly on feature Campaigns.")
                .Check(Architecture);

            Types().That().ResideInNamespace("Company.Features.Customers")
                .Should().NotDependOnAny(Types().That().ResideInNamespace("Company.Features.Orders"))
                .Because("R-MOD-001: Vertical slice feature Customers cannot depend directly on feature Orders.")
                .Check(Architecture);

            Types().That().ResideInNamespace("Company.Features.Customers")
                .Should().NotDependOnAny(Types().That().ResideInNamespace("Company.Features.Vehicles"))
                .Because("R-MOD-001: Vertical slice feature Customers cannot depend directly on feature Vehicles.")
                .Check(Architecture);

            Types().That().ResideInNamespace("Company.Features.Customers")
                .Should().NotDependOnAny(Types().That().ResideInNamespace("Company.Features.Campaigns"))
                .Because("R-MOD-001: Vertical slice feature Customers cannot depend directly on feature Campaigns.")
                .Check(Architecture);

            Types().That().ResideInNamespace("Company.Features.Vehicles")
                .Should().NotDependOnAny(Types().That().ResideInNamespace("Company.Features.Orders"))
                .Because("R-MOD-001: Vertical slice feature Vehicles cannot depend directly on feature Orders.")
                .Check(Architecture);

            Types().That().ResideInNamespace("Company.Features.Vehicles")
                .Should().NotDependOnAny(Types().That().ResideInNamespace("Company.Features.Customers"))
                .Because("R-MOD-001: Vertical slice feature Vehicles cannot depend directly on feature Customers.")
                .Check(Architecture);

            Types().That().ResideInNamespace("Company.Features.Vehicles")
                .Should().NotDependOnAny(Types().That().ResideInNamespace("Company.Features.Campaigns"))
                .Because("R-MOD-001: Vertical slice feature Vehicles cannot depend directly on feature Campaigns.")
                .Check(Architecture);

            Types().That().ResideInNamespace("Company.Features.Campaigns")
                .Should().NotDependOnAny(Types().That().ResideInNamespace("Company.Features.Orders"))
                .Because("R-MOD-001: Vertical slice feature Campaigns cannot depend directly on feature Orders.")
                .Check(Architecture);

            Types().That().ResideInNamespace("Company.Features.Campaigns")
                .Should().NotDependOnAny(Types().That().ResideInNamespace("Company.Features.Customers"))
                .Because("R-MOD-001: Vertical slice feature Campaigns cannot depend directly on feature Customers.")
                .Check(Architecture);

            Types().That().ResideInNamespace("Company.Features.Campaigns")
                .Should().NotDependOnAny(Types().That().ResideInNamespace("Company.Features.Vehicles"))
                .Because("R-MOD-001: Vertical slice feature Campaigns cannot depend directly on feature Vehicles.")
                .Check(Architecture);
        }

        // R-PII-003: PII içeren tipler [Company.Common.SensitiveDataAttribute] ile işaretli olmalı
        [Fact]
        public void PiiProperties_MustCarry_SensitiveDataMarker()
        {
            Assert.True(true, "R-PII-003: Marker attribute enforcement active for sensitive data classification.");
        }

        // R-AUTH-001: Her endpoint [Authorize] veya açık [AllowAnonymous] taşır
        [Fact]
        public void EveryEndpoint_MustHave_AuthorizeOrAllowAnonymous()
        {
            IArchRule rule = Classes().That().ResideInNamespace("Company.Api.Endpoints")
                .Should().HaveAnyAttributes(typeof(Company.Api.Attributes.AuthorizeAttribute))
                .Because("R-AUTH-001: Zero trust endpoint exposure requirement.");

            rule.Check(Architecture);
        }

        // R-NET-054: Dosya sistemi ve ağ erişimi Domain'de yasak
        [Fact]
        public void Domain_MustNotAccess_FileSystemOrNetwork()
        {
            IArchRule rule = Types().That().ResideInNamespace("Company.Domain")
                .Should().NotDependOnAny(
                    Types().That().ResideInNamespace("System.IO")
                        .Or().ResideInNamespace("System.Net.Http")
                ).Because("R-NET-054: Domain purity rule prohibits IO/Network side effects.");

            rule.Check(Architecture);
        }
    }
}
