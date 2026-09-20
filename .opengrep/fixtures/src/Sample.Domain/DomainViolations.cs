// FIXTURE: Domain katmanı ihlalleri. Her satır bir kuralı tetiklemelidir.
using System;
using Microsoft.EntityFrameworkCore;          // banned-import-domain-microsoft-entityframeworkcore
using Microsoft.AspNetCore.Mvc;               // banned-import-domain-microsoft-aspnetcore
using System.Data.Common;                     // banned-import-domain-system-data
using System.IO;                              // banned-import-domain-system-io
using System.Net.Http;                        // banned-import-domain-system-net-http
using Azure.Messaging.ServiceBus;             // banned-import-domain-azure-messaging

namespace Sample.Domain;

public sealed class Order
{
    public Guid Id { get; } = Guid.NewGuid();  // opengrep-no-guid-newguid-in-domain
}

public sealed class DomainEnvironmentAccess
{
    // opengrep-no-environment-access-in-domain
    public string Region() => Environment.GetEnvironmentVariable("REGION");
}
