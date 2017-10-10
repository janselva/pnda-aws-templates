#!/usr/bin/env python
import subprocess
import sys
import os.path

infile = sys.argv[1]
outfile = sys.argv[2]

if not os.path.isfile(infile):
    print 'No volume mapping file found at: %s. Nothing to do.' % infile
    sys.exit(0)

print 'loading requested volumes from %s' % infile

requested_volumes = []
with open(infile) as requested_volumes_file:
    for line in requested_volumes_file:
        line = line.strip()
        if not line.startswith('#'):
            requested_volumes.append(line.split(' '))

print '\nrequested volumes:'
print requested_volumes

out = subprocess.check_output(['lsblk', '-branp', '-o', 'NAME,SIZE,MOUNTPOINT'])
available_volumes = []
for line in out.splitlines():
   fields = line.split(' ')
   available_volumes.append(fields)

available_volumes.sort(key=lambda x: int(x[1]), reverse=True)
print '\navailable volumes:'
print available_volumes

print 'writing volume mappings to %s' % outfile

with open(outfile, 'w') as volume_mappings_file:
    print '\nassignments:'
    i = 0
    available_volume_devices = [volume[i] for volume in available_volumes]
    for available_volume in available_volumes:
        if i >= len(requested_volumes):
            break
        requested_volume = requested_volumes[i]
        if (available_volume[0][-1].isdigit() or '%s%s' % (available_volume[0], 1) not in available_volume_devices) and available_volume[2] != '/':
            available_volume = [available_volume[0]]
            available_volume.extend(requested_volume)
            volume_mappings_file.write(' '.join(available_volume) + '\n')
            i += 1