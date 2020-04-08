SHELL:=bash

md_file_list.md: FORCE
	find . -name "*.md" >$@

FORCE:
