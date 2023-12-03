
*:
	zig build-exe $@ && ./$(word 1, $(subst ., ,$@))

.PHONY: *.zig

clean:
	find ./ -not -name "." -not -name "*.zig" -not -name "Makefile" -not -name ".git*" -not -type d -not -name "*.json" \
		| grep -v .git | grep -v *.md \
		| xargs rm -rf