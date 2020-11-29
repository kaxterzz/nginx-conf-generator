#!/bin/bash
while IFS= read -r line; do
        echo -e "unsubscribe.$line\t"; dig +short "unsubscribe.$line" a
done < domains.txt
