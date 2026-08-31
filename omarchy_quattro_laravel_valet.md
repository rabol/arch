# Omarchy 4 (Quattro) — Laravel Development Environment

This guide sets up a native Laravel development environment on **Omarchy 4 / Quattro**.

It is based on a setup validated on CachyOS/Arch using:

- PHP 8.5
- PHP-FPM
- Composer
- Laravel
- Node.js / npm
- Valet Linux
- Nginx
- dnsmasq / valet-dns
- HTTPS for `*.test`
- Mailpit

Because Omarchy is Arch-based, most of the setup should transfer directly.

However, **DNS/networking must be treated carefully** because Valet modifies NetworkManager, dnsmasq and `systemd-resolved`.

---

# 1. Record the Initial System State

Before installing anything, record the Omarchy and networking state.

```bash
omarchy version
```

Check NetworkManager:

```bash
systemctl status NetworkManager --no-pager
```

Check systemd-resolved:

```bash
systemctl status systemd-resolved --no-pager
```

Check DNS:

```bash
resolvectl status
```

Also record:

```bash
cat /etc/resolv.conf
```

Keep this information.

`valet install` modifies DNS configuration, so these outputs are useful if anything goes wrong.

---

# 2. Install PHP

Use Omarchy's package command:

```bash
omarchy pkg add php
```

Check the installed PHP version:

```bash
php -v
```

The reference CachyOS installation used:

```text
PHP 8.5.9
```

---

# 3. Enable MySQL PHP Support

On Arch, `mysqli` and `pdo_mysql` are supplied by the main PHP package but may be disabled in `/etc/php/php.ini`.

Enable them:

```bash
sudo sed -i -e 's/^;extension=mysqli$/extension=mysqli/' -e 's/^;extension=pdo_mysql$/extension=pdo_mysql/' /etc/php/php.ini
```

This provides PHP support for both MySQL and MariaDB.

A database server itself is not required yet.

---

# 4. Enable Common PHP Extensions

Enable curl, iconv and SQLite support:

```bash
sudo sed -i -e 's/^;extension=curl$/extension=curl/' -e 's/^;extension=iconv$/extension=iconv/' -e 's/^;extension=pdo_sqlite$/extension=pdo_sqlite/' -e 's/^;extension=sqlite3$/extension=sqlite3/' /etc/php/php.ini
```

---

# 5. Install Additional PHP Extensions

Install GD:

```bash
omarchy pkg add php-gd
```

Install Intl:

```bash
omarchy pkg add php-intl
```

---

# 6. Optional: Install Xdebug

Install:

```bash
omarchy pkg add xdebug
```

If the standard Xdebug entry exists commented out in `/etc/php/php.ini`, enable it:

```bash
sudo sed -i 's/^;zend_extension=xdebug$/zend_extension=xdebug/' /etc/php/php.ini
```

---

# 7. Install PHP-FPM

PHP-FPM is a separate package on Arch.

Install:

```bash
omarchy pkg add php-fpm
```

Enable and start it:

```bash
sudo systemctl enable --now php-fpm.service
```

---

# 8. Install Composer

Install Composer:

```bash
omarchy pkg add composer
```

Install the Laravel installer globally:

```bash
composer global require laravel/installer
```

Determine Composer's actual global binary directory:

```bash
composer global config bin-dir --absolute
```

On the reference CachyOS system this returned:

```text
/home/<user>/.config/composer/vendor/bin
```

Do **not** assume this path.

Check your current PATH:

```bash
echo "$PATH"
```

If Composer's global bin directory is missing, add the exact directory returned by Composer to your shell configuration.

For Bash, if Composer returned the same standard path as above:

```bash
echo 'export PATH="$HOME/.config/composer/vendor/bin:$PATH"' >> ~/.bashrc
```

Then:

```bash
source ~/.bashrc
```

---

# 9. Install Development Tools

Install Node.js:

```bash
omarchy pkg add nodejs
```

Install npm:

```bash
omarchy pkg add npm
```

Install Git:

```bash
omarchy pkg add git
```

Install unzip:

```bash
omarchy pkg add unzip
```

---

# 10. Valet Linux Requirements

Valet Linux's Arch requirements include:

- nss
- jq
- xsel
- NetworkManager

