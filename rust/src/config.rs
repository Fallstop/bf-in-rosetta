use std::process;

use crate::{brainfuck_lexer::{BFT, load_bf}, util::{log, throw_error}};

fn get_inputs(input_raw: &str, config: &ConfigStruct) -> Vec<u8> {
    //Used in get_config to parse the inputs into a useable formate.
    let mut inputs: Vec<u8> = vec![];
    let input_split: Vec<&str> = input_raw.split(',').collect();
    for (i, input) in input_split.iter().enumerate() {
        if input.parse::<u8>().is_ok() {
            inputs.push(input_split[i].parse::<u8>().unwrap());
        } else {
            throw_error(5, format!("Input {} is not a number (u8)", i - 1), config);
        }
    }
    inputs
}

pub fn get_config(args: &[String]) -> ConfigStruct {
    //Command line interface tool
    let mut config: ConfigStruct = ConfigStruct::new();
    let mut args_pointer: usize = 1;
    let mut arg: String;
    let help_text = "
How to use: 
    rust-bf [config, any order]
EG:
    rust-bf -c code.bf -i 53,2 -oa
    rust-bf -ci +++.>++.>+.>.
Switches:
    -h   | --help -> This help text
    -c   | --code-file <NameOfFile> -> Name/path of the BF code file
    -ci  | --code-inline <YourCodeWithoutSpaces> -> Your bf code inline
    -i   | --inputs=<YourInputs> -> Preset inputs, comma separated
    -oa  | --output-in-ascii -> BF outputs are in ascii, including inputs (Default)
    -od  | --output-in-decimal -> BF outputs are in decimal
    -v   | --verbose -> All debug output, which is quite allot of output
    -q   | --quiet -> Just the BF program output
    -s   | --silent -> No output at all
    ";
    if args.len() == 1 {
        log(&config, &help_text.to_string(), 2);
        process::exit(0);
    }
    while args_pointer < args.len() {
        log(&config, &format!("Processing arg {}", args_pointer), 3);
        arg = args[args_pointer].clone();
        match arg.as_str() {
            "-h" | "--help" => {
                println!("{}", help_text);
                process::exit(0)
            }
            "-oa" | "--output-in-ascii" => config.output_type = OutputType::Ascii,
            "-od" | "--output-in-decimal" => config.output_type = OutputType::Decimal,
            "-c" | "--code-file" => {
                args_pointer += 1;
                config.code = load_bf(&args[args_pointer].clone(), true)
            }
            "-ci" | "--code-inline" => {
                args_pointer += 1;
                config.code = load_bf(&args[args_pointer].clone(), false)
            }
            "-i" | "--inputs" => {
                args_pointer += 1;
                config.inputs = get_inputs(&args[args_pointer].clone(), &config);
            }
            "-v" | "--verbose" => config.print_level = 3,
            "-q" | "--quiet" => config.print_level = 1,
            "-s" | "--silent" => config.print_level = 0,
            _ => throw_error(
                10,
                format!(
                    "Unknown option \"{}\"\n use -h --help to see possible options",
                    &arg
                ),
                &config,
            ),
        }
        args_pointer += 1;
    }
    if config.code.is_empty() {
        throw_error(10, String::from("Code empty or not set."), &config);
    }
    log(
        &config,
        &format!("Config has been processed: {:#?}", config),
        3,
    );
    config
}


#[derive(Debug, Clone)]
pub struct ConfigStruct {
    pub code: Vec<BFT>,
    pub inputs: Vec<u8>,
    pub print_level: i64,
    pub output_type: OutputType,
}
impl ConfigStruct {
    pub fn new() -> ConfigStruct {
        ConfigStruct {
            code: vec![],
            inputs: vec![],
            print_level: 2,
            output_type: OutputType::Ascii,
        }
    }
}
impl Default for ConfigStruct {
    fn default() -> Self {
        ConfigStruct::new()
    }
}

#[derive(Debug, Clone, PartialEq)]
pub enum OutputType {
    Ascii,
    Decimal,
}