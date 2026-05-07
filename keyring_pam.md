## Add keyring support to PAM.

```
sudo nano /etc/pam.d/system-login
```

Add this line near the top (after other auth lines):

```
auth optional pam_gnome_keyring.so
```

And this line at the end of the session section:

```
session optional pam_gnome_keyring.so auto_start
```
