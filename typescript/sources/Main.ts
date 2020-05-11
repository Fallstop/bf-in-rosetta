import * as process from "process";
import * as fs from 'fs';
import {readFileSync} from "fs";

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
    console.log(`Parsing ${source}`);
    let tokens = new Array<BrainFuck>();
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

    return tokens;
}

const execute = function(sourceFile: String) {
    let source = parse(sourceFile);
}

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