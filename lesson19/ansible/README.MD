# Playbooks

## Configure SFTP server

- ansible-galaxy install johanmeiring.sftp-server,v2.6.0
- ansible-playbook -i azure_rm.yml --limit tb-ftp-vmLinux-0_7833 playbook.yml