/**
 * @name Generic System.Exception thrown (Sonar S112)
 * @description Throwing 'new Exception()' or 'new SystemException()' prevents callers from handling specific error scenarios.
 * @kind problem
 * @problem.severity warning
 * @precision high
 * @id cs/sonarqube/generic-exception-thrown
 * @tags maintainability
 *       sonar-s112
 */

import csharp

from ThrowStmt ts, ObjectCreation oc
where
  ts.getExpr() = oc and
  (
    oc.getType().hasQualifiedName("System", "Exception") or
    oc.getType().hasQualifiedName("System", "SystemException")
  )
select ts, "SonarQube S112: Generic System.Exception thrown. Throw a specific custom domain exception or return a Result failure."
