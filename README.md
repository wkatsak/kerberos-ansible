# kerberos-ansible
Repository to be used with ansible-pull. It will kerberize a system. Currently supports Ubuntu 14 and 16, Centos 6 and 7, SLES 12.

You must generate and install /etc/krb5.keytab before using this.

kerberos-boot.yml must be done first. Normally it only needs to be done once.

kerberos.yml is designed to be run again every time the software changes.

There are lots of configuration options in the hosts file. There will be a script to set it up.