Check rather than assuming:

```bash
pacman -Q nss jq xsel networkmanager
```

Install anything missing individually.

For example:

```bash
omarchy pkg add xsel
```

On the reference CachyOS installation, the first attempt at:

```bash
valet install
```

failed with:

```text
You have missing Valet dependiencies:
 - xsel
```

After installing `xsel`, Valet installation proceeded normally.

---

# 11. Install Valet Linux

The reference system used the current development branch because it contains newer Symfony 8 / Illuminate 13 dependency support.

Install:

```bash
composer global require cpriego/valet-linux:dev-master
```

Check exactly what Composer installed:

```bash
composer global show cpriego/valet-linux
```

The validated installation reported:

```text
versions : * dev-master
source   : ee039fff72e6eb52f33aef4773a1a03f359fc85d
```

Note that:

```bash
valet --version
```

still reported:

```text
Valet v2.4.5
```

even though Composer had installed `dev-master`.

Therefore use `composer global show` when determining the actual installed version.

---

# 12. Important: Record DNS State Before Installing Valet

This is especially important on Omarchy.

Check:

```bash
systemctl is-enabled systemd-resolved.service
```

Then:

```bash
systemctl is-active systemd-resolved.service
```

Check NetworkManager:

```bash
systemctl is-active NetworkManager.service
```

Record `/etc/resolv.conf`:

```bash
cat /etc/resolv.conf
```

Also:

```bash
resolvectl status
```

Keep these results.

---

# 13. Install Valet

Run:

```bash
valet install
```

On the validated CachyOS/Arch installation, the output was:

```text
[nginx] is not installed, installing it now via Pacman... 🍻
Nginx has been enabled
Stopping nginx...
PHP Logs
Installing php config
Restarting php-fpm
Restarting php-fpm...
Dnsmasq has been enabled
[inotify-tools] is not installed, installing it now via Pacman... 🍻
Installing Valet DNS service...
Valet-dns has been enabled
Systemd-resolved has been disabled
Stopping systemd-resolved...
Restarting NetworkManager...
Restarting dnsmasq...
Starting valet-dns...
Restarting nginx...

Valet installed successfully!
```

Valet therefore automatically:

- installed Nginx
- enabled Nginx
- configured PHP
- restarted PHP-FPM
- configured dnsmasq
- installed `inotify-tools`
- installed `valet-dns`
- disabled `systemd-resolved`
- restarted NetworkManager
- restarted dnsmasq
- started `valet-dns`
- restarted Nginx

---

# 14. Omarchy DNS Checkpoint

This is the most important Omarchy-specific validation point.

Immediately after `valet install`, verify normal DNS:

```bash
getent hosts archlinux.org
```

Check NetworkManager:

```bash
systemctl status NetworkManager --no-pager
```

Check dnsmasq:

```bash
systemctl status dnsmasq --no-pager
```

Check valet-dns:

```bash
systemctl status valet-dns --no-pager
```

If DNS is broken, **do not start applying random DNS fixes**.

Compare the current state against the information recorded before `valet install`.

---

# 15. Create the Laravel Projects Directory

The project directory will be:

```text
~/code/web
```

Create it:

```bash
mkdir -p ~/code/web
```

Enter it and tell Valet to park the directory:

```bash
cd ~/code/web && valet park
```

Every directory below `~/code/web` should now automatically receive a `.test` domain.

For example:

```text
~/code/web/test
```

becomes:

```text
http://test.test
```

---

# 16. Create a Test Laravel Project

Enter the projects directory:

```bash
cd ~/code/web
```

Create a Laravel application:

```bash
laravel new test
```

Open:

```text
http://test.test
```

If that works, the complete chain is functioning:

```text
Omarchy
    ↓
NetworkManager / Valet DNS
    ↓
Nginx
    ↓
PHP-FPM
    ↓
Laravel
    ↓
test.test
```

---

# 17. Enable HTTPS

Enter the project:

```bash
cd ~/code/web/test
```

Secure it:

```bash
valet secure
```

Open:

```text
https://test.test
```

---

# 18. Firefox Certificate Trust

Valet may generate the certificate correctly while Firefox still refuses to trust the Valet CA.

Valet's CA is normally stored under:

```text
~/.valet/CA/
```

The relevant certificate is:

