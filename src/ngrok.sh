#!/bin/bash

###################################
#       ROBOT DEVELOPMENT         #
#    ngrok functionality script   #
#       by: Zak Schlemmer         #
###################################


# find project
if [ `pwd | grep -c "robot.dev"` == "0" ]; then
    remove=`pwd | xargs dirname`
    project=`pwd | sed "s@${remove}/@@g"`
else
    project=`pwd | sed 's/.*robot.dev\///' | cut -f1 -d"/"`
fi

# prompt user for alias
echo ""
echo -n "Please enter the ngrok server alias for this project: "
read server_alias
echo ""

# create the server alias in the vhost based on project case
docker exec -t ${project}_web_1 bash -c "sed -i '3i\serveralias ${server_alias}' /etc/apache2/sites-available/${project}.robot"
docker exec -t robot_nginx_1 bash -c 'sed -i -e "s/'${project}'\.robot\;/'${project}'\.robot '${server_alias}'\;/g" /etc/nginx/nginx.conf'

# reload apache we modified
docker exec -t ${project}_web_1 bash -c "/etc/init.d/apache2 reload" && echo ""

# reload nginx to get any needed changes
docker exec -t robot_nginx_1 bash -c "nginx -s reload" && echo ""

echo "${server_alias} ready for ngrok." && echo ""
