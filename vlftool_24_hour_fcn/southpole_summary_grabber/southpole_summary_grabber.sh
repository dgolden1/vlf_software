#!/bin/bash

# Simple little shell script to run the python script and log the output
# By Daniel Golden (dgolden1 at stanford dot edu) May 2010

cd /array/home/vlf-sftp/scott_outbox/southpole_summary_grabber
python southpole_summary_grabber.py >> southpole_summary_grabber.log 2>&1
