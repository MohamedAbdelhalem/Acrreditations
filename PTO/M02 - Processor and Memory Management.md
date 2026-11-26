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

## $Parallelism Wait\\% = \frac{Total Relevant Wait Time}{Parallelism Wait Time} x 100$

For example:

|Wait type|	Wait time (ms)|
|----------|---------------|
|CXPACKET	|20,000|
|PAGEIOLATCH_SH|	30,000|
|LCK_M_X|	10,000|
|WRITELOG|	40,000|
|Total|	100,000|

Here:

CXPACKET% = \frac{20000}{100000} × 100 =20%$

CXPACKET\%=\frac{20000}{100000}\times100=20\%CXPACKET%=10000020000​×100=20%

## $CXPACKET\\% = \frac{20000}{100000} x 100 \\= 20 $ 

Interpretation: CXPACKET represents 20% of the selected wait time.

However, this does not mean:

CPU utilization is 20%.
20% of queries are executing in parallel.
Parallelism is consuming 20% of CPU resources.

It only means that CXPACKET accounts for 20% of the wait time included in the calculation.
