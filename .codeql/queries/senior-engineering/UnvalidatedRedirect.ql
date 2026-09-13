/**
 * @name Unvalidated open redirect (CWE-601 / Senior Web Security)
 * @description Redirecting to a user-supplied URL without verifying that it is local allows attackers to conduct phishing campaigns via open redirects.
 * @kind problem
 * @problem.severity error
 * @precision high
 * @id cs/senior-engineering/unvalidated-open-redirect
 * @tags security
 *       open-redirect
 *       cwe-601
 */

import csharp

from MethodCall mc, Parameter p
where
  (mc.getTarget().getName() = "Redirect" or mc.getTarget().getName() = "LocalRedirect") and
  p.getName().matches("%url%") and
  mc.getAnArgument().(ParameterAccess).getTarget() = p and
  not exists(MethodCall urlCheck |
    urlCheck.getEnclosingCallable() = mc.getEnclosingCallable() and
    urlCheck.getTarget().getName() = "IsLocalUrl"
  )
select mc, "Senior Web Security (CWE-601): Open redirect risk on parameter $@. Validate target with 'Url.IsLocalUrl()' before redirecting.", p, p.getName()
