package main

import (
	"flag"
	"fmt"
	"os"
)

func main() {
	depth := flag.Int("depth", 100, "maximum depth to traverse")
	hidden := flag.Bool("hidden", false, "include hidden files and directories")
	flag.Parse()

	if flag.NArg() < 1 {
		fmt.Fprintln(os.Stderr, "usage: fstree <folder> [--depth N] [--hidden]")
		os.Exit(1)
	}

	folder := flag.Arg(0)

	output, err := Generate(folder, *depth, *hidden)
	if err != nil {
		fmt.Fprintf(os.Stderr, "error: %v\n", err)
		os.Exit(1)
	}

	if err := os.WriteFile("tree_structure.txt", []byte(output), 0644); err != nil {
		fmt.Fprintf(os.Stderr, "error writing file: %v\n", err)
		os.Exit(1)
	}

	fmt.Println("tree_structure.txt written")
}
