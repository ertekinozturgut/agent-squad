/**
 * @name Broken double-checked locking in Singleton
 * @description Singletons using double-checked locking without a 'volatile' backing field suffer from memory reordering issues in multi-threaded environments.
 * @kind problem
 * @problem.severity error
 * @precision high
 * @id cs/design-patterns/singleton-broken-double-check
 * @tags design-patterns
 *       concurrency
 *       maintainability
 */

import csharp

from Field f, Property p, IfStmt is1, LockStmt ls, IfStmt is2
where
  p.getAnAccess() = f.getAnAccess() and
  is1.getEnclosingCallable() = p.getGetter() and
  ls.getEnclosingStmt() = is1.getThen() and
  is2.getEnclosingStmt() = ls.getBlock() and
  not f.isVolatile() and
  not f.isStatic()
select f, "Design Pattern: Singleton field $@ is used in double-checked locking without being marked as 'volatile'. Use Lazy<T> instead.", f, f.getName()
