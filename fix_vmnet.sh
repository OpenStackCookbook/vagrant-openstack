#!/bin/bash

UGROUP=$(id -gn)
sudo chgrp ${UGROUP} /dev/vmnet*
sudo chmod g+rw /dev/vmnet*
