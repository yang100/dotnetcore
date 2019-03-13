#!/usr/bin/env bash
cat >/etc/motd <<EOL 
  _____                               
  /  _  \ __________ _________   ____  
 /  /_\  \\___   /  |  \_  __ \_/ __ \ 
/    |    \/    /|  |  /|  | \/\  ___/ 
\____|__  /_____ \____/ |__|    \___  >
        \/      \/                  \/ 
A P P   S E R V I C E   O N   L I N U X

Documentation: http://aka.ms/webapp-linux
Dotnet quickstart: https://aka.ms/dotnet-qs
.NETCore runtime version: `ls -X /usr/share/dotnet/shared/Microsoft.NETCore.App | tail -n 1`

EOL
cat /etc/motd

sed -i "s/SSH_PORT/$SSH_PORT/g" /etc/ssh/sshd_config
service ssh start

[ -z "$ASPNETCORE_URLS" ] && export ASPNETCORE_URLS=http://*:"$PORT"

# If there is any command line argument specified, run it
if [ $# -ne 0 ]; then
   echo "App Command Line configured: $@"
   echo "Checking if first argument is dotnet and second argument is a file on disk"
   if [ $1 == "dotnet" -a -f $2 ]; then
        echo "Argument to dotnet exists on disk, launching it:  $@"
        exec "$@"
   else
       echo "App command line ignored, since file $2 was not found"
   fi
fi

# Pick up one .csproj file from repository where git push puts files into
CSPROJ=`ls -1 /home/site/repository/*.csproj 2>/dev/null | head -1`

# Convert /home/site/repository/<name>.csproj into ./<name>.dll and execute it
if [ -n "$CSPROJ" ]; then
    DLL=./`basename "$CSPROJ" .csproj`.dll
    if [ -e $DLL ]; then
        echo Found: $DLL
        exec dotnet "$DLL"
    else
        if [ -d /home/site/wwwroot/oryx_publish_output ]; then
            DLL=./oryx_publish_output/`basename "$CSPROJ" .csproj`.dll
            if [ -e $DLL ]; then
                echo Found: $DLL
                exec dotnet "$DLL"
            fi
        fi
    fi
fi

echo Could not find .csproj or .dll. Using default.
cd /defaulthome/hostingstart
exec dotnet hostingstart.dll

