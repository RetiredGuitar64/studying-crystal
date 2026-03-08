package main

import (
	"fmt"
	"time"
)

func main() {
	ch := make(chan struct{}) // 等价 Channel(Nil) 的无缓冲 channel

	fmt.Println(1)

	go func() { // fibera
		fmt.Println(2)

		go func() { // fiberb
			fmt.Println(3)
			time.Sleep(1 * time.Second)
			fmt.Println(4)
		}()

		fmt.Println(5)
		<-ch // ch.receive
		fmt.Println(6)
	}()

	fmt.Println(7)
	ch <- struct{}{} // ch.send nil
	fmt.Println(8)

	// 可选：避免 main 过早退出导致 fiberb 的 4 来不及打印
	time.Sleep(2 * time.Second)
}
