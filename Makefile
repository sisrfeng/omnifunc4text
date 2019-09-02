autoload/text_omnicomplete_data.vim: tools/*
	python tools/generate_vimscript.py

.PHONY: clean
clean:
	rm -f autoload/text_omnicomplete_data.vim
