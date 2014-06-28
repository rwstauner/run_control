#!/bin/bash

facter memorysize processorcount

/sbin/ifconfig | perl -lne 'print $1 if /addr:([0-9.]+)/'
