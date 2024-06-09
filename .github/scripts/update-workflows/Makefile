.PHONY: all
all: clean generate

.PHONY: clean
clean:
	rm -rf generated/

.PHONY: generate
generate:
	go run main.go

.PHONY: copy
copy:
	cp generated/*.yml ../../workflows/
