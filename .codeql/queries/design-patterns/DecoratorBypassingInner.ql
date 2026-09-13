/**
 * @name Decorator class bypassing wrapped instance
 * @description A Decorator class must forward operations to its decorated inner component. Overridden methods that ignore the inner instance break the Decorator pattern.
 * @kind problem
 * @problem.severity error
 * @precision medium
 * @id cs/design-patterns/decorator-bypassing-inner
 * @tags design-patterns
 *       correctness
 *       maintainability
 */

import csharp

from Class decorator, Field inner, Method m
where
  decorator.getName().matches("%Decorator%") and
  inner.getDeclaringType() = decorator and
  inner.getType() = decorator.getABaseInterface() and
  m.getDeclaringType() = decorator and
  m.isPublic() and
  not exists(MethodCall mc |
    mc.getEnclosingCallable() = m and
    mc.getAnArgument*().(FieldAccess).getTarget() = inner
  ) and
  not m.isVirtual() and
  not m.getName().matches("get_%") and
  not m.getName().matches("set_%")
select m, "Design Pattern: Decorator method $@ does not delegate to wrapped inner field $@.", m, m.getName(), inner, inner.getName()
