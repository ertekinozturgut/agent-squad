/**
 * @name Excessive conditional branching candidate for Strategy Pattern
 * @description Methods with large switch statements based on type or enum codes indicate a missing Strategy or State pattern.
 * @kind problem
 * @problem.severity warning
 * @precision medium
 * @id cs/design-patterns/complex-switch-candidate-for-strategy
 * @tags design-patterns
 *       maintainability
 *       refactoring
 */

import csharp

from SwitchStmt ss, Method m
where
  ss.getEnclosingCallable() = m and
  count(SwitchCase sc | sc = ss.getACase()) >= 6
select ss, "Design Pattern Smell: Switch statement with " + count(SwitchCase sc | sc = ss.getACase()).toString() + " cases in method $@. Consider refactoring to the Strategy or Factory pattern.", m, m.getName()
