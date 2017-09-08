**Install Vmware Workstation**

TD;DR

[VMware Remote Console 10.0.1 Release Notes][] says

	Remote Console cannot be installed on the same virtual machine as
	VMware Workstation or VMware Workstation Player.

(But that really means on the same **host** machine)

<!-- markdown-toc start - Don't edit this section. Run M-x markdown-toc-generate-toc again -->
**Table of Contents**

- [Fail on my primary workstation](#fail-on-my-primary-workstation)
    - [Find error log file](#find-error-log-file)
    - [Try on other context](#try-on-other-context)
    - [Fail to guess what debian package or lib could made the difference](#fail-to-guess-what-debian-package-or-lib-could-made-the-difference)
    - [But, found an advice to remove older version of same VMware product](#but-found-an-advice-to-remove-older-version-of-same-vmware-product)
- [Remove VMware-Remote-Console and succeed to install VMware-Workstation](#remove-vmware-remote-console-and-succeed-to-install-vmware-workstation)
- [Fail to install back VMware-Remote-Console](#fail-to-install-back-vmware-remote-console)
- [Let's ensure we have the correct file](#lets-ensure-we-have-the-correct-file)
- [It won't work and it's documented !](#it-wont-work-and-its-documented-)
- [There is still some non blocking errors](#there-is-still-some-non-blocking-errors)
- [Now, maybe we can have a VM with a browser and VMware-Remote-Console](#now-maybe-we-can-have-a-vm-with-a-browser-and-vmware-remote-console)

<!-- markdown-toc end -->


# Fail on my primary workstation

Just tells `Installation failed, rolling back installation.` and exit.

## Find error log file

Nothing on stderr, but look in `/var/log/vmware-installer` 

```
[2017-09-07 21:42:13,695] [vmware-player-setup 7.1.4] Installation failed, rolling back installation.
[2017-09-07 21:42:13,732] Top level exception handler
Traceback (most recent call last):
  File "/usr/lib/vmware-installer/2.1.0/vmis/core/transaction.py", line 430, in RunThreadedTransaction
    txn.Run()
  File "/usr/lib/vmware-installer/2.1.0/vmis/core/transaction.py", line 78, in Run
    self.get()()
  File "/usr/lib/vmware-installer/2.1.0/vmis/core/common.py", line 138, in Show
    i.Execute(txn.temp, onProgress)
  File "/usr/lib/vmware-installer/2.1.0/vmis/core/install.py", line 385, in Execute
    db.files.Add(filePath, fileMtime, dest.fileType.id, uid)
  File "/usr/lib/vmware-installer/2.1.0/vmis/db.py", line 33, in decorator
    raise IntegrityError(unicode(e))
IntegrityError: column path is not unique
```

And in `File "/usr/lib/vmware-installer/2.1.0/vmis/db.py", line 33, in decorator`

```python
def wrapIntegrityError(func):
   """
   Raise our own IntegrityError to instead of SQLite's to maintain
   a consistent interface.
   """
   @wraps(func)
   def decorator(*args, **kwargs):
      try:
         return func(*args, **kwargs)
      except sqlite.IntegrityError, e:
         raise IntegrityError(unicode(e))

   return decorator
```

## Try on other context

- Succeed on a secondary workstation with quite similar `stretch` environment
- Succeed on a VitualBox VM on primary workstation (not really, but
  fail at later stage with the expected `can't install a VM from a VM`
- Succeed on a chroot on primary workstation made using
  
  Require
  
  ```bash
  sudo debootstrap stretch /tmp/stretch http://deb.debian.org/debian/
  sudo echo 'proc /tmp/stretch/proc proc defaults,noauto 0 0' | tee -a /etc/fstab
  sudo echo 'sysfs /tmp/stretch/sys sysfs defaults,noauto 0 0' | tee -a /etc/fstab
  sudo mount /tmp/stretch/proc
  sudo mount /tmp/stretch/sys
  ```

## Fail to guess what debian package or lib could made the difference

## But, found an advice to remove older version of same VMware product

I never installed VMware Workstation, but I do insalled VMware Remote
Console which is required by HTML5 VMware vSphere 6.5.

# Remove VMware-Remote-Console and succeed to install VMware-Workstation

Am I the only one to install VMware-Workstation after
VMware-Remote-Console ?

```bash
vmware-installer -l
vmware-installer -u vmware-vmrc --required
```

Then [install-vmware-workstation playbook](install-vmware-workstation.yml) will works.

# Fail to install back VMware-Remote-Console

```console
thy@tde-ws:~$ sudo bash /usr/local/dist/VMware-Remote-Console-10.0.1-5898794.x86_64.bundle --help
thy@tde-ws:~$ sudo bash /usr/local/dist/VMware-Remote-Console-10.0.1-5898794.x86_64.bundle --eulas-agreed --console --required --ignore-errors
Extracting VMware Installer...done.
Installing VMware Remote Console Setup 10.0.1
Copying files...
Rolling back VMware Remote Console Setup 10.0.1
Removing files...
Deconfiguring...
```

# Let's ensure we have the correct file

- No direct links available for `VMware-Remote-Console-10.0.1-5898794.x86_64.bundle` nor its SHA256 sum.
- Accept EULA, cut-and-paste SHA256 sum from the account restricted dowload page, make a SHA256SUMS file and checks

```console
thy@tde-ws:/usr/local/dist$ echo '03e72be96496335c46a83d9d00b9f97ee626056a526637970dde18d47ef5fb85  VMware-Remote-Console-10.0.1-5898794.x86_64.bundle' > VMware-Remote-Console-10.0.1-5898794.x86_64.bundle.SHA256SUMS
thy@tde-ws:/usr/local/dist$ shasum -a 256 -c VMware-Remote-Console-10.0.1-5898794.x86_64.bundle.SHA256SUMS
VMware-Remote-Console-10.0.1-5898794.x86_64.bundle: OK
```

# It won't work and it's documented !

But I would say, impossible to find **before** you conclude yourself
that those two VMware products may be incompatible and search for
`VMware-Remote-Console VMware-Workstation incompatible` and find
confirmation in [VMware Remote Console 9.0 Release Notes][] (we tried
to use `VMware-Remote-Console-10.0.1`, and when lookin for the exact
sentence use by VMware we also found the
correct [VMware Remote Console 10.0.1 Release Notes][])

	Remote Console cannot be installed on the same virtual machine as VMware Workstation or VMware Workstation Player.
	Workaround: None

[VMware Remote Console 9.0 Release Notes]:
	http://pubs.vmware.com/Release_Notes/en/vmrc/90/vmrc-90-release-notes.html "http://pubs.vmware.com"
[VMware Remote Console 10.0.1 Release Notes]:
	http://pubs.vmware.com/Release_Notes/en/vmrc/100/vmware-remote-console-1001-release-notes.html "http://pubs.vmware.com"

# There is still some non blocking errors

```console
thy@tde-ws:~$ vmware-installer -l
Gtk-Message: Failed to load module "atk-bridge": /usr/lib/x86_64-linux-gnu/libatspi.so.0: undefined symbol: g_type_class_adjust_private_offset
Gtk-Message: Failed to load module "canberra-gtk-module": /usr/lib/x86_64-linux-gnu/libatspi.so.0: undefined symbol: g_type_class_adjust_private_offset
Product Name         Product Version
==================== ====================
vmware-workstation   12.5.7.5813279
```

And a work around

```console
thy@tde-ws:~$ LD_LIBRARY_PATH=/usr/lib/vmware/lib/libatspi.so.0:$LD_LIBRARY_PATH vmware-installer -t
Component Name                 Component Long Name                               Component Version   
============================== ================================================= ====================
vmware-player-setup            VMware Player Setup                               12.5.7.5813279      
vmware-vmx                     VMware VMX                                        12.5.7.5813279      
vmware-vix-core                VMware VIX Core Library                           1.15.8.5813279      
vmware-network-editor          VMware Network Editor                             12.5.7.5813279      
vmware-network-editor-ui       VMware Network Editor User Interface              12.5.7.5813279      
vmware-tools-netware           VMware Tools for NetWare                          10.1.6.5813279      
vmware-tools-linuxPreGlibc25   VMware Tools for legacy Linux                     10.1.6.5813279      
vmware-tools-winPreVista       VMware Tools for Windows 2000, XP and Server 2003 10.1.6.5813279      
vmware-tools-winPre2k          VMware Tools for Windows 95, 98, Me and NT        10.1.6.5813279      
vmware-tools-freebsd           VMware Tools for FreeBSD                          10.1.6.5813279      
vmware-tools-windows           VMware Tools for Windows Vista or later           10.1.6.5813279      
vmware-tools-solaris           VMware Tools for Solaris                          10.1.6.5813279      
vmware-tools-linux             VMware Tools for Linux                            10.1.6.5813279      
vmware-player-app              VMware Player Application                         12.5.7.5813279      
vmware-workstation-server      VMware Workstation Server                         12.5.7.5813279      
vmware-ovftool                 VMware OVF Tool component for Linux               4.1.0.3634792       
vmware-vprobe                  VMware VProbes component for Linux                12.5.7.5813279      
vmware-vix-lib-Workstation1200 VMware VIX Workstation-12.0.0 Library             1.15.8.5813279      
vmware-workstation             VMware Workstation                                12.5.7.5813279      
vmware-installer               VMware Installer                                  2.1.0.5381180       
```

# Now, maybe we can have a VM with a browser and VMware-Remote-Console
