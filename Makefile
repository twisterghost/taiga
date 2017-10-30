build:
	crystal build src/taiga.cr

release:
	crystal build src/taiga.cr --release --no-debug
