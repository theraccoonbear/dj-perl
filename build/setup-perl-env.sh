#!/bin/bash

cd /opt/src/app

cpanm --installdeps --no-wget --verbose --notest .
