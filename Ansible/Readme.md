ansible all --key-file ~/.ssh/ansible_ed25519 -i inventory -m ping

can be simplified using ansible.cfg

ansible all -m ping
ansible all --list hosts
ansible all -m gather_facts

ansible all -m apt -a update_cache=true --become --ask-become-pass