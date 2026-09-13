/**
 * @name Unbounded Channel creation (R-NET-073 / Memory Exhaustion)
 * @description Unbounded channels (Channel.CreateUnbounded) lack backpressure. Under high load, producers can overwhelm consumers and cause OutOfMemory crashes.
 * @kind problem
 * @problem.severity warning
 * @precision high
 * @id cs/senior-engineering/unbounded-channel-usage
 * @tags performance
 *       reliability
 *       r-net-073
 */

import csharp

from MethodCall mc
where
  mc.getTarget().hasQualifiedName("System.Threading.Channels", "Channel", "CreateUnbounded")
select mc, "Senior Reliability (R-NET-073): Unbounded Channel lacks backpressure protection. Use 'Channel.CreateBounded<T>(capacity)' with a BoundedChannelOptions strategy."
