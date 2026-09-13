/**
 * @name Synchronous blocking on Task (R-NET-001 / Senior Concurrency)
 * @description Using .Result, .Wait(), or .GetAwaiter().GetResult() synchronously blocks worker threads and leads to thread pool starvation and deadlocks.
 * @kind problem
 * @problem.severity error
 * @precision high
 * @id cs/senior-engineering/sync-blocking-task
 * @tags concurrency
 *       performance
 *       r-net-001
 */

import csharp

from Expr e
where
  (
    e.(PropertyAccess).getTarget().getName() = "Result" and
    e.(PropertyAccess).getQualifier().getType().getABaseType*().hasQualifiedName("System.Threading.Tasks", "Task")
  ) or
  (
    e.(MethodCall).getTarget().getName() = "Wait" and
    e.(MethodCall).getTarget().getDeclaringType().hasQualifiedName("System.Threading.Tasks", "Task")
  ) or
  (
    e.(MethodCall).getTarget().getName() = "GetResult" and
    e.(MethodCall).getQualifier().(MethodCall).getTarget().getName() = "GetAwaiter"
  )
select e, "Senior Concurrency (R-NET-001): Synchronous blocking on async Task. Await the task instead to prevent thread pool starvation."
