bfCode = ',-->+.>>>+.<<<<[->[->+>+<<]>>[-<<+>>]>[->+>+<<]>>[-<<+>>]<<<<[->>>>>+<<<<<]>>>[->>+<<]>>.<<<<<<[-]>>>[-<<<+>>>]>>>[-<<<+>>>]<<<<<<<]';
inputs = [15];
%Code and inputs go ^
bfCodeLength = strlength(bfCode);
i = 1;
bracketData = zeros(1,bfCodeLength);
bracketDataPointer = 1;
indentationLevel = 0;
%Match brackets
while i <= bfCodeLength
    char = bfCode(i);
    if char == '['
        indentationLevel = indentationLevel + 1;
        bracketData(bracketDataPointer) = (indentationLevel);
        bracketDataPointer = bracketDataPointer + 1;
    elseif char == ']'
        x = i;
        while x > 0
            if bracketData(x) == indentationLevel
                bracketData(bracketDataPointer) = x;
                bracketDataPointer = bracketDataPointer + 1;
                break
            end
            x = x - 1;
        end
        indentationLevel = indentationLevel - 1;
    else
        bracketData(bracketDataPointer) = -2;
        bracketDataPointer = bracketDataPointer + 1;
    end
    i = i + 1;
end
%Running code
memory = zeros(1,20000);
memory_pointer = 1;
code_pointer = 1;
input_pointer = 1;
while code_pointer <= bfCodeLength
    char = bfCode(code_pointer);
    %fprintf("Current char: %c, num %d\n",char,code_pointer);
    switch char
        case "+"
            memory(memory_pointer) = memory(memory_pointer) + 1;
        case "-"
            memory(memory_pointer) = memory(memory_pointer) - 1;
        case ","
            fprintf("Taking input %d\n",inputs(input_pointer));
            memory(memory_pointer) = inputs(input_pointer);
            input_pointer = input_pointer + 1;
        case "."
            fprintf("Output: %d\n",memory(memory_pointer));
        case ">"
            memory_pointer = memory_pointer + 1;
        case "<"
            memory_pointer = memory_pointer - 1;
        case "]"
            if memory(memory_pointer) ~= 0
                code_pointer = bracketData(code_pointer);
            end
    end
    if memory_pointer > 20000
        fprintf("memory_pointer over 2000\n");
        memory_pointer = 1;
    elseif memory_pointer < 1
        memory_pointer = 20000;
        fprintf("memory_pointer less than 1\n");
    end
    code_pointer = code_pointer + 1;
end