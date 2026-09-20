/**
 * @name Broken double-checked locking in Singleton
 * @description Singletons using double-checked locking without a 'volatile' backing field suffer from memory reordering issues in multi-threaded environments.
 * @kind problem
 * @problem.severity error
 * @precision high
 * @id cs/design-patterns/singleton-broken-double-check
 * @tags design-patterns
 *       concurrency
 *       maintainability
 */

import csharp

/*
 * R-GOF-006.
 *
 * Aranan desen: statik, volatile OLMAYAN bir alanın önce kilit dışında, sonra
 * kilit içinde kontrol edilmesi (double-checked locking). Singleton backing
 * field'ı tanımı gereği STATİKTİR; alanı statik olmayanlarla sınırlamak kuralı
 * sessizce etkisiz bırakır.
 */
from Field f, IfStmt outerCheck, LockStmt lockStmt, IfStmt innerCheck
where
  f.isStatic() and
  not f.isVolatile() and
  // 1) Kilit dışındaki ilk kontrol
  outerCheck.getCondition().getAChildExpr*() = f.getAnAccess() and
  // 2) İlk kontrolün gövdesindeki lock bloğu
  lockStmt.getParent+() = outerCheck.getThen() and
  // 3) Lock bloğu içindeki ikinci kontrol
  innerCheck.getParent+() = lockStmt.getBlock() and
  innerCheck.getCondition().getAChildExpr*() = f.getAnAccess()
select f,
  "Design Pattern (R-GOF-006): Singleton field $@ is used in double-checked locking without being marked 'volatile'. Use Lazy<T> instead.",
  f, f.getName()
