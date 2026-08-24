.PHONY: test

test:
	nvim --headless -u tests/minimal.lua -c "PlenaryBustedDirectory tests { minimal_init = 'tests/minimal.lua' }" -c 'qa!'
