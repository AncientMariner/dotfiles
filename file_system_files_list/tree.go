package main

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"
)

func Generate(root string, maxDepth int, showHidden bool) (string, error) {
	info, err := os.Stat(root)
	if err != nil {
		return "", fmt.Errorf("cannot access %q: %w", root, err)
	}
	if !info.IsDir() {
		return "", fmt.Errorf("%q is not a directory", root)
	}

	var sb strings.Builder
	fmt.Fprintf(&sb, "%s/\n", info.Name())
	if err := walk(&sb, root, "", maxDepth, 1, showHidden); err != nil {
		return "", err
	}
	return sb.String(), nil
}

func walk(sb *strings.Builder, dir, prefix string, maxDepth, currentDepth int, showHidden bool) error {
	if currentDepth > maxDepth {
		return nil
	}

	entries, err := os.ReadDir(dir)
	if err != nil {
		return fmt.Errorf("cannot read dir %q: %w", dir, err)
	}

	// filter hidden if needed
	if !showHidden {
		filtered := entries[:0]
		for _, e := range entries {
			if !strings.HasPrefix(e.Name(), ".") {
				filtered = append(filtered, e)
			}
		}
		entries = filtered
	}

	for i, entry := range entries {
		isLast := i == len(entries)-1

		connector := "├── "
		childPrefix := prefix + "│   "
		if isLast {
			connector = "└── "
			childPrefix = prefix + "    "
		}

		name := entry.Name()
		if entry.IsDir() {
			name += "/"
		}
		fmt.Fprintf(sb, "%s%s%s\n", prefix, connector, name)

		if entry.IsDir() {
			if err := walk(sb, filepath.Join(dir, entry.Name()), childPrefix, maxDepth, currentDepth+1, showHidden); err != nil {
				return err
			}
		}
	}
	return nil
}
