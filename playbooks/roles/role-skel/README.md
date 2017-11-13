# role-skel
This role serves as a skeleton which you can duplicate and then modify for the creation of new Ansible roles.

## How To Use
1. Duplicate `role-skel` and name the new directory after your new role (i.e. gitlab)
2. Modify/add/remove the role sub-directories and files to suit your new role
3. Create a new playbook to call your role in the root of the `playbooks` directory
4. Include your new playbook in the `main.yml` file in the root of the `playbooks` directory
5. Double-check and remove any `empty` files that remain in non-empty sub-directories
6. Update this README to describe your role as well as provide instructions for use
