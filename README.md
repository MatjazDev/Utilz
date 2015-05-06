This repo is a mess by definition. It's a collection of various scripts, mostly Bash, I frequently use and think would be nice to share.

count_lines_of_java_code.sh
---------------------------
Run it when located in the root folder of a Java Maven project and this script will save on files and return you an analysis of the Java project including number of lines of Java code, Javadoc lines, empty lines and various ratios between them.

apt_get_autoupdater.sh
----------------------
This extremly basic script contains a list of commands to perform a complete apt update and upgrade of the OS to be called directly from crontab. This allows automatic apt packages upgrades.

See [my blog post](http://matjaz.it/automatically-update-a-debian-ubuntu-using-apt-get-and-cron/) about this script.

ring_distance.c
---------------
This C struct and function allows to find the shortest path on a ring-like structure, more specifically a sequentially sorted circular double linked list.

See [my blog post](http://matjaz.it/shortest-path-problem-in-ring-buffer-or-circular-double-linked-list/) about this program.
