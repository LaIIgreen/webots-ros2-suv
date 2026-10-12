#!/usr/bin/env bash
set -euo pipefail

if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
  echo "Usage: setup.sh [--first-time-ros-setup]"
  exit 0
fi

source /opt/ros/humble/setup.bash
if [ ! -f /etc/ros/rosdep/sources.list.d/20-default.list ]; then
  sudo rosdep init
fi
rosdep update --rosdistro "${ROS_DISTRO}"
cd /ulstu/ros2_ws
rosdep install --rosdistro "${ROS_DISTRO}" -r --from-paths src --ignore-src -y
