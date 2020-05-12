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

const parseCsv = function(inputs: String): Array<number> {
    console.log(`Parsing CSV input: ${inputs}`);
    let list: Array<number> = new Array<number>();
    // @ts-ignore
    let r = inputs.split(",");

    r.forEach(i => {
        // @ts-ignore
        let inputs = [...i];
        let num = "";
        inputs.forEach(number => {
            // @ts-ignore
            let q = number.charCodeAt();
            if (q >= 48 && q <= 57) {
                num += number;
            }
        });
        list.push(+num);
    });

    process.stdout.write("Parsed: ");
    list.forEach(num => process.stdout.write(`${num}`));
    process.stdout.write('\n');
    return list;
}

const execute = function(sourceFile: String, inputs: String) {
    let source = parse(sourceFile);
    let input = parseCsv(inputs);

    const memorySize = 30000;
    let memory = new Uint8Array(memorySize);
    for (let i = 0; i < memorySize - 1; i++) {
        memory[i] = 0;
    }
    let mp = 0;
    let ip = 0;
    let braces = new Array<number>();

    let i = 0;

    console.log("Executing");

    while (i < source.length) {
        let token = source[i];
        switch (token) {
            case BrainFuck.OUT:
                console.log(memory[mp]);
                break;
            case BrainFuck.IN:
                console.log(`${input.length}`);
                if (ip > input.length) {
                    console.log(`Error not enough inputs does not exist, needed at least ${ip}, got ${input.length}`);
                    process.exit(-1);
                }
                memory[mp] = input[ip];
                ip++;
                break;
            case BrainFuck.DEC:
                memory[mp]--;
                break;
            case BrainFuck.INC:
                memory[mp]++;
                break;
            case BrainFuck.SLF:
                mp--;
                if (mp < 0) {
                    mp = memorySize - 1;
                }
                break;
            case BrainFuck.SRT:
                mp++;
                if (mp > memorySize) {
                    mp = 0;
                }
                break;
            case BrainFuck.SJP:
                braces.push(i - 1);
                break;
            case BrainFuck.JNZ:
                if (memory[mp] != 0) {
                    i = braces.pop();
                } else {
                    braces.pop();
                }
                break;
        }
        i++;
    }

    console.log("Done!");
}

const main = function() {

    const args = process.argv;

    if (args.length < 4) {
        console.error("Error, expected at lease 2 arguments\nUsage: npm execute [source_file] [scv_input]");
        process.exit(-1);
    }

    let source: String;
    let input: String;

    try {
        source = fs.readFileSync(args[2], "utf-8");
        input = fs.readFileSync(args[3], "utf-8");
    } catch (e) {
        console.error("Unable to open file " + args[2] + " or " + args[3] + ". I dont really know, fuck you!");
        process.exit(-1);
    }

    execute(source, input);
}

main();