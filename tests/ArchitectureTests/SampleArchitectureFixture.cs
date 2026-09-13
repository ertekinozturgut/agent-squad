namespace Company.Domain.Attributes
{
    [AttributeUsage(AttributeTargets.Class | AttributeTargets.Struct)]
    public class DomainEntityAttribute : Attribute { }
}

namespace Company.Common
{
    [AttributeUsage(AttributeTargets.Property | AttributeTargets.Class)]
    public class SensitiveDataAttribute : Attribute { }
}

namespace Company.Domain
{
    [Company.Domain.Attributes.DomainEntity]
    public class SampleDomainEntity
    {
        public Guid Id { get; init; } = Guid.NewGuid();
        public string Name { get; private set; } = string.Empty;
    }
}

namespace Company.Application
{
    public class SampleApplicationService
    {
        public Company.Domain.SampleDomainEntity CreateEntity(string name)
        {
            _ = name;
            return new Company.Domain.SampleDomainEntity();
        }
    }
}

namespace Company.Infrastructure
{
    public class SampleInfrastructureRepository
    {
        public void Persist(Company.Domain.SampleDomainEntity entity)
        {
            _ = entity;
        }
    }
}

namespace Company.Api.Attributes
{
    [AttributeUsage(AttributeTargets.Class | AttributeTargets.Method)]
    public class AuthorizeAttribute : Attribute { }
}

namespace Company.Api
{
    public class ApiMarker
    {
        public string Version { get; set; } = "1.0";
    }
}

namespace Company.Api.Endpoints
{
    [Company.Api.Attributes.Authorize]
    public class SampleOrdersEndpoint
    {
        private readonly Company.Application.SampleApplicationService _service = new();

        public string GetOrderStatus(string orderId)
        {
            _ = orderId;
            _ = _service;
            return "Active";
        }
    }
}

namespace Company.Features.Orders
{
    public class OrderSlice
    {
        public string Code { get; set; } = "ORD-1";
    }
}

namespace Company.Features.Customers
{
    public class CustomerSlice
    {
        public string Code { get; set; } = "CUST-1";
    }
}

namespace Company.Features.Vehicles
{
    public class VehicleSlice
    {
        public string Code { get; set; } = "VEH-1";
    }
}

namespace Company.Features.Campaigns
{
    public class CampaignSlice
    {
        public string Code { get; set; } = "CMP-1";
    }
}
