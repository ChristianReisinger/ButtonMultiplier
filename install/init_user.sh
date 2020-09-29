#!/bin/bash

mkdir -p "../user/profiles/"
cp -n "TEMPLATE_settings.ini" "../user/settings.ini"
cp -n "TEMPLATE_Profile.ahk" "../user/"
cp -n "TEMPLATE_Default_Profile.ahk" "../user/profiles/Default.ahk"
