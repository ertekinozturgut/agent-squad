/**
 * @name Sensitive data / PII in logging invocation (R-PII-001 / Senior Security)
 * @description Logging personal data (TCKN, password, token, email) leaks sensitive information into observability storage (CWE-532, KVKK m.12).
 * @kind problem
 * @problem.severity error
 * @precision high
 * @id cs/senior-engineering/sensitive-data-logged
 * @tags security
 *       privacy
 *       cwe-532
 *       r-pii-001
 */

import csharp

from MethodCall mc, Expr arg
where
  mc.getTarget().getDeclaringType().hasQualifiedName("Microsoft.Extensions.Logging", "ILogger") and
  arg = mc.getAnArgument() and
  (
    arg.getValue().matches("%password%") or
    arg.getValue().matches("%secret%") or
    arg.getValue().matches("%token%") or
    arg.getValue().matches("%tckn%") or
    arg.getValue().matches("%apikey%")
  )
select mc, "Senior Security (R-PII-001 / CWE-532): Potential sensitive credential or PII parameter passed to logger. Mask or redact before logging."
