#! /usr/bin/env python

"""
Program to grab south pole summary plots when the satellite is up

By Daniel Golden (dgolden1 at stanford dot edu) May 2010
$Id$
"""

import datetime # Times of TDRS passes
import urllib   # Get TDRS schedule from Internet
import re       # Regular expressions
#import ssh      # SSH utilities that I grabbed from http://commandline.org.uk/python/sftp-python-really-simple-ssh/
import socket   # For SSH errors
import paramiko # For more complicated SFTP stuff
import os       # Get information about local files

class TrdsPass:
    """Time information for a single TDRS pass."""
    
    def __init__(self, startdate=None, duration=None, tdrs_file_line=None):
        if tdrs_file_line is None:
            self.startdate = startdate
            self.duration = duration
        else:
            # Example format: 'MS   Y  171 10/143/143000 150500 003500 --- SNS H02 I02 P04            4   '
            r = re.compile('(\d{2})/(\d{3})/(\d{6}) (\d{6}) (\d{6})')
            result = r.search(tdrs_file_line, 12, 39)
            if result is None:
                raise Exception('Invalid line format:' + tdrs_file_line)
            year = int(result.group(1)) + 2000
            doy = int(result.group(2))
            hhmmss = result.group(3)
            hour = int(hhmmss[0:2])
            min = int(hhmmss[2:4])
            sec = int(hhmmss[4:6])
            sectotal = sec + ((hour*60) + min)*60
            self.startdate = datetime.datetime(year, 1, 1) + datetime.timedelta(doy - 1, sectotal)
            
            dur_hhmmss = result.group(5)
            dur_hour = int(dur_hhmmss[0:2])
            dur_min = int(dur_hhmmss[2:4])
            dur_sec = int(dur_hhmmss[4:6])
            dur_sectotal = dur_sec + (dur_hour*60 + dur_min)*60
            self.duration = datetime.timedelta(0, dur_sectotal)
            
        
    def IsBetween(self, date):
        if date >= self.startdate and date < self.startdate + self.duration:
            return True
        else:
            return False

def GetRemoteFileSize(sftp, filename):
    """File size of remote files in bytes"""
    attr = sftp.lstat(filename)
    return attr.st_size

def GetLocalFileSize(filename):
    """File size of local file in bytes"""
    attr = os.stat(filename)
    return attr.st_size

def SftpConnect(remote_host, username, key_filename=None):
    """Connect to remote SSH host and return ssh and sftp objects."""
    ssh = paramiko.SSHClient()
    if key_filename == None:
        look_for_keys = True
    else:
        look_for_keys = False

    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(remote_host, username=username, key_filename=key_filename)
    sftp = ssh.open_sftp()
    return ssh, sftp
    
def GetFiles(thispass, b_debug=False):
    """Download files from South Pole and dump them into autosort directory on scott."""
    

    if b_debug:
        local_tempdir = '/tmp'
        ip_southpole = 'localhost'
        ip_scott = 'localhost'
        sp_file_src_dir = '/home/dgolden/temp/sptest_src1'
        sp_file_dest_dir = '/home/dgolden/temp/sptest_src2'
        scott_upload_dir = '/home/dgolden/temp/sptest_dest'
        username_sp = 'dgolden'
        username_scott = 'dgolden'
        key_filename='/home/dgolden/.ssh/id_rsa_noenc'
        
    else:
        local_tempdir = '/array/home/vlf-sftp/scott_outbox/files/'
        ip_southpole = '10.3.1.169'
        sp_file_src_dir = '/cygdrive/c/VLF_DAQ_DISTRO/Spectrogram/24hour/upload'
        sp_file_dest_dir = '/cygdrive/c/VLF_DAQ_DISTRO/Spectrogram/24hour'
        username_sp = 'vlf'
        key_filename='/array/home/vlf-sftp/.ssh/id_rsa'
    
        pass_end = thispass.startdate + thispass.duration
        print 'Satellite is up. Pass begun at %s, complete at %s, (%s from now).' % \
        (thispass.startdate, pass_end, pass_end - datetime.datetime.utcnow())
        
