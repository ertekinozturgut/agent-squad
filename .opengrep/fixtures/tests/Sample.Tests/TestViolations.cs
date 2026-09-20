// FIXTURE: Test disiplini ihlalleri.
using System;
using System.Threading;
using System.Threading.Tasks;
using Xunit;

namespace Sample.Tests;

public class OrderTests
{
    // opengrep-tests-order-independent
    private static int _sharedCounter = 0;

    // opengrep-test-must-contain-assertion + opengrep-test-naming-convention
    [Fact]
    public void Test1()
    {
        var result = 1 + 1;
        GC.KeepAlive(result);
    }

    // opengrep-fact-skip-must-have-reason
    [Fact(Skip = "")]
    public void Skipped_WithoutReason_IsRejected()
    {
        Assert.True(true);
    }

    // opengrep-no-thread-sleep-in-tests
    [Fact]
    public void Sleep_InTest_IsRejected()
    {
        Thread.Sleep(100);
        Assert.True(true);
    }

    // opengrep-no-real-pii-in-tests
    [Fact]
    public void RealTckn_InFixture_IsRejected()
    {
        var tckn = "12345678901";
        Assert.NotNull(tckn);
    }

    // opengrep-no-inmemory-db-in-integration-tests
    [Fact]
    public void InMemoryDb_IsRejected()
    {
        var options = new DbContextOptionsBuilder();
        options.UseInMemoryDatabase("test");
        Assert.NotNull(options);
    }
}
