package main

import (
	"fmt"
	"strings"
)

func main() {
	ch := make(chan string)

	fmt.Println(strings.Repeat("1", 100))

	go func() {
		ch <- "hello"
	}()

	fmt.Println(strings.Repeat("2", 100))

	fmt.Println(<-ch) // block

	fmt.Println(strings.Repeat("3", 100))
}