```text
~/.valet/CA/LaravelValetCASelfSigned.pem
```

## Do Not Assume the Firefox Profile Path

On the validated CachyOS installation, Firefox did **not** use:

```text
~/.mozilla/firefox
```

Instead it used:

```text
~/.config/mozilla/firefox
```

Find the real location:

```bash
find ~ -maxdepth 5 -type f -name profiles.ini -path '*firefox*' -print 2>/dev/null
```

Inspect the returned `profiles.ini`.

Also inspect the corresponding:

```text
installs.ini
```

to determine which profile the installed Firefox instance actually uses.

---

# 19. Verify certutil

Check:

```bash
command -v certutil
```

The validated system returned:

```text
/usr/bin/certutil
```

---

# 20. Import the Valet CA into Firefox

After determining the **actual Firefox profile directory**, import the CA:

```bash
certutil -A -n "Laravel Valet CA" -t "C,," -i ~/.valet/CA/LaravelValetCASelfSigned.pem -d sql:/ACTUAL/FIREFOX/PROFILE/PATH
```

Do not copy a profile path from another machine.

Verify:

```bash
certutil -L -d sql:/ACTUAL/FIREFOX/PROFILE/PATH | grep "Laravel Valet CA"
```

Expected:

```text
Laravel Valet CA                                             C,,
```

Completely close Firefox and reopen it.

Then:

```text
https://test.test
```

should be trusted.

---

# 21. Install Mailpit

Use Mailpit's official static binary installer:

```bash
sudo sh < <(curl -sL https://raw.githubusercontent.com/axllent/mailpit/develop/install.sh)
```

On the validated system this installed Mailpit to:

```text
/usr/local/bin/mailpit
```

The installed version at the time of testing was:

```text
Mailpit v1.31.0
```

---

# 22. Create the Mailpit Data Directory

```bash
mkdir -p ~/.local/share/mailpit
```

---

# 23. Create the Mailpit systemd Service

Create:

```bash
sudo nano /etc/systemd/system/mailpit.service
```

Use:

```ini
[Unit]
Description=Mailpit local mail testing server
After=network.target

[Service]
Type=simple
User=<user>
ExecStart=/usr/local/bin/mailpit --database /home/<user>/.local/share/mailpit/mailpit.db --smtp 127.0.0.1:1025 --listen 127.0.0.1:8025
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
```

Replace `<user>` with the actual Linux username.

---

# 24. Enable Mailpit

Reload systemd and enable Mailpit:

```bash
sudo systemctl daemon-reload && sudo systemctl enable --now mailpit.service
```

Check:

```bash
systemctl status mailpit.service --no-pager
```

Expected listeners:

```text
SMTP  127.0.0.1:1025
HTTP  127.0.0.1:8025
```

Mailpit is deliberately bound to localhost.

Therefore **no inbound firewall rule is required**.

---

# 25. Expose Mailpit Through Valet

Valet supports reverse proxies.

Create a secure proxy:

```bash
valet proxy mailpit http://127.0.0.1:8025 --secure
```

Mailpit should now be available at:

```text
https://mailpit.test
```

This gives a much cleaner local-development URL while Mailpit itself remains bound to localhost.

---

# 26. Configure Laravel for Mailpit

Use the following in Laravel's `.env`:

```dotenv
MAIL_MAILER=smtp
MAIL_HOST=127.0.0.1
MAIL_PORT=1025
MAIL_USERNAME=null
MAIL_PASSWORD=null
MAIL_ENCRYPTION=null
```

---

# 27. MariaDB / MySQL

Valet Linux does **not** install MariaDB or MySQL.

That is intentional.

Install a database server separately when one is actually required.

PHP already has:

```text
mysqli
pdo_mysql
```

enabled, so Laravel will be ready to connect to MySQL/MariaDB.

---

# 28. Optional PHPMD

Install a current PHPMD version:

```bash
composer require --dev phpmd/phpmd:^2.15 -W
```

Do not use the ancient PHPMD 2.5/PDepend 2.2 combination with a modern Symfony environment.

The following Laravel/Livewire-friendly `phpmd.xml` worked successfully:

