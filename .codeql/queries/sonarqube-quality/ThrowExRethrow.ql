/**
 * @name Re-throwing exception with 'throw ex;' (Sonar S1144 / CA2200)
 * @description Using 'throw ex;' resets the original exception stack trace, making root-cause diagnostics significantly harder.
 * @kind problem
 * @problem.severity error
 * @precision high
 * @id cs/sonarqube/throw-ex-rethrow
 * @tags maintainability
 *       reliability
 *       sonar-s1144
 *       ca2200
 */

import csharp

from ThrowStmt ts, SpecificCatchClause scc
where
  ts.getExpr() = scc.getExceptionVariable().getAnAccess() and
  ts.getEnclosingStmt*() = scc.getBlock()
select ts, "SonarQube S1144 / CA2200: 'throw ex;' resets the call stack. Use bare 'throw;' to preserve diagnostic trace."
