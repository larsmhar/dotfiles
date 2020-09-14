#!/bin/bash
if [ "$(playerctl status -p spotify)" = "Playing" ]; then
  title=`exec playerctl -p spotify metadata xesam:title`
  artist=`exec playerctl -p spotify metadata xesam:artist`
  echo " $title - $artist"
else
  echo ""
fi
