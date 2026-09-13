/**
 * @name Unreleased IDisposable instance (Sonar S2930 / CA2000)
 * @description Local instances of IDisposable must be disposed using a 'using' statement or declaration to prevent unmanaged resource leaks.
 * @kind problem
 * @problem.severity error
 * @precision high
 * @id cs/sonarqube/missing-dispose-on-idisposable
 * @tags efficiency
 *       reliability
 *       sonar-s2930
 *       ca2000
 */

import csharp

from LocalVariableDeclExpr decl, ObjectCreation oc
where
  decl.getInitializer() = oc and
  oc.getType().getABaseType*().hasQualifiedName("System", "IDisposable") and
  not exists(UsingStmt us | us.getAVariableDeclExpr() = decl) and
  not exists(UsingPatternStmt ups | ups.getAVariableDeclExpr() = decl) and
  not decl.getVariable().getName().matches("%builder%") and
  not decl.getEnclosingCallable().getName().matches("Create%")
select decl, "SonarQube S2930 / CA2000: Disposable instance $@ is not enclosed in a using statement or declaration.", decl, decl.getName()
