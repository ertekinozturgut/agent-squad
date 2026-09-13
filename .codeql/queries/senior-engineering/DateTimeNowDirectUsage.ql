/**
 * @name Direct usage of DateTime.Now or UtcNow (R-NET-050 / Senior Determinism)
 * @description Direct calls to DateTime.Now or DateTime.UtcNow couple code to the system clock and break testability. Inject TimeProvider instead.
 * @kind problem
 * @problem.severity error
 * @precision high
 * @id cs/senior-engineering/datetime-now-direct-usage
 * @tags testability
 *       maintainability
 *       r-net-050
 */

import csharp

from PropertyAccess pa
where
  (
    pa.getTarget().hasQualifiedName("System", "DateTime", "Now") or
    pa.getTarget().hasQualifiedName("System", "DateTime", "UtcNow") or
    pa.getTarget().hasQualifiedName("System", "DateTimeOffset", "Now") or
    pa.getTarget().hasQualifiedName("System", "DateTimeOffset", "UtcNow")
  ) and
  not pa.getEnclosingCallable().getDeclaringType().getName().matches("%Test%")
select pa, "Senior Determinism (R-NET-050): Direct system clock access ($@). Inject 'TimeProvider' for testability and deterministic time control.", pa.getTarget(), pa.getTarget().getName()
