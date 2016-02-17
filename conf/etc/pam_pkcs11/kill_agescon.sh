#!/bin/sh
JP=$(ps aux | grep jwm | grep -v grep | awk '{print $1}')
MP=$(ps aux | grep midori | grep -v grep | awk '{print $1}')
kill -kill $MP 
kill -kill $JP

