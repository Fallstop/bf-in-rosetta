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
	fmt.Println("Parsing: ", source)
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
	fmt.Print("Parsed source code: ")
	for _, token := range list {
		fmt.Print(token_index[token])
	}

	fmt.Print("\n")

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

func parseCsv(input string) []uint8 {
	var numbers []uint8
	var str string
	for _, token := range input{
		if token < 57 && token > 47 {
			str += string(token)
		} else if token == ',' {
			if len(str) > 0 {
				i, _ := strconv.ParseUint(str, 0, 8)
				numbers = append(numbers, uint8(i))
			}
			str = ""
		}
	}

	if len(str) > 0 {
		i, _ := strconv.ParseUint(str, 0, 8)
		numbers = append(numbers, uint8(i))
	}

	fmt.Print("Parsed: ")
	for _, token := range numbers {
		fmt.Print(token)
	}
	fmt.Println()

	return numbers
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

func executeCsv(source string, inputs string) {
	src := parse(source)
	csv := parseCsv(inputs)
	inputPointer := 0
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
			if inputPointer < len(csv) {
				memory[memoryPointer] = csv[inputPointer]
				inputPointer++;
			} else {
				fmt.Println("Error: not enough inputs supplied in csv, falling back to on-demand input")
				memory[memoryPointer] = input()
			}
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
	} else {
		inputs := openFile(args[1])
		executeCsv(file, inputs)
	}
}
