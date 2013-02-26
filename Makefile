COMPONENT = node_modules/component/bin/component

.PHONY: clean test

all: build build/repos/gitweb.js build/repos/gitweb.css

build: components
	$(COMPONENT) build

build/repos/gitweb.%: gitweb-theme/gitweb.% build/build.% public/gitweb.%
	mkdir -p build/repos
	cat $^ > $@

components: component.json
	$(COMPONENT) install -f

clean: 
	rm -Rf components build
