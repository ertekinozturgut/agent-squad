/**
 * @name Lock on 'this' or Type object (CA2002 / Senior Synchronization)
 * @description Locking on publicly accessible objects such as 'this', 'typeof(...)', or string literals exposes the lock to external deadlocks.
 * @kind problem
 * @problem.severity error
 * @precision high
 * @id cs/senior-engineering/lock-on-this-or-type
 * @tags concurrency
 *       correctness
 *       ca2002
 */

import csharp

from LockStmt ls, Expr e
where
  e = ls.getExpr() and
  (
    e instanceof ThisAccess or
    e instanceof TypeOfExpr or
    e.getType().hasQualifiedName("System", "String")
  )
select ls, "Senior Synchronization (CA2002): Locking on 'this', 'typeof(...)', or string literal. Lock on a private dedicated 'readonly object' instead."
