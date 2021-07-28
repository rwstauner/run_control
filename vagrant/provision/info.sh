#!/bin/bash

command -v facter && \
facter memorysize processorcount

# FIXME: ip addr show?
# /sbin/ifconfig | perl -lne 'print $1 if /addr:([0-9.]+)/'