```xml
<?xml version="1.0"?>
<ruleset name="Laravel PHPMD"
         xmlns="http://pmd.sf.net/ruleset/1.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://pmd.sf.net/ruleset/1.0.0
                             https://pmd.sourceforge.io/ruleset_xml_schema.xsd">

    <description>
        PHPMD ruleset tuned for Laravel and Livewire applications.
    </description>

    <rule ref="rulesets/cleancode.xml">
        <exclude name="StaticAccess"/>
    </rule>

    <rule ref="rulesets/codesize.xml">
        <exclude name="TooManyFields"/>
        <exclude name="TooManyPublicMethods"/>
    </rule>

    <rule ref="rulesets/design.xml"/>

    <rule ref="rulesets/naming.xml">
        <exclude name="LongVariable"/>
    </rule>

    <rule ref="rulesets/unusedcode.xml"/>

</ruleset>
```

Run PHPMD with:

```bash
./vendor/bin/phpmd app text phpmd.xml
```

---

# 29. Firewall Note: LocalSend

This is unrelated to Laravel/Valet but was discovered during the reference CachyOS installation.

LocalSend listened on:

```text
TCP 53317
UDP 53317
```

With UFW configured as default-deny inbound, LocalSend did not work.

On the reference LAN (`10.17.8.0/24`) this fixed it:

```bash
sudo ufw allow from 10.17.8.0/24 to any port 53317
```

Do **not** copy that subnet blindly.

Determine the actual LAN subnet first.

---

# 30. Potential Valet Linux PR: System Readiness Check

During installation it became clear that Valet Linux would benefit significantly from a non-destructive system check.

For example:

```text
valet doctor
```

or:

```text
valet check
```

It should inspect:

- Linux distribution
- Arch derivative compatibility
- PHP version
- required PHP extensions
- PHP-FPM package
- PHP-FPM service
- PHP-FPM socket
- Composer
- Composer global bin path
- whether Composer bin is in PATH
- nss
- jq
- xsel
- NetworkManager
- dnsmasq
- Nginx
- ports 80 and 443
- systemd-resolved
- `/etc/resolv.conf`
- valet-dns
- Valet CA
- browser certificate trust
- Firefox NSS database
- required permissions

Output should ideally look like:

```text
PASS  PHP 8.5.9
PASS  PHP-FPM
PASS  Composer
FAIL  xsel not installed
WARN  systemd-resolved currently active
PASS  NetworkManager
WARN  Valet CA not trusted by Firefox
```

The command should **not modify the system**.

One concrete inconsistency already observed:

`xsel` was treated as a fatal prerequisite:

```text
You have missing Valet dependiencies:
 - xsel
```

while Nginx and `inotify-tools` were automatically installed by `valet install`.

A readiness command could expose this before making any system changes.

---

# 31. Main Omarchy-Specific Risk: DNS

This is the part of the guide that has **not yet been validated on an actual Omarchy 4 machine**.

Omarchy 4 Quattro is Arch-based and uses NetworkManager.

Valet Linux:

- configures dnsmasq
- integrates with NetworkManager
- may disable `systemd-resolved`
- installs `valet-dns`

Therefore do not assume the successful CachyOS DNS behavior proves Omarchy will behave identically.

Before `valet install`, preserve:

```bash
systemctl status NetworkManager --no-pager
```

```bash
systemctl status systemd-resolved --no-pager
```

```bash
resolvectl status
```

```bash
cat /etc/resolv.conf
```

After `valet install`, verify DNS immediately.

If there is a problem, compare the before/after state rather than


# Install SQLite

Install SQLite itself:

omarchy pkg add sqlite

PHP's SQLite extensions should already have been enabled earlier:

extension=pdo_sqlite
extension=sqlite3

This provides both the sqlite3 command-line client and PHP/Laravel SQLite support.


# Install MariaDB

Install MariaDB:

omarchy pkg add mariadb

Do not start MariaDB yet.

Before the first start, check the installation information from the installed MariaDB package and use the initialization procedure documented for the current Arch/Omarchy package. Do not assume an initialization command from Ubuntu, Debian, or an older Arch release.

After the data directory has been initialized, MariaDB can be enabled and started.

PHP's MySQL/MariaDB extensions should already have been enabled earlier:

extension=mysqli
extension=pdo_mysql

Laravel can then use MariaDB through the normal mysql database driver.
