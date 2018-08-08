#!/bin/bash

cd /opt/src/app
curl -LO http://xrl.us/cpanm
perl cpanm --installdeps --no-wget --verbose .
