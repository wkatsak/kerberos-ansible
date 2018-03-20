# kerberos-ansible
Repository to be used with ansible-pull. It will kerberize a system. Currently supports Ubuntu 14 and 16, Centos 6 and 7, SLES 12.

You must generate and install /etc/krb5.keytab before using this.

kerberos-boot.yml must be done first. Normally it only needs to be done once.

kerberos.yml is designed to be run again every time the software changes.

There are lots of configuration options in the hosts file. There will be a script to set it up.

The kerberize script depends upon this:

User role: rutgers user add host
Privilege: Rutgers add host
System: Add Host
System: Enroll a Host
System: Manage Host Enrollment Password

Also depends upon an ACI
```
dn: cn=computers,cn=accounts,dc=cs,dc=rutgers,dc=edu
changetype: modify
add:aci
aci: (targetfilter=(objectClass=ipahost))(targetattr="managedby")
 (target="ldap:///cn=computers,cn=accounts,dc=cs,dc=rutgers,dc=edu") (version 3.0; acl "Modify Own ManagedBy";
 allow (all) (userattr="creatorsName#USERDN"); )
```

