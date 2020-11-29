#!/bin/bash
awk -i inplace '!seen[$0]++' domains.txt
