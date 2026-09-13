/**
 * @name Nested ternary operator (Sonar S3358)
 * @description Nested conditional operators (? :) drastically reduce readability and increase cognitive complexity.
 * @kind problem
 * @problem.severity warning
 * @precision high
 * @id cs/sonarqube/nested-ternary-operator
 * @tags maintainability
 *       sonar-s3358
 */

import csharp

from ConditionalExpr outer, ConditionalExpr inner
where
  inner = outer.getThen() or inner = outer.getElse()
select outer, "SonarQube S3358: Nested ternary operator. Refactor into explicit if-else or switch expressions to reduce cognitive complexity."
