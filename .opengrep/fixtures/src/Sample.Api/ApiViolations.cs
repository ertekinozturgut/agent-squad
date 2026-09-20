// FIXTURE: Üretim kodu ihlalleri. Her blok en az bir opengrep kuralını tetiklemelidir.
// Bu dosya .agents/verify.sh tarafından taranır; ürün kodu değildir.
using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Diagnostics.Metrics;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Security.Cryptography;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading;
using System.Threading.Channels;
using System.Threading.Tasks;

namespace Sample.Api;

public class ApiViolations
{
    private static readonly SemaphoreSlim Gate = new(1);
    private readonly object _sync = new();

    // opengrep-key-material-not-string
    private string signingKeySecret = "s3cret-signing-key-value";

    // opengrep-prefer-datetimeoffset
    public DateTime CreatedAt { get; set; }

    // opengrep-threadstatic-asynclocal-audit
    [ThreadStatic]
    private static int _threadLocalCounter;

    // opengrep-no-notimplemented-exception
    public void NotDone() => throw new NotImplementedException();

    // opengrep-cancellation-token-propagation (imzada CancellationToken yok)
    public async Task LoadAsync(int id)
    {
        await Task.Delay(1);
    }

    // opengrep-no-await-in-lock
    public void BlockingInsideLock()
    {
        lock (_sync)
        {
            var value = Task.FromResult(1).Result;
            GC.KeepAlive(value);
        }
    }

    // opengrep-semaphore-released-in-finally (finally dışında Release)
    public void ReleaseOutsideFinally()
    {
        Gate.Wait();
        Gate.Release();
    }

    // opengrep-parallel-no-async-lambda
    public void ParallelAsyncLambda()
    {
        Parallel.ForEach(new[] { 1, 2 }, async (x) => { await Task.Delay(x); });
    }

    // opengrep-bounded-collections
    public Channel<int> Unbounded() => Channel.CreateUnbounded<int>();

    // opengrep-meaningful-exception-logging + opengrep-log-level-convention
    public void LogExceptionAtInformation(ILoggerLike logger)
    {
        try
        {
            Work();
        }
        catch (InvalidOperationException ex)
        {
            logger.LogInformation(ex, "failed");
        }
    }

    // opengrep-no-throw-ex-rethrow
    public void RethrowResetsStack()
    {
        try
        {
            Work();
        }
        catch (InvalidOperationException ex)
        {
            throw ex;
        }
    }

    // opengrep-no-throw-raw-exception
    public void ThrowRaw() => throw new Exception("boom");

    // opengrep-do-not-swallow-operationcanceled
    public void SwallowCancel()
    {
        try
        {
            Work();
        }
        catch (OperationCanceledException) { }
    }

    // opengrep-do-not-catch-fatal-exceptions
    public void CatchFatal()
    {
        try
        {
            Work();
        }
        catch (OutOfMemoryException ex)
        {
            GC.KeepAlive(ex);
        }
    }

    // opengrep-no-exception-leak-to-client
    public object LeakStackTrace(Exception ex) => Problem(ex.StackTrace);

    // opengrep-no-empty-catch
    public void EmptyCatch()
    {
        try
        {
            Work();
        }
        catch (InvalidOperationException) { }
    }

    // opengrep-catch-specific-exception-types
    public void CatchAll(ILoggerLike logger)
    {
        try
        {
            Work();
        }
        catch (Exception ex)
        {
            logger.LogError(ex, "swallowed");
        }
    }

    // opengrep-exception-filters-no-side-effects
    public void FilterWithSideEffect(ILoggerLike logger)
    {
        try
        {
            Work();
        }
        catch (Exception ex) when (logger.LogWarning(ex, "filtering"))
        {
            throw;
        }
    }

    // opengrep-structured-logging-no-interpolation
    public void InterpolatedLog(ILoggerLike logger, int orderId)
    {
        logger.LogError($"order {orderId} failed");
    }

    // opengrep-pii-in-cache-key
    public void CachePii(ICacheLike cache, string tckn) => cache.Set("user:tckn:" + tckn, 1);

    // opengrep-pii-in-url-query
    public string ReadPiiFromQuery(HttpRequestLike Request) => Request.Query["email"];

    // opengrep-tostring-no-pii
    public override string ToString() => "customer " + Tckn;

    public string Tckn { get; set; } = string.Empty;

    // opengrep-jwt-validation-parameters + opengrep-jwt-require-https-metadata
    public TokenParamsLike TokenParams() => new()
    {
        ValidateIssuer = false,
        RequireHttpsMetadata = false,
    };

