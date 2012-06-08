
all:	build

install:	build
	$(MAKE) -C src install

build:	
	$(MAKE) -C src


clean:	
	$(MAKE) -C src clean
	$(MAKE) -C examples clean

