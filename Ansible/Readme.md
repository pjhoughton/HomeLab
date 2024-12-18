
# Full syntax to run ansible command

ansible all --key-file ~/.ssh/ansible_ed25519 -i inventory -m ping

# Can be simplified  to the following using ansible.cfg

ansible all -m ping   

 
# Other simple commands

ansible all --list hosts
ansible all -m gather_facts

# What if you need to elevate the command thats where --become command is used:

# installs atitude on a servers asking for sudo password 

ansible all -m apt -a name=aptitude --become --ask-become-pass

# Updates snapd asking  sudo password 

ansible all -m apt -a "name=snapd state=latest" --become --ask-become-pass

