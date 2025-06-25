#!/bin/sh
sleep 1
killall -e xdg-desktop-portal-hyprland
killall -e xdg-desktop-portal-gtk
killall -e xdg-desktop-portal-wlr
killall xdg-desktop-portal
xdg-desktop-portal-hyprland &
sleep 2
xdg-desktop-portal-gtk &
sleep 2
xdg-desktop-portal &
