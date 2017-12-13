#!/bin/bash

UGROUP=$(id -gn)
if [ -c /dev/vmnet0 ]
then
	sudo chgrp ${UGROUP} /dev/vmnet*
	sudo chmod g+rw /dev/vmnet*
fi
