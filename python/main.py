import sys
import re
#Preprocess inputs and code
fileName = sys.argv[1]
args = sys.argv[2:]
inputs = []
for i in args:
    try:
        inputs.append(int(i))
    except:
        print("Non interger input was givin")
print("Inputs:", inputs)
try:
    BfFile = open(fileName,"r")
    bfRawCode = BfFile.read()
    bfStrCode = re.findall("[\[\]<>+-.,,]",bfRawCode)
    bfCode = [x for x in bfStrCode]
except Exception as e:
    print()
    raise NameError("File {} could not be read, error: \n {}".format(fileName, e))

print("BF code after processing", bfCode)

#Logic for matching the loops

nestedLevel = 0
breaketLeft = []
bracketCompleate = []

i = 0
while i < len(bfCode):
    if bfCode[i] == "[":
        nestedLevel+=1
        breaketLeft.append([nestedLevel,i])
        bracketCompleate.append(i)
    elif bfCode[i] == "]":
        x = len(breaketLeft)-1
        while x >= 0:
            if breaketLeft[x][0] == nestedLevel:
                bracketCompleate.append(breaketLeft[x][1])
                break
            x-=1
        nestedLevel-=1
    else:
        bracketCompleate.append(0)
    i+=1
    
#Run BF
print("Running Code")
codePointer = 0
inputPointer = 0
memoryPointer = 0
memory = [0] * 30000
while codePointer < len(bfCode):
    codeScanCharter = bfCode[codePointer]
    
    if codeScanCharter == '<':
        memoryPointer-=1
    elif codeScanCharter == '>':
        memoryPointer+=1
    elif codeScanCharter == ',':
        memory[memoryPointer] = inputs[inputPointer]
        inputPointer +=1
    elif codeScanCharter == '.':
        print(memory[memoryPointer])
    elif codeScanCharter == '+':
        memory[memoryPointer] += 1
    elif codeScanCharter == '-':
        memory[memoryPointer] -= 1
    elif codeScanCharter == ']':
        if memory[memoryPointer] != 0:
            codePointer = bracketCompleate[codePointer]
        
    codePointer +=1
