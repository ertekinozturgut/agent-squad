/**
 * @name Observer pattern event subscription without unsubscription
 * @description Subscribing to an event on a longer-lived publisher without unregistering causes memory leaks in the Observer pattern.
 * @kind problem
 * @problem.severity warning
 * @precision medium
 * @id cs/design-patterns/observer-missing-unsubscribe
 * @tags design-patterns
 *       memory-management
 *       reliability
 */

import csharp

from AddEventExpr aee, Class c
where
  c = aee.getEnclosingCallable().getDeclaringType() and
  c.getABaseType*().hasQualifiedName("System", "IDisposable") and
  not exists(RemoveEventExpr ree |
    ree.getEnclosingCallable().getDeclaringType() = c and
    ree.getTarget() = aee.getTarget()
  )
select aee, "Design Pattern: Event $@ subscribed without corresponding unsubscription in Dispose. This may cause a publisher-subscriber memory leak.", aee.getTarget(), aee.getTarget().getName()
