#!/bin/bash

export LABEL=acme
export SESSION=acme

perl $XDSI/tests/iig/iig-1001/iig-1001-11.pl $LABEL $SESSION acme__iig
