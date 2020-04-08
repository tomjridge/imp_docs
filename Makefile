SHELL:=bash

index.md: FORCE
	find . -name "*.md" >index.md

FORCE:
