Why does the workshop mention OLTP?

OLTP workloads typically execute many short transactions.

For example:
- INSERT
- UPDATE
- DELETE
- Small SELECT queries

These workloads often benefit from efficient serial execution.

If many small OLTP queries execute using parallel plans, the overhead of coordinating multiple workers may outweigh the performance benefits.

Microsoft specifically recognizes that excessive parallelism can negatively affect OLTP workloads.

C. What does the 20% mean?

The workshop most likely means:

If parallelism-related waits account for more than 20% of the total relevant wait time, investigate potential parallelism issues.

The formula would be:

Parallelism Wait %

$Parallelism Wait = \frac{Total Relevant Wait Time}{Parallelism Wait Time} x 100$
