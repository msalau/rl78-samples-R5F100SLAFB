.PHONY: all clean check

all:

clean:

check:

define add-sample

.PHONY: $(1) $(1)-clean $(1)-check

all: $(1)

clean: $(1)-clean

check: $(1)-check

$(1):
		make -C $(1)

$(1)-clean:
		make -C $(1) clean

$(1)-check:
		make -C $(1) check
endef

$(eval $(call add-sample,00-led))
$(eval $(call add-sample,01-it))
$(eval $(call add-sample,02-uart))
