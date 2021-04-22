#!/bin/bash

###################################################
#
# Permutation to create a list of possible
# Hardware IDs  (3 uppercase letters)
#
# Simple Brute-Force to fetch possible
# BIOS Files
#
# Tavinus 2021
#
# Redirect the output of this file to your
# target file
#
# ./permuteThree.sh > permutedHIDs.txt


for c1 in {A..Z}; do
	for c2 in {A..Z}; do
		for c3 in {A..Z}; do
			echo $c1$c2$c3
		done
	done
done

