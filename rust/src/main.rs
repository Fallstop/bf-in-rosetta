use brainfuck_lexer::BFT;
use config::{get_config, ConfigStruct, OutputType};
use std::env;
use std::io::{self, stdout, Write};
use std::num::Wrapping;
use std::time::Instant;

mod brainfuck_lexer;

mod loop_cache;
use loop_cache::{loop_cache_control, LoopCacheStatus};

mod config;

mod util;
use util::{log, log_without_newline, throw_error};

fn main() {
    let start_time = Instant::now();
    let args: Vec<String> = env::args().collect();
    let config = get_config(&args); //Takes the args and returns a ConfigStruct with the processed Code, Inputs and default options

    run_bf(&config); //Steps through processed code
    let elapsed = start_time.elapsed();
    log(&config, &format!("Time taken: {:.5?}", elapsed), 2);
}

fn run_bf(config: &ConfigStruct) {
    //Primary runtime - Run after all preparations
    /*
    Takes the config with all the data required and executes the code

    Loop cache routine
        When the normal routine encounters the start of a loop, instead of doing nothing, if enabled,
        it looks at the caching_reference to see if it needs to either: Start a thread to calculate the
        loop or use the already made cache at this address or do nothing as usual.
    */
    log(config, "Running bf code", 2);
    let code = config.code.clone();
    let mut inputs = config.inputs.clone();
    let mut memory: Vec<Wrapping<i128>> = vec![Wrapping(0); 3000];
    let mut memory_pointer: usize = 0;
    let mut code_pointer: usize = 0;
    let mut inputs_pointer: usize = 0;
    let mut caching_data = vec![];
    let mut caching_reference = vec![LoopCacheStatus::Unknown; code.len()];
    if config.output_type == OutputType::Ascii {
        log_without_newline(config, "Output: ", 2);
    }
    while code_pointer < code.len() as usize {
        match code[code_pointer] {
            BFT::Print => {
                if config.print_level >= 1 {
                    match config.output_type {
                        OutputType::Ascii => {
                            log_without_newline(
                                config,
                                &format!("{}", memory[memory_pointer].0 as u8 as char),
                                1,
                            );
                        }
                        OutputType::Decimal => {
                            log(config, &format!("Output: {}", memory[memory_pointer]), 1)
                        }
                    }
                }
            }
            BFT::Read => {
                while inputs_pointer >= inputs.len() {
                    inputs.push(get_commandline_input(config))
                }
                memory[memory_pointer] = Wrapping(inputs[inputs_pointer] as i128);
                inputs_pointer += 1;
            }
            BFT::Move(count) if count > 0 => {
                memory_pointer += count as usize;
            }
            BFT::Move(count) => {
                let count = (-count) as usize;
                if count > memory_pointer {
                    throw_error(
                        15,
                        String::from("Bad BF code, memory pointer went below zero"),
                        config,
                    );
                }
                memory_pointer -= count;
            }
            BFT::MemChange(count) => memory[memory_pointer] += Wrapping(count),
            BFT::LoopEnd(loc) => {
                // println!("m{}",memory[memory_pointer].0);
                if memory[memory_pointer].0 != 0 {
                    code_pointer = loc - 1;
                } else {
                }
            }
            BFT::LoopStart(index) => {
                // println!("m{}",memory[memory_pointer].0);
                if memory[memory_pointer].0 == 0 {
                    if let Some(index) = index {
                        code_pointer = index;
                    } else {
                        throw_error(
                            15,
                            String::from("Bad BF code, loop start without end"),
                            config,
                        )
                    }
                } else {
                    // If loop caching is enabled
                    loop_cache_control(
                        &mut caching_reference,
                        &mut code_pointer,
                        &code,
                        &mut caching_data,
                        &mut memory,
                        &mut memory_pointer,
                    );
                }
            }
        }
        code_pointer += 1;

        while memory_pointer >= memory.len() - 1 {
            memory.push(Wrapping(0));
        }
    }
    log(config, "\nBF execution done", 2);
}

fn get_commandline_input(config: &ConfigStruct) -> u8 {
    //When the BF code requests more inputs than user supplied on the commandline
    log(config, "Please enter input for program: ", 2);
    let _ = stdout().flush();
    let mut input = String::new();
    match io::stdin().read_line(&mut input) {
        Ok(_) => {}
        Err(error) => log(config, &format!("error: {}", error), 1),
    }
    if config.output_type == OutputType::Ascii {
        let mut result: u8 = 0;
        for current_char in input.trim().chars() {
            result += current_char as u8 as u8;
        }
        log(config, &format!("ascii to int -> {}", result), 2);
        result
    } else if input.trim().parse::<u8>().is_ok() {
        input.trim().parse::<u8>().unwrap()
    } else {
        throw_error(5, String::from("Input is not a number (u8)"), config);
        0
    }
}

