/**
 * @name Repository interface leaking IQueryable
 * @description Repositories should return materialized collections or specific expressions (Specifications), not IQueryable<T>, to prevent EF Core query leaks outside the persistence layer.
 * @kind problem
 * @problem.severity warning
 * @precision high
 * @id cs/design-patterns/repository-leaking-iqueryable
 * @tags design-patterns
 *       architecture
 *       maintainability
 */

import csharp

from Method m, Interface i
where
  i.getName().matches("%Repository%") and
  m.getDeclaringType() = i and
  m.getReturnType().(ConstructedGenericType).getUnboundGenericType().hasQualifiedName("System.Linq", "IQueryable`1")
select m, "Design Pattern: Repository method $@ leaks IQueryable<T>. Return IReadOnlyList<T> or apply the Specification pattern.", m, m.getName()
