# Ansible
This repository serves as our configuration management repository. In order to keep things in order and maintain consistency, there are some conventions which should be followed.

## Conventions
1. __Keep this repository client-agnostic.__ Do not include any environment or client-specific information in this repository. Store all of your environment and client-specific information in the appropriate inventory repository. This allows us to utilize this code-repository across multiple clients, projects and initiatives.
2. __Write your Ansible roles and playbooks to be idempotent.__ This means that when you run your Ansible multiple times in succession it will not perform any unnecessary actions repeatedly (0 changes).
3. __Always test your Ansible in Vagrant__ or a disposable environment before issuing a merge request, or merging your branch into master. This ensures that we are not "developing in production" and gives us stability and reliability across our production systems.
4. __Use feature branching when pushing.__ When you push to the Ansible source repository, push your changes to a feature branch, i.e. `gitlab` and then issue a merge request when you are ready to have your code merged. This allows at least 2 sets of eyes on everything that gets added to the Ansible code base.
5. __Always tag your role tasks with the name of the role.__ This allows fine-grained targeting of systems with specific roles and playbooks.
6. __Never target production systems__ from your local machine, Vagrant or any non-assigned Ansible control nodes or from the command line of a control node. This helps us to ensure that all actions taken against production systems are logged/audited properly; as we orchestrate the execution of Ansible from tools which retain the logs and activities of Ansible.
7. __Give each task a unique name__ so that the Ansible execution output is easier to read by humans. Uniqueness of the task name simplifies troubleshooting.
8. __Never use `ignore_errors`__ unless you absolutely have to.
9. __Avoid using bare `shell`__ module as it is always non-idempotent.
10. __Add padding to your variables.__ For example, `{{hard_to_read}}` and `{{ easier_to_read }}`.
11. __Use Pascal Case for boolean.__ Instead of `true` use `True`.

# Ansible Config Tree
 - `inventory-vagrant/`                -- Directory of static inventory files and variable files for `Vagrant`
 - `inventory-vagrant/group_vars/`     -- Group variables
 - `inventory-vagrant/inventory/`      -- Directory of static inventory files for `Vagrant`
 - `library/`                          -- Custom `Ansible modules`
 - `playbooks/`                        -- Recipes for configuration and appropriate related actions
 - `playbooks/roles/`                  -- Roles and modules under them for which we act upon within Ansible
 - `.gitignore`                        -- Git ignore file.
 - `ansible.cfg`                       -- Ansible program configuration variables.
                                       -- This file should not be modified under most circumstances.
 - `README.md`                         -- This file.
 - `site.yml`                          -- Global cookbook for all recipes to be played automatically.
 - `Vagrantfile`                       -- Specification file for Vagrant.

# How-To

## Example (dev)
1. Execute `ansible-playbook site.yml -e "env=dev"` from the Ansible control node to run Ansible against `dev` environment

## Global Variables
 - `env`  -- Host environment to target
 - Check Ansible documentation for additional global variables

## HostType and env Definition
The combination of __HostType__ and __env__ is an internal organization scheme that I have developed by utilizing the flexibility of Ansible in order to assist the grouping of hosts together as well as targeting Ansible playbook execution to a limited scope of hosts. This allows us to run the same `site.yml` playbook every time, however we can granularly target hosts all the way down to specific tasks if desired. The result of this is much easier automation of Ansible playbook executions as well as removing the burden of needing to know which exact playbook you need to run to perform your desired actions against the infrastructure.

__HostType__ refers to the playbook that you want executed against that host each and every time Ansible is targeted against that host. (i.e. `HostType-gitlab`)

__env__ refers to the environment in which you want to target.

The way it works is, when Ansible executes it creates an intersection between those 2 host groups (`HostType` and `env`) and only executes playbooks where that intersection occurs. For example, if you wanted to install Gitlab on a host in `dev` you would simply add your host (i.e. `dev1.example.com 10.10.10.10`) to the following host groups in Ansible inventory: `gitlab` and `dev`. From there you could execute Ansible using the following command: `ansible-playbook site.yml -e "env=dev" -t "gitlab"` and the result would be that Ansible would install Gitlab on the `dev1.example.com` host in the `dev` environment, as well as any other hosts which are defined both in the `gitlab` and `dev` host groups simultaneously.

## Create New Roles and Playbooks
### Please follow these instructions to create your new playbooks:
1. Create a new playbook in `playbooks` prefixed with one of the following prefixes:
   1. `HostType-` for standard playbooks (i.e. `HostType-app_deploy.yml`)
      1. Use the example playbook provided `playbooks/HostType-app_deploy.yml`
2. Structure your playbook content like the following example:
   1. For standard playbooks:
      ```
      ---
      - name: Ansible HostType app_deploy Play
        hosts: "{{ env }}:&app_deploy"
        become: True
        roles:
          - app_deploy
      ```
3. Include your new playbook at the end of `playbooks/main.yml`
* `- include: HostType-gitlab.yml`
4. Duplicate the `playbooks/roles/role-skel` directory and follow the instructions in `playbooks/roles/role-skel/README.md` to create your role

# Vagrant

## Run Ansible inside Vagrant
1. Install Virtualbox (https://www.virtualbox.org/wiki/Downloads) and Vagrant (https://www.vagrantup.com/)
2. Inside the root of the repository, on your command line, type: `vagrant up` to bring up the Vagrant machine
3. After the Vagrant machine comes up, type: `vagrant ssh` to ssh into the Vagrant machine
4. Run the following command inside the Vagrant machine: `cd /vagrant; ansible-playbook site.yml -e "env=vagrant"` to execute Ansible. You can execute this command each time you want to test your changes. You may also run Ansible in "check mode" by adding the `--check` parameter to the end, like so: `cd /vagrant; ansible-playbook site.yml -e "env=vagrant" --check`
5. You can modify the `Vagrantfile` inside the repository to add any additional ports you need forwarded, after doing so you must reload your Vagrant machine (`vagrant reload`) to pick up the new changes. Please see the Vagrant docs for further information

__Uncomment `vagrant` in the inventory file (inventory-vagrant/inventory/vagrant) under any product you'd like to install__

# Hepful Tips
- Add `-vvvv` to your Ansible execution to get extremely verbose output
- You are able to store your custom roles (for testing purposes) in `/etc/ansible/roles` and they will be automatically picked up (if you don't want to commit them to the repository)
