COMPONENT = node_modules/component/bin/component

.PHONY: clean test

all: build build/gitweb.js build/gitweb.css

build: components
	$(COMPONENT) build

build/gitweb.%: gitweb-theme/gitweb.% build/build.% public/gitweb.%
	cat $^ > $@

components: component.json
	$(COMPONENT) install -f

clean: 
	rm -Rf components build
