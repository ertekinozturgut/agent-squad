/**
 * @name Public field violates encapsulation (Sonar S1104 / CA1051)
 * @description Fields in classes should be private or protected and accessed through properties to ensure proper encapsulation and state control.
 * @kind problem
 * @problem.severity warning
 * @precision high
 * @id cs/sonarqube/public-field-encapsulation-violation
 * @tags maintainability
 *       sonar-s1104
 *       ca1051
 */

import csharp

from Field f, Class c
where
  f.getDeclaringType() = c and
  f.isPublic() and
  not f.isConst() and
  not f.isReadOnly() and
  not c.getName().matches("%Dto%") and
  not c.getName().matches("%Record%") and
  not c instanceof Struct
select f, "SonarQube S1104 / CA1051: Public field $@ exposes internal class state. Replace with a property.", f, f.getName()
