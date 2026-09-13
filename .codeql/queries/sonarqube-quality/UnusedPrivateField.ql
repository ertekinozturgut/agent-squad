/**
 * @name Unread private field (Sonar S1450 / S1068)
 * @description Private fields that are never read are dead code and add unnecessary clutter and memory overhead.
 * @kind problem
 * @problem.severity warning
 * @precision high
 * @id cs/sonarqube/unused-private-field
 * @tags maintainability
 *       sonar-s1450
 *       sonar-s1068
 */

import csharp

from Field f
where
  f.isPrivate() and
  not f.isConst() and
  not exists(FieldRead fr | fr.getTarget() = f) and
  not exists(Attribute a | a.getTarget() = f) and
  not f.getDeclaringType().getName().matches("%Test%")
select f, "SonarQube S1450 / S1068: Private field $@ is never read. Remove this unused field.", f, f.getName()
