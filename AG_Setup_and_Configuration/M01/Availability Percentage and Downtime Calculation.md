### Availability Percentage and Downtime Calculation

|Availability %|Downtime per Year|
|--------|------------------|
|99%     |~3.65 days|
|99.9%   |~8.76 hours|
|99.99%  |~52.6 minutes|
|99.999% |~5.26 minutes|

<mark><b>To calculate downtime per year:</mark></b>

`Downtime` (minutes/year) = (1 - Availability%) × ((60 minuts x 24 hours per day) x 365 days per year) = 525,600 minuts

`Downtime` (minutes/year) = (1 - Availability%) × 525,600 minuts

99.999% downtime is:

`Downtime` = (1 - 0.9999) × 525,600 = **~52.56 minutes/year**


### What Impacts Availability in Synchronous AG?

Even in synchronous mode, actual availability depends on:

- Network latency between replicas
- Redo queue delays on secondary
- Automatic failover configuration
- Hardware reliability
- Patch and maintenance windows


### Best Practices to Maximize Availability

- Use `automatic failover` with a third replica as a witness.
- `Monitor` redo queue size and send rate using DMVs like `sys.dm_hadr_database_replica_states`.
- Ensure `low-latency` and `high-throughput` network between replicas.
- Apply patches during scheduled maintenance windows with `failover planning`.