#        yesterday = datetime.datetime.utcnow() + datetime.timedelta(-1)
#        spec_filename = 'southpole_%s.png' % (yesterday.strftime('%Y%m%d'))
        
    try:
        sp_ssh, sp_sftp = SftpConnect(ip_southpole, username_sp, key_filename) 
    except socket.error:
        print 'Unable to connect to %s' % (ip_southpole)
        return

    if b_debug:
        sc_ssh, sc_sftp = SftpConnect(ip_scott, username_scott, key_filename)

    sp_files = sp_sftp.listdir(sp_file_src_dir)
        
    if len(sp_files) == 0:
        print 'No files to sort'   
 
    # Download each file to a local temp directory, then upload it to the scott sort directory
    for file in sp_files:
        sp_filename = os.path.join(sp_file_src_dir, file)
        sp_dest_filename = os.path.join(sp_file_dest_dir, file)
        temp_filename = os.path.join(local_tempdir, file)
        
        # Download the south Pole file to local temp directory
        sp_sftp.get(sp_filename, temp_filename)
        
        # Make sure it's the right size
        sp_filesize = GetRemoteFileSize(sp_sftp, sp_filename)
        temp_filesize = GetLocalFileSize(temp_filename)
        if not sp_filesize == temp_filesize:
            raise Exception('Remote %s and temporary %s file sizes differ (%d vs %d bytes)' %\
                            (ip_southpole + ':' + sp_filename, temp_filename, sp_filesize, temp_filesize))
        
        # Upload it from the local temp directory to scott as necessary
        if b_debug:
            sc_filename = os.path.join(scott_upload_dir, file)
            sc_sftp.put(temp_filename, sc_filename)
            
        
        # Move file to "uploaded" dir on south pole computer
        sp_ssh.exec_command('mv %s %s' % (sp_filename, sp_dest_filename))
        print 'Sorted %s' % (ip_southpole + ':' + sp_filename)
        
    # Clean up
    sp_sftp.close()

    if b_debug:
        sc_sftp.close()
    
#    # The old way (using easy SSH)
#    try:
#        s = ssh.Connection('10.3.1.169', username='vlf', private_key='/home/dgolden/.ssh/id_rsa_noenc')
#    except socket.error, er:
#        print 'Unable to connect to 10.3.1.169:', er
#    else:
#        source = '/cygdrive/c/VLF_DAQ/VLFData/Spectrogram/24hour/%s' % (spec_filename)
#        dest = '/home/dgolden/temp/%s' % (spec_filename)
#        s.get(source, dest)
#        s.close()
#
#    print 'Copied southpole: %s to %s' % (source, dest)



if __name__ == '__main__':
    
    # Parse command line arguments
    from optparse import OptionParser
    parser=OptionParser()
    parser.add_option('-d', '--debug', dest='b_debug', help='Run a test on Dan\'s local machine', 
                      default=False, action='store_true')
    (options, args) = parser.parse_args()
    
    print '*** Current time is %s UTC (%s local).' % (datetime.datetime.utcnow(), datetime.datetime.now())

    if options.b_debug:
        print '*** RUNNING IN DEBUG MODE ***'
        GetFiles(None, options.b_debug)
    else:
        tdrs_text_file = 'http://www.usap.gov/USAPgov/technology/documents/cel.txt'

        # Get list of times when satellite is up
        try:
            tdrs_schedule = urllib.urlopen(tdrs_text_file)
        except IOError:
            print 'Unable to connect to %s' % (tdrs_text_file)
            exit()

        b_satellite_up = False
        
        # Loop over lines in TDRS schedule to see whether the satellite should be up right now
        # Quit when we find that we're in the middle of a pass, or when the next pass is in the future
        for line in tdrs_schedule:
            #print line,
            if line[0:2] == 'MS':
                thispass = TrdsPass(tdrs_file_line=line)
                if thispass.IsBetween(datetime.datetime.utcnow()):
                    b_satellite_up = True
                    break
                elif thispass.startdate > datetime.datetime.utcnow():
                    break
    
        # Raise exception if we got to the end of the list and all passes are already over
        if not b_satellite_up and thispass.startdate < datetime.datetime.utcnow():
            last_pass_time = thispass.startdate + thispass.duration
            raise Exception('All satellite passes are in the past; last pass ended at %s' % (last_pass_time))
    
        
        if b_satellite_up:
            GetFiles(thispass)
        else:
            time_to_next_pass = thispass.startdate - datetime.datetime.utcnow()
            print 'Satellite is not up. Next TDRS pass is at %s UTC ({%s from now).' %\
            (thispass.startdate, time_to_next_pass)
