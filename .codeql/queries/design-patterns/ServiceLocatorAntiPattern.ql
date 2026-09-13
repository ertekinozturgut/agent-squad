/**
 * @name Service Locator Anti-Pattern
 * @description Direct resolution from IServiceProvider obscures class dependencies, complicates testing, and violates Dependency Inversion (DIP).
 * @kind problem
 * @problem.severity error
 * @precision high
 * @id cs/design-patterns/service-locator-anti-pattern
 * @tags design-patterns
 *       architecture
 *       maintainability
 */

import csharp

from MethodCall mc
where
  (
    mc.getTarget().hasQualifiedName("System", "IServiceProvider", "GetService") or
    mc.getTarget().getName() = "GetRequiredService"
  ) and
  not mc.getEnclosingCallable().getDeclaringType().getName().matches("%Program%") and
  not mc.getEnclosingCallable().getDeclaringType().getName().matches("%Startup%") and
  not mc.getEnclosingCallable().getDeclaringType().getName().matches("%DependencyInjection%") and
  not mc.getEnclosingCallable().getDeclaringType().getName().matches("%Factory%")
select mc, "Design Pattern / DIP: Direct service resolution using Service Locator ($@). Inject dependencies explicitly via constructor.", mc.getTarget(), mc.getTarget().getName()
