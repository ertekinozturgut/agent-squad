/**
 * @name Redundant null check after 'is' pattern (Sonar S2583)
 * @description Performing a null check on an expression that has already been verified by pattern matching or is known non-null is redundant.
 * @kind problem
 * @problem.severity warning
 * @precision medium
 * @id cs/sonarqube/redundant-null-check
 * @tags maintainability
 *       sonar-s2583
 */

import csharp

from LogicalAndExpr lae, TypeAccessExpr tae, ComparisonOperation co
where
  lae.getAnOperand() = tae and
  lae.getAnOperand() = co and
  co.getAnOperand() instanceof NullLiteral
select co, "SonarQube S2583: Redundant null check in boolean condition."
