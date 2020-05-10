package main

import (
	"bufio"
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"strconv"
)

const (
	INC = 0
	DEC = 1
	IN  = 2
	OUT = 3
	SLF = 4
	SRT = 5
	SJP = 6
	JNZ = 7
)

var token_index = [...]string{"+", "-", ".", ",", "<", ">", "[", "]"}

func parse(source string) []int {
	var list []int
	for _, char := range source {
		switch char {
		case '+':
			list = append(list, INC)
			break
		case '-':
			list = append(list, DEC)
			break
		case ',':
			list = append(list, IN)
			break
		case '.':
			list = append(list, OUT)
			break
		case '<':
			list = append(list, SLF)
			break
		case '>':
			list = append(list, SRT)
			break
		case '[':
			list = append(list, SJP)
			break
		case ']':
			list = append(list, JNZ)
			break
		default:
			break
		}
	}
	return list
}

func openFile(source string) string{
	file, err := os.Open(source)
	if err != nil {
		log.Fatal(err)
	}
	defer file.Close()


	b, err := ioutil.ReadAll(file)
	return string(b)
}

func input() uint8 {
	fmt.Print(">>> ")
	reader := bufio.NewReader(os.Stdin)
	var str string
	str, _ = reader.ReadString('\n')
	strs := len(str)
	if strs > 0 && str[strs-1] == '\n' {
		str = str[:strs - 1]
	}
	i1, err := strconv.ParseUint(str, 0, 8)
	if err != nil {
		fmt.Println("Invalid input, ", err, " please try again.")
		return input()
	}
	return uint8(i1)
}

func execute(source string) {
	src := parse(source)
	memoryPointer := 0
	const memorySize = 30000
	var memory [memorySize]uint8
	codePointer := 0
	var braces []int
	for codePointer < len(src) {
		switch src[codePointer] {
		case INC:
			memory[memoryPointer]++
			break
		case DEC:
			memory[memoryPointer]--
			break
		case IN:
			memory[memoryPointer] = input()
			break
		case OUT:
			fmt.Println(memory[memoryPointer])
			break
		case SLF:
			memoryPointer--
			if memoryPointer < 0 {
				memoryPointer = memorySize - 1
			}
		case SRT:
			memoryPointer++
			if memoryPointer > memorySize {
				memoryPointer = 0
			}
		case SJP:
			braces = append(braces, codePointer - 1)
			break
		case JNZ:
			if memory[memoryPointer] != 0 {
				n := len(braces) - 1
				codePointer = braces[n]
				braces[n] = 0
				braces = braces[:n]
			} else {
				n := len(braces) - 1
				braces = braces[:n]
			}
		}
		codePointer++
	}
}

func main() {
	var args = os.Args[1:]
	if len(args) < 1 {
		log.Fatal("Error: expected at least 1 argument got none\nUsage: bf [source_file] <csv_file>")
	}

	file := openFile(args[0])

	if len(args) == 1 {
		execute(file)
	}
}
