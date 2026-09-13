/**
 * @name Direct HttpClient instantiation (R-NET-022 / Socket Exhaustion)
 * @description Instantiating HttpClient with 'new' for each request exhausts OS socket handles. Use IHttpClientFactory or typed HTTP clients.
 * @kind problem
 * @problem.severity error
 * @precision high
 * @id cs/senior-engineering/new-httpclient-instance
 * @tags performance
 *       reliability
 *       r-net-022
 */

import csharp

from ObjectCreation oc
where
  oc.getType().hasQualifiedName("System.Net.Http", "HttpClient") and
  not oc.getEnclosingCallable().getDeclaringType().getName().matches("%Factory%") and
  not oc.getEnclosingCallable().getDeclaringType().getName().matches("%Program%") and
  not oc.getEnclosingCallable().getDeclaringType().getName().matches("%Startup%") and
  not oc.getEnclosingCallable().getDeclaringType().getName().matches("%Test%")
select oc, "Senior Performance (R-NET-022): Direct 'new HttpClient()' causes socket exhaustion. Inject 'IHttpClientFactory' or use a typed client."
