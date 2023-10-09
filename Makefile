
*:
	zig build-exe $@ && ./$(word 1, $(subst ., ,$@))

.PHONY: *.zig

clean:
	find ./ -not -name "." -not -name "*.zig" -not -name "Makefile" \
		| xargs rm -rf