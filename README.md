#### Bash Script to monitor status of docker container using mysql and slack webhook ####
---

##### Components of application #####
1. Bash script
2. MySQL DB
3. Slack token.
[Configure Slack Web App](https://api.slack.com/tutorials/tracks/getting-a-token)

##### Steps to implement the script #####
1. Create database status.
2. Create table container_status with two columns id and status
```
    mysql> describe container_status;
    +--------+-------------+------+-----+---------+-------+
    | Field  | Type        | Null | Key | Default | Extra |
    +--------+-------------+------+-----+---------+-------+
    | id     | int(11)     | YES  |     | NULL    |       |
    | status | varchar(20) | YES  |     | NULL    |       |
    +--------+-------------+------+-----+---------+-------+
 ```
3. Set initial state of table as below.
```
    +------+--------+
    | id   | status |
    +------+--------+
    |    1 | up     |
    +------+--------+
 ```
4. Configure credentials to be used for mysql as login path.
[Doc about login path](https://dev.mysql.com/doc/refman/5.6/en/option-file-options.html)
5. Schedule the script to run at required intervals.
6. Save the slack token in text file at the same folder level as script.
---

##### Working of script #####
1. Script checks the status of container using docker inspect.
2. Compares the received status (**up** or **down**) of container with the status marked in database.
3. If the received status is same as the status in database, no further action.
4. If the received status is different
    If received status is **down** and status marked is **up** in database
        update database with **down** status and send slack notification of container is **down**
    If received status is **up** and status marked is **down** in database
        update database with **up** status and send slack notification of container is **up**
