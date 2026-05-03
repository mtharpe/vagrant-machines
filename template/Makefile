# Per-VM Makefile. Driven by ./.vmconfig (created by bin/new-machine).

.DEFAULT_GOAL := help

.PHONY: help up halt destroy ssh provision status

help:
	@echo "Targets in this VM directory:"
	@echo "  make up         vagrant up"
	@echo "  make halt       vagrant halt"
	@echo "  make destroy    vagrant destroy -f"
	@echo "  make ssh        vagrant ssh"
	@echo "  make provision  vagrant provision"
	@echo "  make status     vagrant status"

up:        ; vagrant up
halt:      ; vagrant halt
destroy:   ; vagrant destroy -f
ssh:       ; vagrant ssh
provision: ; vagrant provision
status:    ; vagrant status
