#!/bin/sh
# Enforces Terraform file naming standards
# Files must be named with the matching prefix, using . as the separator.
# e.g. output blocks may only appear in outputs.tf, outputs.networking.tf, etc.

FAILED=0

# check LABEL BLOCK_PATTERN VALID_FILE_PATTERN
#   LABEL            - human-readable name used in error messages
#   BLOCK_PATTERN    - grep regex matching the opening line of the block type
#   VALID_FILE_PATTERN - grep regex for file paths that are allowed to contain the block
check() {
    LABEL="$1"
    PATTERN="$2"
    VALID_GREP="$3"

    # Find all .tf files containing the block type, excluding valid filenames and .terraform cache
    VIOLATIONS=$(grep -rl "$PATTERN" . --include="*.tf" \
        | grep -v "$VALID_GREP" \
        | grep -v '/\.terraform/')

    if [ -n "$VIOLATIONS" ]; then
        echo "$LABEL must be defined in $LABEL files. Found in:"
        printf '%s\n' "$VIOLATIONS" | sed 's|^\./||' | sed 's/^/  /'
        FAILED=1
    fi
}

# [^/-] ensures only . is used as a separator, not -
check "data"          '^data "'      '/data[^/-]*\.tf$'
check "outputs"       '^output "'    '/outputs[^/-]*\.tf$'
check "locals"        '^locals {'    '/locals[^/-]*\.tf$'
check "variables"     '^variable "'  '/variables[^/-]*\.tf$'
check "resources"     '^resource "'  '/main[^/-]*\.tf$'
check "modules"       '^module "'    '/main[^/-]*\.tf$'

exit $FAILED
