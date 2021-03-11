SHELL = /bin/sh
PYTHON := $(shell command -v python3 2> /dev/null || \
	command -v python2 2> /dev/null || \
	echo python)

autoload/text_omnicomplete_data.vim: build.py data/*
	$(PYTHON) $<

.PHONY: clean
clean:
	rm -f autoload/text_omnicomplete_data.vim
