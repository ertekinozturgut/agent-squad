/**
 * @name Read-only query missing AsNoTracking() (R-NET-010 / Senior EF Core)
 * @description Querying data for read-only purposes without AsNoTracking() causes EF Core to allocate change trackers and degrades performance.
 * @kind problem
 * @problem.severity warning
 * @precision medium
 * @id cs/senior-engineering/efcore-missing-asnotracking
 * @tags performance
 *       efcore
 *       r-net-010
 */

import csharp

from MethodCall mc, Method m
where
  m = mc.getEnclosingCallable() and
  (m.getName().matches("Get%") or m.getName().matches("Find%") or m.getName().matches("List%")) and
  (mc.getTarget().getName() = "ToListAsync" or mc.getTarget().getName() = "ToList") and
  not exists(MethodCall ant |
    ant.getEnclosingCallable() = m and
    ant.getTarget().getName() = "AsNoTracking"
  )
select mc, "Senior EF Core (R-NET-010): Read query in $@ does not use '.AsNoTracking()'. Disable change tracking to reduce memory allocations.", m, m.getName()
