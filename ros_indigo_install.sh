#!/bin/bash
# The BSD License
# Copyright (c) 2015 Laboratory For Intelligent Robots & Vision System, Kyushu University.

version=`lsb_release -sc`

echo "[Checking the ubuntu version]"
case $version in
  "saucy" | "trusty")
  ;;
  *)
    echo "[This script will only work on ubuntu saucy(13.10) or trusty(14.04)]"
    exit 0
esac

echo "[Update & upgrade the package]"
sudo apt-get update -qq
sudo apt-get upgrade -qq

echo "[Check the 14.04.2 TLS issue]"
relesenum=`grep DISTRIB_DESCRIPTION /etc/*-release | awk -F 'Ubuntu ' '{print $2}' | awk -F ' LTS' '{print $1}'`
if [ "$relesenum" = "14.04.2" ]
then
  echo "Your ubuntu version is $relesenum"
  echo "Intstall the libgl1-mesa-dev-lts-utopic package to solve the dependency issues during the ROS installation"
  sudo apt-get install -y libgl1-mesa-dev-lts-utopic
else
  echo "Your ubuntu version is $relesenum"
fi

echo "[Installing chrony and setting the ntpdate]"
sudo apt-get install -y chrony
sudo ntpdate ntp.ubuntu.com

echo "[Add the ROS repository]"
if [ ! -e /etc/apt/sources.list.d/ros-latest.list ]; then
  sudo sh -c "echo \"deb http://packages.ros.org/ros/ubuntu ${version} main\" > /etc/apt/sources.list.d/ros-latest.list"
fi

echo "[Set up your ROS keys]"
wget https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -O - | sudo apt-key add -

echo "[Update & upgrade the package]"
sudo apt-get update -qq
sudo apt-get upgrade -qq

echo "[Installing ROS]"
sudo apt-get install -y ros-indigo-desktop-full ros-indigo-rqt-*

echo "[rosdep init and python-rosinstall]"
sudo sh -c "rosdep init"
rosdep update
. /opt/ros/indigo/setup.sh
sudo apt-get install -y python-rosinstall

echo "[Making the catkin workspace and testing the catkin_make]"
mkdir -p ~/catkin_ws/src
cd ~/catkin_ws/src
catkin_init_workspace
cd ~/catkin_ws/
catkin_make

echo "[Setting the ROS evironment]"
sh -c "echo \"source /opt/ros/indigo/setup.bash\" >> ~/.bashrc"
sh -c "echo \"source ~/catkin_ws/devel/setup.bash\" >> ~/.bashrc"
sh -c "echo \"export ROS_MASTER_URI=http://localhost:11311\" >> ~/.bashrc"
sh -c "echo \"export ROS_HOSTNAME=localhost\" >> ~/.bashrc"

echo "[Complete!!!]"

exec bash

exit 0

