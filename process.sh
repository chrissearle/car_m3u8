#!/bin/bash

rm -f files.m3u8
tr  '\n' < Car.m3u8 > files.m3u8
