before you start this lab, you have to create a performance monitor for some counters to see the after and before.

here are the steps to create the Perfmon:
![alt text](https://github.com/MohamedAbdelhalem/dbatools/blob/main/Monitor/Perfmon/media/new_perfmon_1.png)

![alt text](https://github.com/MohamedAbdelhalem/dbatools/blob/main/Monitor/Perfmon/media/new_perfmon_2.png)

![alt text](https://github.com/MohamedAbdelhalem/dbatools/blob/main/Monitor/Perfmon/media/new_perfmon_3.png)

![alt text](https://github.com/MohamedAbdelhalem/dbatools/blob/main/Monitor/Perfmon/media/new_perfmon_4.png)

Here add the below counters

![alt text](https://github.com/MohamedAbdelhalem/dbatools/blob/main/Monitor/Perfmon/media/new_perfmon_5.png)

then start it

![alt text](https://github.com/MohamedAbdelhalem/dbatools/blob/main/Monitor/Perfmon/media/new_perfmon_6.png)

Here is the saved query run it and you will observe it takes a lot of time to run

![alt text](https://github.com/MohamedAbdelhalem/dbatools/blob/main/Monitor/Perfmon/media/slow_script.png)

after the above query has been completed, stop the performance counter and see the report

![alt text](https://github.com/MohamedAbdelhalem/dbatools/blob/main/Monitor/Perfmon/media/slow_perfmon.png)

do this changes to fix the issue by committing after 1000 inserts to decrease the Transaction log writer bottelneck becsuse the above report says, its only 514 bytes/sec which is very low number,
so, to increase the avreage size you have to batch your transaction into many patches and change it into explicit transaction instead of auto commit (default behaviour).

![alt text](https://github.com/MohamedAbdelhalem/dbatools/blob/main/Monitor/Perfmon/media/fast_script.png)

and now you can see the differences, how fast and effection.

![alt text](https://github.com/MohamedAbdelhalem/dbatools/blob/main/Monitor/Perfmon/media/fast_perfmon.png)
