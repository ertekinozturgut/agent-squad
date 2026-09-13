/**
 * @name Empty catch block (Sonar S2486)
 * @description Catching an exception without logging, handling, or rethrowing suppresses defects and hides system failures.
 * @kind problem
 * @problem.severity error
 * @precision high
 * @id cs/sonarqube/empty-catch-block
 * @tags maintainability
 *       reliability
 *       sonar-s2486
 */

import csharp

from CatchClause cc
where
  cc.getBlock().isEmpty()
select cc, "SonarQube S2486 / UDAP: Empty catch block hides errors. Log the exception or handle it explicitly."
