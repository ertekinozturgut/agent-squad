/**
 * @name Insecure Random generator used in security context (R-CRY-003 / Senior Cryptography)
 * @description System.Random is pseudo-random and predictable. Cryptographic operations (tokens, nonces, salt) must use RandomNumberGenerator.
 * @kind problem
 * @problem.severity error
 * @precision high
 * @id cs/senior-engineering/insecure-random-generator
 * @tags security
 *       cryptography
 *       cwe-338
 *       r-cry-003
 */

import csharp

from ObjectCreation oc
where
  oc.getType().hasQualifiedName("System", "Random") and
  (
    oc.getEnclosingCallable().getName().matches("%Token%") or
    oc.getEnclosingCallable().getName().matches("%Key%") or
    oc.getEnclosingCallable().getName().matches("%Password%") or
    oc.getEnclosingCallable().getName().matches("%Auth%") or
    oc.getEnclosingCallable().getName().matches("%Salt%")
  )
select oc, "Senior Cryptography (R-CRY-003 / CWE-338): System.Random is predictable and insecure for cryptographic contexts. Use 'RandomNumberGenerator.GetBytes()' instead."
