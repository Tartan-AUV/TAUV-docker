#!/bin/bash

rocker --nvidia --x11 --privileged --home --port 22$(id -u | rev | cut -c1-3 | rev):22 tauv/x86-nvidia-workstation
