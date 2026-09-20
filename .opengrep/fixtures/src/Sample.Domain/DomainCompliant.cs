// FIXTURE: Uyumlu domain kodu - sıfır bulgu vermelidir.
using System;

namespace Sample.Domain;

public sealed class Customer
{
    public Customer(Guid id) => Id = id;

    public Guid Id { get; }
}
