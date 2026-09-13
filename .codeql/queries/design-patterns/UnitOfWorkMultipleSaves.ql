/**
 * @name Multiple SaveChanges calls in single method (Unit of Work violation)
 * @description Calling SaveChangesAsync multiple times in a single method creates fragmented transactions and violates the atomic Unit of Work pattern.
 * @kind problem
 * @problem.severity warning
 * @precision high
 * @id cs/design-patterns/unit-of-work-multiple-saves
 * @tags design-patterns
 *       data-integrity
 *       maintainability
 */

import csharp

from Method m
where
  count(MethodCall mc |
    mc.getEnclosingCallable() = m and
    mc.getTarget().getName().matches("%SaveChanges%")
  ) > 1
select m, "Design Pattern: Method $@ contains multiple SaveChanges calls. Consolidate operations into a single atomic Unit of Work transaction.", m, m.getName()
