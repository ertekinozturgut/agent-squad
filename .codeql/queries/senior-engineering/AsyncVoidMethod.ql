/**
 * @name Async void method (R-NET-002 / Senior Async Discipline)
 * @description 'async void' methods cannot be awaited and unhandled exceptions crash the entire application process.
 * @kind problem
 * @problem.severity error
 * @precision high
 * @id cs/senior-engineering/async-void-method
 * @tags concurrency
 *       reliability
 *       r-net-002
 */

import csharp

from Method m
where
  m.isAsync() and
  m.getReturnType() instanceof VoidType and
  not m.getAnAttribute().getType().getName().matches("%EventHandler%") and
  not m.getName().matches("%_Click") and
  not m.getName().matches("On%")
select m, "Senior Async Discipline (R-NET-002): 'async void' method $@ cannot be awaited. Change return type to 'Task'."
