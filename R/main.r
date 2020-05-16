"Input your filenames here"
codeFileName = "testCode.bf"
inputsFileName = "testInputs.csv"
plotOutputs = FALSE
"That's all you need to modify"
# Load readtext package
library(readtext)
codeRaw = readtext(codeFileName, text_field = "plaintext")[,2]
codeRawLength = nchar(codeRaw)
inputsCSV = read.csv(inputsFileName, header=FALSE)
print(getwd())
print("CodeRaw:")
print(codeRaw)
print("CodeRawLength:")
print(codeRawLength)
print("InputsRaw:")
print(inputsCSV)

"Process code"
code <- character()
for (i in 1:codeRawLength) {
    char <- substring(codeRaw,i,i)
    if ( char == "<" | char == ">" | char == "-" | char == "+" | char == "," | char == "." | char == "[" | char == "]") {
        code <- c(code,char)   
    }
}
print(code)


"Match Brackets"
bracketList <- character(length(code))
nestedLevel <- 0
i <- 1
while (i <= length(code)) {
    if (code[i] == "[") {
        nestedLevel <- nestedLevel + 1
        bracketList[i] <- nestedLevel
    } else if (code[i] == "]") {
        x <- i
        while (x >= 1) {
            if (bracketList[x] == nestedLevel) {
                bracketList[i] <- x
                print("Found Match")
                break
            }
            x <- x - 1
        }
        nestedLevel <- nestedLevel - 1
    }
    else {
        bracketList[i] <- -1
    }
    i <- i+1
}
print("Bracket Matching")
print(bracketList)

"Run code"
print("Running BF code")
code_pointer <- 1
memory <- rep(0,20000)
memory_pointer <- 1
input_pointer <- 1
outputs <- character()

while (code_pointer <= length(code)) {
    char <- code[code_pointer]
    #print(paste("Excuting: ",char))
    if (char == "<") {
        memory_pointer <- memory_pointer-1
    } else if (char == ">") {
        memory_pointer <- memory_pointer+1
    } else if (char == "+") {
        memory[memory_pointer] <- memory[memory_pointer] + 1
    } else if (char == "-") {
        memory[memory_pointer] <- memory[memory_pointer] - 1
    } else if (char == ",") {
        memory[memory_pointer] <- strtoi(inputsCSV[input_pointer])
        input_pointer <- input_pointer
    } else if (char == ".") {
        outputs <- append(outputs,memory[memory_pointer])
        print(memory[memory_pointer])
    } else if (char == "]") {
        if (memory[memory_pointer] != 0) {
            code_pointer = strtoi(bracketList[code_pointer])
        }
    }
    code_pointer <- code_pointer+1
}
if (plotOutputs == True) {
    par(pch=22, col="red")
    outputNum = c(1:length(outputs))
    heading="BF outputs"
    plot(outputNum, outputs, main=heading)
    lines(outputNum, outputs, type="l")
}