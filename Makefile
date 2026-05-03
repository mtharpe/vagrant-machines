# Top-level dispatcher. Auto-selects mac/ on Darwin (M-series) and linux/ elsewhere.
# Override with: `make PLATFORM=linux <target>` or `make -C mac <target>`.

UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Darwin)
  PLATFORM ?= mac
else
  PLATFORM ?= linux
endif

PLATFORM_DIR := $(PLATFORM)

.DEFAULT_GOAL := help

.PHONY: help
help:
	@echo "Top-level dispatcher (current platform: $(PLATFORM))"
	@echo ""
	@echo "Run targets against the platform dir directly, e.g.:"
	@echo "  make -C $(PLATFORM_DIR) help"
	@echo "  make -C $(PLATFORM_DIR) install"
	@echo "  make -C $(PLATFORM_DIR) vm name=myvm box=... role=server family=apt"
	@echo ""
	@echo "Or use this dispatcher (forwards to ./$(PLATFORM_DIR)/Makefile):"
	@echo "  make install"
	@echo "  make plugins"
	@echo "  make check"
	@echo "  make validate"
	@echo "  make clean"
	@echo "  make vm name=... box=... role=... family=..."
	@echo ""
	@echo "Force a platform:"
	@echo "  make PLATFORM=linux install"

# Forward common targets to the selected platform.
.PHONY: check install update box-add validate validate-soft plugins clean vm vm-root vm-migrate links
check install update box-add validate validate-soft plugins clean vm vm-root vm-migrate links:
	$(MAKE) -C $(PLATFORM_DIR) $@ \
		$(if $(name),name=$(name)) \
		$(if $(box),box=$(box)) \
		$(if $(box_publisher),box_publisher=$(box_publisher)) \
		$(if $(box_name),box_name=$(box_name)) \
		$(if $(provider),provider=$(provider)) \
		$(if $(family),family=$(family)) \
		$(if $(role),role=$(role)) \
		$(if $(playbook),playbook=$(playbook)) \
		$(if $(vm_root),vm_root=$(vm_root)) \
		$(if $(BOXES),BOXES='$(BOXES)')
