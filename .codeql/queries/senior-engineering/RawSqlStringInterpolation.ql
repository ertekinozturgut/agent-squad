/**
 * @name SQL command with string concatenation/interpolation (R-INJ-001 / Senior Security)
 * @description Building SQL statements dynamically with string concatenation or interpolation invites SQL Injection (CWE-89).
 * @kind problem
 * @problem.severity error
 * @precision high
 * @id cs/senior-engineering/raw-sql-interpolation
 * @tags security
 *       sql-injection
 *       cwe-89
 *       r-inj-001
 */

import csharp

from MethodCall mc, AddExpr ae
where
  (
    mc.getTarget().getName() = "FromSqlRaw" or
    mc.getTarget().getName() = "ExecuteSqlRaw" or
    mc.getTarget().getName() = "ExecuteSqlRawAsync" or
    mc.getTarget().getName() = "Query" or
    mc.getTarget().getName() = "Execute"
  ) and
  ae = mc.getAnArgument()
select mc, "Senior Security (R-INJ-001 / CWE-89): Dynamic SQL constructed using string concatenation. Use parameterized queries or 'FromSqlInterpolated'."
