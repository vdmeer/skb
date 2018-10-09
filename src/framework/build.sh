#!/usr/bin/env bash

gradle -c java.settings clean
gradle -c java.settings
gradle -c distribution.settings
