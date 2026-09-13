/**
 * @name Catching general Exception without rethrowing (Sonar S2221)
 * @description Catching System.Exception swallows unintended errors (such as NullReferenceException) unless it is properly logged and re-thrown.
 * @kind problem
 * @problem.severity warning
 * @precision medium
 * @id cs/sonarqube/broad-catch-swallowing
 * @tags reliability
 *       sonar-s2221
 */

import csharp

from SpecificCatchClause scc
where
  scc.getCaughtType().hasQualifiedName("System", "Exception") and
  not exists(ThrowStmt ts | ts.getEnclosingStmt*() = scc.getBlock() and not exists(ts.getExpr())) and
  not scc.getEnclosingCallable().getName().matches("%Middleware%") and
  not scc.getEnclosingCallable().getName().matches("%Handler%")
select scc, "SonarQube S2221: Broad 'catch (Exception)' without re-throw. Catch only expected specific exception types."
