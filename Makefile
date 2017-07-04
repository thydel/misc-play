top:; @date

SHELL := bash

# strange bug in 2.3 remove role name from file name
all   := (source ~/usr/ext/ansible-stable-2.2/hacking/env-setup -q;
all   +=  ansible-galaxy install -r requirements.yml)
role   = ansible-galaxy remove $@;
role  += $(all)
roles := regenerate-host-keys

all:; $($@)
$(roles):; $(role)
.Phony: all $(roles)
