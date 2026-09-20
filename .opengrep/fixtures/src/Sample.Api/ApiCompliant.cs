// FIXTURE: Uyumlu üretim kodu. Bu dosya SIFIR bulgu vermelidir (yanlış pozitif kontrolü).
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Text.RegularExpressions;
using System.Threading;
using System.Threading.Tasks;

namespace Sample.Api;

public sealed class ApiCompliant
{
    private static readonly SemaphoreSlim Gate = new(1);
    private static readonly Regex Safe = new("a+", RegexOptions.None, TimeSpan.FromMilliseconds(200));

    public DateTimeOffset CreatedAt { get; init; }

    public const string Endpoint = "https://payments.internal/api";

    public async Task<int> LoadAsync(int id, CancellationToken cancellationToken = default)
    {
        await Task.Delay(1, cancellationToken).ConfigureAwait(false);
        return id;
    }

    public async Task WithSemaphoreAsync(CancellationToken cancellationToken)
    {
        await Gate.WaitAsync(cancellationToken).ConfigureAwait(false);
        try
        {
            await Task.Delay(1, cancellationToken).ConfigureAwait(false);
        }
        finally
        {
            Gate.Release();
        }
    }

    public void HandleSpecific(ILoggerLike logger)
    {
        try
        {
            Work();
        }
        catch (InvalidOperationException ex)
        {
            logger.LogError(ex, "İşlem geçersiz durumda sonlandı: {Endpoint}", Endpoint);
            throw;
        }
    }

    public Task<List<Order>> PagedAsync(DbLike db, int skip, int take, CancellationToken cancellationToken) =>
        db.Orders.AsNoTracking().Skip(skip).Take(take).ToListAsync(cancellationToken);

    public byte[] HashPassword(string password, byte[] salt) =>
        Rfc2898DeriveBytes.Pbkdf2(password, salt, 210_000, HashAlgorithmName.SHA512, 32);

    public string ReadSetting(OptionsLike<PaymentOptions> options) => options.Value.ApiKey;

    public Regex Matcher() => Safe;

    private static void Work()
    {
    }
}

public sealed class PaymentOptions
{
    public string ApiKey { get; init; } = string.Empty;
}
