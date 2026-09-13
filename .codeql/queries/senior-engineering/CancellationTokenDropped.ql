/**
 * @name CancellationToken not forwarded to async downstream call (R-NET-004)
 * @description Dropping CancellationToken prevents cooperative cancellation, allowing zombie tasks to continue running and wasting compute.
 * @kind problem
 * @problem.severity warning
 * @precision medium
 * @id cs/senior-engineering/cancellation-token-dropped
 * @tags performance
 *       reliability
 *       r-net-004
 */

import csharp

from Method m, Parameter ct, MethodCall mc
where
  ct.getCallable() = m and
  ct.getType().hasQualifiedName("System.Threading", "CancellationToken") and
  mc.getEnclosingCallable() = m and
  mc.getTarget().getAParameter().getType().hasQualifiedName("System.Threading", "CancellationToken") and
  not mc.getAnArgument().(ParameterAccess).getTarget() = ct
select mc, "Senior Concurrency (R-NET-004): Async call $@ does not forward the ambient CancellationToken $@.", mc, mc.getTarget().getName(), ct, ct.getName()
