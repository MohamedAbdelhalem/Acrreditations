Before starting this lab, you need to create a performance monitor for certain counters to compare the results afterward.

Here are the steps to create the Performance Monitor (Perfmon):

1. Follow the instructions in the provided images to set it up:

![alt text](https://github.com/MohamedAbdelhalem/dbatools/blob/main/Monitor/Perfmon/media/new_perfmon_1.png)

![alt text](https://github.com/MohamedAbdelhalem/dbatools/blob/main/Monitor/Perfmon/media/new_perfmon_2.png)

![alt text](https://github.com/MohamedAbdelhalem/dbatools/blob/main/Monitor/Perfmon/media/new_perfmon_3.png)

![alt text](https://github.com/MohamedAbdelhalem/dbatools/blob/main/Monitor/Perfmon/media/new_perfmon_4.png)

2. Add the following counters:

![alt text](https://github.com/MohamedAbdelhalem/dbatools/blob/main/Monitor/Perfmon/media/new_perfmon_5.png)

3. Start the performance monitor:

![alt text](https://github.com/MohamedAbdelhalem/dbatools/blob/main/Monitor/Perfmon/media/new_perfmon_6.png)

4. Use the provided saved query and run it. You will notice that it takes a significant amount of time to complete:

![alt text](https://github.com/MohamedAbdelhalem/dbatools/blob/main/Monitor/Perfmon/media/slow_script.png)

5. After the query has finished running, stop the performance counter and review the report:

![alt text](https://github.com/MohamedAbdelhalem/dbatools/blob/main/Monitor/Perfmon/media/slow_perfmon.png)

To address the identified issue, make the following changes: commit after every 1,000 inserts to reduce the transaction log writer bottleneck. The report indicates that the write speed is only 516 bytes per second, which is quite low. To improve the average size, batch your transactions into multiple patches and change them into explicit transactions instead of using the default auto-commit behavior.

![alt text](https://github.com/MohamedAbdelhalem/dbatools/blob/main/Monitor/Perfmon/media/fast_script.png)

Now you can see the differences and how fast and effective they are.

![alt text](https://github.com/MohamedAbdelhalem/dbatools/blob/main/Monitor/Perfmon/media/fast_perfmon.png)
