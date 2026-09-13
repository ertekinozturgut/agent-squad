/**
 * @name Critical fatal exception caught (Sonar S2142 / S1166)
 * @description Critical exceptions such as OutOfMemoryException or StackOverflowException indicate unrecoverable system failures and should not be caught.
 * @kind problem
 * @problem.severity error
 * @precision high
 * @id cs/sonarqube/fatal-exception-caught
 * @tags reliability
 *       sonar-s2142
 */

import csharp

from SpecificCatchClause scc
where
  scc.getCaughtType().hasQualifiedName("System", "OutOfMemoryException") or
  scc.getCaughtType().hasQualifiedName("System", "StackOverflowException") or
  scc.getCaughtType().hasQualifiedName("System", "ExecutionEngineException")
select scc, "SonarQube S2142: Catching unrecoverable fatal exception $@. Allow this exception to terminate the process cleanly.", scc.getCaughtType(), scc.getCaughtType().getName()
