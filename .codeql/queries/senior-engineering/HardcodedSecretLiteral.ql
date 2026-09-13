/**
 * @name Hardcoded credentials or symmetric keys (CWE-798 / Senior Security)
 * @description Hardcoding secret keys, connection strings, or JWT symmetric keys into source code invites extraction via decompilation or repository leaks.
 * @kind problem
 * @problem.severity error
 * @precision high
 * @id cs/senior-engineering/hardcoded-secret-literal
 * @tags security
 *       credentials
 *       cwe-798
 */

import csharp

from Variable v, StringLiteral sl
where
  v.getInitializer() = sl and
  (
    v.getName().matches("%Secret%") or
    v.getName().matches("%ApiKey%") or
    v.getName().matches("%Password%") or
    v.getName().matches("%PrivateKey%")
  ) and
  sl.getValue().length() > 16 and
  not v.getEnclosingCallable().getDeclaringType().getName().matches("%Test%")
select sl, "Senior Security (CWE-798): Hardcoded credential or secret detected in variable $@. Store in Azure KeyVault or Secret Manager.", v, v.getName()
