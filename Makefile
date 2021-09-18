project: clean
	mkdir project
	cp tests/* project
	cp vhdl/* project
	cp examples/* project
	cp -r altera/* project

clean:
	rm -rf project
