#!/usr/bin/env zsh

keychain \
	--agents gpg,ssh \
	--inherit any \
	--eval \
	--quick \
	--systemd \
	--quiet \
	id_rsa \
	63CC496475267693
