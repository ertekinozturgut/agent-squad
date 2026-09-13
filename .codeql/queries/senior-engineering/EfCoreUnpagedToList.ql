/**
 * @name Unpaged collection queried into memory (R-NET-017 / Senior EF Core)
 * @description Calling ToListAsync() or ToList() directly on a database set without Skip() or Take() risks querying millions of rows and causing OutOfMemory.
 * @kind problem
 * @problem.severity error
 * @precision medium
 * @id cs/senior-engineering/efcore-unpaged-tolist
 * @tags performance
 *       reliability
 *       r-net-017
 */

import csharp

from MethodCall toListCall, Method m
where
  m = toListCall.getEnclosingCallable() and
  (toListCall.getTarget().getName() = "ToListAsync" or toListCall.getTarget().getName() = "ToList") and
  not exists(MethodCall pageCall |
    pageCall.getEnclosingCallable() = m and
    (pageCall.getTarget().getName() = "Take" or pageCall.getTarget().getName() = "FirstOrDefault" or pageCall.getTarget().getName() = "SingleOrDefault")
  ) and
  not m.getDeclaringType().getName().matches("%Migration%") and
  not m.getDeclaringType().getName().matches("%Test%")
select toListCall, "Senior EF Core (R-NET-017): Database query executed without paging (Skip/Take). Enforce pagination to prevent out-of-memory errors."