    // opengrep-xml-reader-dtd-disabled
    public XmlSettingsLike XmlSettings() => new() { DtdProcessing = DtdProcessing.Parse };

    // opengrep-typenamehandling-prohibited
    public JsonSettingsLike JsonSettings() => new() { TypeNameHandling = TypeNameHandling.All };

    // opengrep-regex-injection-and-redos (timeout yok)
    public Regex NoTimeout(string pattern) => new Regex(pattern);

    // opengrep-deserialization-depth-limit
    public JsonSettingsLike NoDepthLimit() => new() { MaxDepth = null };

    // opengrep-secure-password-hashing
    public byte[] HashPassword(string password) => SHA256.HashData(Encoding.UTF8.GetBytes(password));

    // opengrep-no-certificate-validation-bypass
    public HttpClientHandler InsecureHandler() => new()
    {
        ServerCertificateCustomValidationCallback = (a, b, c, d) => true,
    };

    // opengrep-tls-min-version
    public void LegacyTls() => ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls11;

    // opengrep-no-static-iv
    public void StaticIv(Aes aes) => aes.IV = new byte[] { 1, 2, 3, 4, 5, 6, 7, 8 };

    // opengrep-no-http-plain-url
    public const string LegacyEndpoint = "http://payments.internal/api";

    // opengrep-readonly-query-asnotracking + opengrep-no-unpaged-tolist
    public Task<List<Order>> AllOrders(DbLike db) => db.Orders.ToListAsync();

    public Task<List<Order>> TrackedOrders(DbLike db) => db.Orders.Where(o => o.Id > 0).ToListAsync();

    // opengrep-prefer-select-projection-over-include
    public IQueryable<Order> DeepInclude(DbLike db) =>
        db.Orders.Include(o => o.Lines).Include(o => o.Customer).Include(o => o.Invoice);

    // opengrep-no-lazy-loading
    public void LazyLoading(OptionsLike options) => options.UseLazyLoadingProxies();

    // opengrep-no-singleton-dbcontext
    public void RegisterContext(ServicesLike services) => services.AddSingleton<AppDbContext>();

    // opengrep-entity-type-configuration-classes
    protected override void OnModelCreating(ModelBuilderLike modelBuilder)
    {
        modelBuilder.Entity<Order>().ToTable("Orders");
    }

    // opengrep-no-sync-savechanges
    public async Task SaveSync(DbLike db)
    {
        await Task.Delay(1);
        db.SaveChanges();
    }

    // opengrep-prefer-batch-operations
    public void AddInLoop(List<Order> target, IEnumerable<Order> source)
    {
        foreach (var item in source)
        {
            target.Add(item);
        }
    }

    // opengrep-no-new-httpclient + opengrep-httpclient-timeout-configured
    public HttpClient RawClient()
    {
        var client = new HttpClient();
        client.Timeout = Timeout.InfiniteTimeSpan;
        return client;
    }

    // opengrep-backoff-with-jitter (jitter'sız retry)
    public void NoJitter(PolicyLike policy) => policy.RetryAsync(3);

    // opengrep-metric-names-convention
    public Counter<long> BadMetric(Meter meter) => meter.CreateCounter<long>("Orders");

    // opengrep-no-high-cardinality-metric-tags
    public KeyValuePair<string, object> HighCardinalityTag(int userId) =>
        new KeyValuePair<string, object>("user_id", userId);

    // opengrep-strongly-typed-options
    public string ReadConfig(ConfigLike Configuration) => Configuration["Payments:ApiKey"];

    // opengrep-no-developerexceptionpage-in-prod
    public void DevPage(AppLike app) => app.UseDeveloperExceptionPage();

    // opengrep-cors-no-wildcard-with-credentials
    public void BadCors(CorsLike builder) => builder.AllowAnyOrigin().AllowCredentials();

    // opengrep-no-detailed-errors-in-prod
    public void DetailedErrors(OptionsLike options) => options.EnableSensitiveDataLogging();

    // opengrep-no-debug-directives-in-business-logic
    public decimal Discount(decimal total)
    {
#if DEBUG
        return total;
#else
        return total * 0.9m;
#endif
    }

    // opengrep-env-var-names-from-constants
    public string ReadEnv() => Environment.GetEnvironmentVariable("PAYMENTS_API_KEY");

    // opengrep-allow-anonymous-comment-justification
    [AllowAnonymous]
    public void PublicEndpoint() => Work();

    // opengrep-roles-from-constants
    [Authorize(Roles = "Admin")]
    public void AdminEndpoint() => Work();

    private static void Work() { }

    private static object Problem(string detail) => detail;
}
