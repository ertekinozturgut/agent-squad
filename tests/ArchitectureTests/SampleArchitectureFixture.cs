// ==============================================================================
// Mimari kural fixture'ı.
//
// Bu dosya, ArchitectureRulesTests içindeki her kuralın ÜZERİNDE ÇALIŞACAĞI
// referans tip grafiğini kurar: R-TST-007 gereği her S1 kuralın pozitif (uyumlu)
// örneği burada bulunur. Hedef projeye uyarlanırken bu fixture korunur; gerçek
// ürün assembly'leri ArchitectureRulesTests.ProductAssemblies() üzerinden eklenir.
//
// DİKKAT: Fixture yalnızca UYUMLU örnekler içerir. Buraya kasıtlı bir ihlal
// eklenirse ilgili mimari test kırmızıya döner.
// ==============================================================================

namespace Company.Domain.Attributes
{
    [AttributeUsage(AttributeTargets.Class | AttributeTargets.Struct)]
    public sealed class DomainEntityAttribute : Attribute { }
}

namespace Company.Common
{
    /// <summary>KVKK m.12 kapsamındaki kişisel veri taşıyan tipleri işaretler (R-PII-003).</summary>
    [AttributeUsage(AttributeTargets.Property | AttributeTargets.Class)]
    public sealed class SensitiveDataAttribute : Attribute { }
}

namespace Company.SharedKernel
{
    /// <summary>Tüm dikey dilimlerin paylaştığı sözleşme; hiçbir dilime bağımlı olamaz (R-MOD-004).</summary>
    public interface IAuditable
    {
        DateTimeOffset OccurredAt { get; }
    }
}

namespace Company.Domain
{
    [Company.Domain.Attributes.DomainEntity]
    public sealed class SampleDomainEntity
    {
        public SampleDomainEntity(Guid id, string name)
        {
            Id = id;
            Name = name;
        }

        public Guid Id { get; }

        public string Name { get; }
    }
}

namespace Company.Domain.Pii
{
    /// <summary>R-PII-003 pozitif fixture'ı: PII taşıyan tip [SensitiveData] ile işaretlenmiştir.</summary>
    [Company.Common.SensitiveData]
    public sealed class CustomerIdentity
    {
        public CustomerIdentity(string tckn) => Tckn = tckn;

        public string Tckn { get; }
    }
}

namespace Company.Application
{
    public sealed class SampleApplicationService
    {
        public Company.Domain.SampleDomainEntity CreateEntity(Guid id, string name)
            => new Company.Domain.SampleDomainEntity(id, name);
    }
}

namespace Company.Infrastructure
{
    public sealed class SampleInfrastructureRepository
    {
        public void Persist(Company.Domain.SampleDomainEntity entity) => _ = entity;
    }
}

namespace Company.Api.Attributes
{
    [AttributeUsage(AttributeTargets.Class | AttributeTargets.Method)]
    public sealed class AuthorizeAttribute : Attribute { }

    /// <summary>R-AUTH-001: anonim erişim yalnızca açık beyanla ve gerekçeyle açılabilir.</summary>
    [AttributeUsage(AttributeTargets.Class | AttributeTargets.Method)]
    public sealed class AllowAnonymousAttribute : Attribute { }
}

namespace Company.Api
{
    public sealed class ApiMarker
    {
        public string Version { get; } = "1.0";
    }
}

namespace Company.Api.Endpoints
{
    /// <summary>R-ARCH-005 / R-AUTH-001 pozitif fixture'ı: yalnızca Application'a bağımlı, yetkilendirilmiş endpoint.</summary>
    [Company.Api.Attributes.Authorize]
    public sealed class SampleOrdersEndpoint
    {
        private readonly Company.Application.SampleApplicationService _service = new();

        public string GetOrderStatus(string orderId)
        {
            _ = orderId;
            _ = _service;
            return "Active";
        }
    }

    /// <summary>R-AUTH-001 pozitif fixture'ı: gerekçeli anonim endpoint (sağlık probu).</summary>
    [Company.Api.Attributes.AllowAnonymous]
    public sealed class SampleHealthEndpoint
    {
        public string Live() => "ok";
    }
}

namespace Company.Features.Orders
{
    public sealed class OrderSlice
    {
        public string Code { get; } = "ORD-1";
    }
}

namespace Company.Features.Customers
{
    public sealed class CustomerSlice
    {
        public string Code { get; } = "CUST-1";
    }
}

namespace Company.Features.Vehicles
{
    public sealed class VehicleSlice
    {
        public string Code { get; } = "VEH-1";
    }
}

namespace Company.Features.Campaigns
{
    public sealed class CampaignSlice
    {
        public string Code { get; } = "CMP-1";
    }
}
