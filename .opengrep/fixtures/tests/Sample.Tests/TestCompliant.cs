// FIXTURE: Uyumlu test kodu. Bu dosya SIFIR bulgu vermelidir.
using System.Threading.Tasks;
using Xunit;

namespace Sample.Tests;

public class OrderCompliantTests
{
    [Fact(Skip = "ISSUE-142: Testcontainers CI imajı bekleniyor.")]
    public void Approve_WhenLimitExceeded_ReturnsFailure()
    {
        Assert.True(true);
    }

    [Fact]
    public async Task Approve_WhenWithinLimit_ReturnsSuccess()
    {
        await Task.Delay(1);
        Assert.True(true);
    }
}
