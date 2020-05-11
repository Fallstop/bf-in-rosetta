import * as process from "process";
import * as fs from 'fs';

const tokenIndex = ["+", "-", ",", ".", "<", ">", "[", "]"];

enum BrainFuck {
    INC = 0,
    DEC = 1,
    IN  = 2,
    OUT = 3,
    SLF = 4,
    SRT = 5,
    SJP = 6,
    JNZ = 7
}

const parse = function (source: String): Array<BrainFuck> {
    console.log(`Parsing: ${source}`);
    let tokens = new Array<BrainFuck>();
    // @ts-ignore
    const char = [...source];
    char.forEach(char => {
        switch (char) {
            case "+":
                tokens.push(BrainFuck.INC);
                break;
            case "-":
                tokens.push(BrainFuck.DEC);
                break;
            case ">":
                tokens.push(BrainFuck.SRT);
                break;
            case "<":
                tokens.push(BrainFuck.SLF);
                break;
            case ".":
                tokens.push(BrainFuck.OUT);
                break;
            case ",":
                tokens.push(BrainFuck.IN);
                break;
            case "[":
                tokens.push(BrainFuck.SJP);
                break;
            case "]":
                tokens.push(BrainFuck.JNZ);
                break;
            default:
                break;
        }
    });
    process.stdout.write("Parsed output: ");
    tokens.forEach(token => {
        process.stdout.write(tokenIndex[token]);
    });
    process.stdout.write("\n");
    return tokens;
}

const execute = async function(sourceFile: String) {
    let source = parse(sourceFile);
    const memorySize = 30000;
    let memory = new Int8Array(memorySize);
    for (let i = 0; i < memorySize - 1; i++) {
        memory[i] = 0;
    }
    let mp = 0;
    let braces = new Array<number>();

    let i = 0;

    let qurestion = [
        {
            type: 'input',
            name: 'name',
            message: '>>> '
        }
    ]

    while (i < source.length) {
        let token = source[i];
        switch (token) {
            case BrainFuck.OUT:
                console.log(memory[mp]);
                break;
            case BrainFuck.IN:
                
                break;
            default:
                break;
        }
        i++;
    }

    console.log("Done!");
}

const main = function() {

    const args = process.argv;

    if (args.length < 3) {
        console.error("Error, expected at lease 1 argument, got none\nUsage: npm execute [source_file]");
        process.exit(-1);
    }

    let source: String;

    try {
        source = fs.readFileSync(args[2], "utf-8")
    } catch (e) {
        console.error("Unable to open file " + args[2]);
        process.exit(-1);
    }

    if (args.length < 4) {
        execute(source);
    }
}

main();