/**
 * @name Infinite loop with constant condition (Sonar S2189)
 * @description Loops that cannot terminate will hang the thread and consume CPU indefinitely.
 * @kind problem
 * @problem.severity error
 * @precision high
 * @id cs/sonarqube/infinite-loop-constant-condition
 * @tags reliability
 *       sonar-s2189
 */

import csharp

from WhileStmt ws
where
  ws.getCondition().getValue() = "true" and
  not exists(BreakStmt bs | bs.getEnclosingStmt*() = ws.getBody()) and
  not exists(ReturnStmt rs | rs.getEnclosingStmt*() = ws.getBody()) and
  not exists(ThrowStmt ts | ts.getEnclosingStmt*() = ws.getBody())
select ws, "SonarQube S2189: Loop condition is constant true and body contains no break, return, or throw statement."
