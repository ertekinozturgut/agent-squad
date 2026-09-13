/**
 * @name Factory Method returning concrete implementation
 * @description Factory methods should return abstractions (interfaces or abstract classes) rather than concrete classes to decouple client code from implementations.
 * @kind problem
 * @problem.severity warning
 * @precision high
 * @id cs/design-patterns/factory-returns-concrete
 * @tags design-patterns
 *       maintainability
 */

import csharp

from Method m, Class factoryClass
where
  factoryClass.getName().matches("%Factory%") and
  m.getDeclaringType() = factoryClass and
  m.isPublic() and
  m.getName().matches("Create%") and
  m.getReturnType() instanceof Class and
  not m.getReturnType().(Class).isAbstract() and
  not m.getReturnType().hasQualifiedName("System", "Object")
select m, "Design Pattern: Factory method $@ returns concrete class $@ instead of an interface or abstract base.", m, m.getName(), m.getReturnType(), m.getReturnType().getName()
