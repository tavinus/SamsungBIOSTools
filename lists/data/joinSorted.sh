#!/bin/bash

###################################################
# Tavinus 2021
#
# Join .sorted.txt files and resort with unique
#
###################################################

cat *.sorted.txt | sort -u -o ../ItemList.txt
