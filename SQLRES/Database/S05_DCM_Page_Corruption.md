### What does the DCM page do?
It tracks the changes in extents since the last full backup.

### How have they been cleaning?
The full backup is responsible for clearing the DCM pages.


### How to mitigate when you have DCM corruption?
If you experience a DCM system page corruption, you cannot perform a normal full backup. The full backup process requires clearing out the DCM pages, but corrupted pages will prevent this from happening.

To resolve this situation, we need to take a full backup using `COPY_ONLY` and restore it during downtime. First, we must agree with the application team to stop modifying the database and schedule a downtime window. Once the application is completely shut down, we can take a backup with `COPY_ONLY` and then proceed with the restore.
