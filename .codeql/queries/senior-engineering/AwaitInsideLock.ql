/**
 * @name Await expression inside lock block (R-NET-006 / Senior Concurrency)
 * @description The C# monitor lock cannot be held across asynchronous context switches. Use SemaphoreSlim.WaitAsync instead.
 * @kind problem
 * @problem.severity error
 * @precision high
 * @id cs/senior-engineering/await-inside-lock
 * @tags concurrency
 *       correctness
 *       r-net-006
 */

import csharp

from AwaitExpr ae, LockStmt ls
where
  ae.getEnclosingStmt*() = ls.getBlock()
select ae, "Senior Concurrency (R-NET-006): 'await' expression inside 'lock'. Use 'SemaphoreSlim.WaitAsync' instead."
