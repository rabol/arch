## NAS shares

if you have a NAS and some shares

Make a mount point
```bash
sudo mkdir -p /home/<user_name>/shares/{sharename_1,sharename_2}
``` 

Create a credentials file

```bash
nano ~/.smb-credentials
```

add this:

```
username=youruser
password=yourpassword
```

Save and then lock it down:

``` 
sudo chmod 600 /root/.smb-credentials
```


Then make the mounts permananet 


```bash
sudo nano /etc/fstab
``` 


``` 
//server/<share_name>  /home/<user_name>/shares/authorizedoc  cifs  _netdev,credentials=/home/<user_name>/.smb-credentials,iocharset=utf8,vers=3.0,uid=1000,gid=1000,file_mode=0644,dir_mode=0755  0  0
//server/<share_name>  /home/<user_name>/shares/authorizedoc  cifs  _netdev,credentials=/home/<user_name>/.smb-credentials,iocharset=utf8,vers=3.0,uid=1000,gid=1000,file_mode=0644,dir_mode=0755  0  0
....
```
