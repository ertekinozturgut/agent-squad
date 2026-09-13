/**
 * @name Thread.Sleep used in asynchronous context (R-TST-003 / Concurrency Anti-Pattern)
 * @description Calling Thread.Sleep blocks the underlying thread-pool worker thread. Use 'await Task.Delay()' in asynchronous workflows.
 * @kind problem
 * @problem.severity error
 * @precision high
 * @id cs/senior-engineering/thread-sleep-in-async
 * @tags concurrency
 *       performance
 *       r-tst-003
 */

import csharp

from MethodCall mc, Method m
where
  mc.getTarget().hasQualifiedName("System.Threading", "Thread", "Sleep") and
  m = mc.getEnclosingCallable() and
  m.isAsync()
select mc, "Senior Concurrency: 'Thread.Sleep()' blocks OS worker thread in async method $@. Replace with 'await Task.Delay(...)'.", m, m.getName()
