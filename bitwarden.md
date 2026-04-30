## Bitwarden
Bitwarden is a great password manager.
Wnen installin on Arch linux, one can choose different keyring, and to avoid key in you password way to many times you can modify your ```/etc/pam.d/system-login``` file and add theses two lines

# Under the auth section
```bash
auth       optional   pam_gnome_keyring.so
```

# Under the session section
```bash
session    optional   pam_gnome_keyring.so auto_start
```


Then you will have the option to store the password for your keyring so you do not need to enterit so opten.

NOTE: This might be a sequrity risk!
