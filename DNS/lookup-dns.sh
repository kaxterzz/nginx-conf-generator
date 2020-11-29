#!/bin/bash
while IFS= read -r line; do
	echo -e "---------- Nameservers for $line -----------"
	host -t ns $line
	echo -e "----------------------------------------------------------------\n"
done < domains.txt
