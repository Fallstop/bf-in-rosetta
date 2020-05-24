use std::env;
use std::fs;
use std::thread;
use std::sync::{Arc,Mutex};
use regex::Regex;
use std::process;
use std::time::{Instant,Duration};
use std::io::{self, Write,stdout};

fn main() {
    let start_time = Instant::now();
    let args: Vec<String> = env::args().collect();
    let mut config = get_config(&args); //Takes the args and returns a ConfigStruct with the processed Code, Inputs and default options
    if config.code_compression == true {
        config.code = macro_scan(&config.code); //Condenses repeated characters into macros (Shortcuts) a=> b=< c=+ d=-
    }
    config.braces = match_braces(&config); //Precalculates the nested loops/braces in the code
    run_bf(&config); //Steps through processed code
    let elapsed = start_time.elapsed();
    log(&config,format!("Time taken: {:.5?}", elapsed),2);
}


fn process_bf(filename: &String) -> Vec<char>{ //Read from file and remove non-command characters
    let file_contents = fs::read_to_string(filename)
        .expect("Something went wrong reading the file");
    let code_pre: Vec<char> = file_contents.chars().collect();
    let regex_code = Regex::new("^[\\[\\]<>+-.,,]$").unwrap();
    let mut code_post: Vec<char> = vec![];
    for i in 0..code_pre.len(){
        let current_char = code_pre[i];
        if regex_code.is_match(current_char.encode_utf8(&mut [4])){
            code_post.push(current_char);
        }
    }
    return code_post;
}
fn macro_scan(code: &Vec<char>) -> Vec<char>{ //Condenses sequential characters 3-9 chars long.
    let mut code_macro: Vec<char>=vec!();
    let mut char_list: Vec<char>=vec!('0','0','0');
    let mut i: usize=0;
    
    while i < code.len()-3{
        char_list[0] = code[i];
        char_list[1] = code[i+1];
        char_list[2] = code[i+2];
        if equal_vec(&char_list){
            for x in 3..10{
                if code[i+x] != code[i] || x==255{
                    let macro_type  = match code[i]{
                        '>' => 'a',
                        '<' => 'b',
                        '+' => 'c',
                        '-' => 'd',
                         _ => 'z',
                    };
                    if macro_type == 'z'{code_macro.push(code[i]);break;}//Don't want to macro things like ",.[]"
                    code_macro.push(macro_type);
                    code_macro.push(x as u8 as char);
                    i+=x;
                    break;
                }
            }
        }
        else {
            code_macro.push(code[i]);
            
            i+=1;
        }
        
    }
    while i < code.len(){
        code_macro.push(code[i]);
        i+=1;
    }
    return code_macro;

}
fn equal_vec(arr: &Vec<char>) -> bool { //Used in the macro-code to make sure 3 characters are the same
    arr.iter().min() == arr.iter().max()
}

fn run_bf(config: &ConfigStruct){ //Primary runtime - Run after all preparations
    /*
    Takes the config with all the data required

    Loop cache routine
        When the normal routine encounters the start of a loop, instead of doing nothing, if enabled,
        it looks at the caching_reference to see if it needs to either: Start a thread to calculate the
        loop or use the already made cache at this address or do nothing as usual.
    */
    log(&config,format!("Running bf code"),2);
    let code = config.code.clone();
    let mut inputs = config.inputs.clone();
    let braces = config.braces.clone();
    let mut memory: Vec<i64> = vec!(0);
    let mut memory_pointer: usize = 0;
    let mut code_pointer: usize = 0;
    let mut inputs_pointer: usize = 0;
    let caching_data = Arc::new(Mutex::new(vec!()));
    let caching_reference = Arc::new(Mutex::new(vec!(0; code.len())));
    let mut handles = vec![];
    let code_arc = Arc::new(code.clone());
    log(&config,format!("Variables Initialized"),3);
    if config.output_type == 'a'{
        log_without_newline(&config,format!("Output: "),2);
    }
    while code_pointer < code.len() as usize{
        let code_char: char = code[code_pointer];
        match code_char {
            '.' => {if config.output_type == 'd' {log(&config,format!("Output: {}",memory[memory_pointer]),1)} else {log_without_newline(&config,format!("{}",memory[memory_pointer] as u8 as char),1);}},
            ',' => {while inputs_pointer >= inputs.len() {inputs.push(get_commandline_input(&config))} memory[memory_pointer] = inputs[inputs_pointer]; inputs_pointer +=1; },
            '>' => memory_pointer+=1,
            '<' => {if memory_pointer != 0{memory_pointer-=1}else{throw_error(15, String::from("Bad BF code, memory pointer went below zero"),config)}},
            '+' => memory[memory_pointer] += 1,
            '-' => memory[memory_pointer] -= 1,
            ']' => {if memory[memory_pointer] != 0 {
                        code_pointer = braces[code_pointer] as usize;    
                    }},
            'a' => {code_pointer+=1; memory_pointer+=code[code_pointer] as usize; }, //>
            'b' => {code_pointer+=1; if memory_pointer != code[code_pointer] as usize-1{memory_pointer-=code[code_pointer] as usize;}else{throw_error(15, String::from("Bad BF code, memory pointer went below zero"),&config)} }, //<
            'c' => {code_pointer+=1; memory[memory_pointer]+=code[code_pointer] as i64;}, //+
            'd' => {code_pointer+=1; memory[memory_pointer]-=code[code_pointer] as i64; }, //-
            '[' => {
                if config.code_loop_cache == true { //If loop caching is enabled
                    let arc_cache_status = Arc::clone(&caching_reference);
                    let mut mutex_cache_status = arc_cache_status.lock().unwrap();
                    let current_cache_status = mutex_cache_status[code_pointer];
                    if current_cache_status == 0 {
                        mutex_cache_status[code_pointer] = -1;
                        drop(mutex_cache_status);
                        let caching_data = Arc::clone(&caching_data);
                        let code_arc = Arc::clone(&code_arc);
                        let caching_reference = Arc::clone(&caching_reference);
                        let mut code_pointer_local = code_pointer.clone()+1;
                        let handle = thread::spawn(move || {
                            thread::park_timeout(Duration::from_millis(10));
                            let mut current_cache: LoopCacheMeta = LoopCacheMeta::new();
                            let mut code_arc_char = code_arc[code_pointer_local];
                            let mut able_to_be_cached: bool = true;
                            let starting_position = code_pointer_local.clone();
                            let mut mutex_caching_reference = caching_reference.lock().unwrap();
                            mutex_caching_reference[starting_position] = -1;
                            drop(mutex_caching_reference);
                            while code_arc_char != ']' && able_to_be_cached == true{
                                match code_arc_char {
                                    '<' => current_cache.memory_pointer -=1,
                                    '>' => current_cache.memory_pointer +=1,
                                    '+' => current_cache.change_memory(1),
                                    '-' => current_cache.change_memory(-1),
                                    'a' => { // >
                                        code_pointer_local+=1;
                                        current_cache.memory_pointer += code_arc[code_pointer_local] as i32; 
                                    }, 
                                    'b' => { // <
                                        code_pointer_local+=1;
                                        current_cache.memory_pointer -= code_arc[code_pointer_local] as i32; 
                                    }, 
                                    'c' => { // +
                                        code_pointer_local+=1;
                                        current_cache.change_memory(code_arc[code_pointer_local] as i32);
                                    },
                                    'd' => { // -
                                        code_pointer_local+=1;
                                        current_cache.change_memory(-1*code_arc[code_pointer_local] as i32);
                                    },
                                    _   => {
                                        able_to_be_cached = false;
                                    },
                                }
                                code_pointer_local += 1;
                                code_arc_char = code_arc[code_pointer_local];
                            }
                            current_cache.control_pointer = current_cache.memory_pointer as i32;
                            if current_cache.control_pointer != 0 {
                                able_to_be_cached = false;
                            }
                            if able_to_be_cached == true {
                                current_cache.code_pointer = code_pointer_local as i32;
                                current_cache.loop_starting_loc = starting_position as i32;
                                let mut mutex_caching_data = caching_data.lock().unwrap();
                                let mut mutex_caching_reference = caching_reference.lock().unwrap();
                                mutex_caching_data.push(current_cache);
                                mutex_caching_reference[starting_position-1] = mutex_caching_data.len() as i32; //One more than actual index
                                drop(mutex_caching_data);
                                drop(caching_data);
                                drop(mutex_caching_reference);
                            }
                            else { // Loop is not possible to cache
                                drop(caching_data);
                            }

                        });
                        handles.push(handle);
                    } else if current_cache_status > 0{ //Loop has been cached
                        let mutex_cache = Arc::clone(&caching_data);
                        let unlocked_cache = mutex_cache.lock().unwrap();
                        let cache = unlocked_cache[current_cache_status as usize-1].clone(); //Gets the Cache obj with all the necessary info
                        drop(mutex_cache_status);
                        drop(unlocked_cache);
                        let mut i: usize = 0;
                        let control_memory =  memory[memory_pointer+cache.control_pointer as usize];
                        while i < cache.instructions.len() {
                            memory[memory_pointer+cache.instructions[i][0] as usize] += cache.instructions[i][1] as i64 * control_memory;
                            i+=1;
                        }
                        memory[memory_pointer+cache.control_pointer as usize] = 0;
                        memory_pointer = add_to_usize(memory_pointer, cache.memory_pointer);
                        code_pointer = cache.code_pointer as usize;

                    } else { //Loop has already being cached or attempted to be cached, just do nothing and unlock the cache status
                        drop(mutex_cache_status);
                    }
                }
            },
            _ => (),
        }
        code_pointer+=1;
        while memory_pointer >= memory.len()-1{
            memory.push(0);
        }
    }
    log(&config,format!("\nBF execution done"),2);
    for handle in handles {
        handle.join().unwrap();
    }
}
fn get_inputs(input_raw: &String, config: &ConfigStruct)-> Vec<i64>{ //Used in get_config to parse the inputs into a useable formate.
    let mut inputs: Vec<i64> = vec![];
    let input_split: Vec<&str> = input_raw.split(",").collect();
    for i in 0..input_split.len(){
        if !input_split[i].parse::<i64>().is_err(){
            inputs.push(input_split[i].parse::<i64>().unwrap());
        }
        else{
            throw_error(5,String::from(format!("Input {} is not a number (i64)",i-1)),&config);
        }
        
	}
    return inputs;
}
fn match_braces(config: &ConfigStruct)-> Vec<i32>{ //Match up the loop braces (Making sure that nested loops stay intact)
    let code_post = config.code.clone();
    let mut nested_level: i32 = 1;
    let mut bracket_left: Vec<Vec<i32>> = vec!();
    let mut bracket_right: Vec<i32> = vec!();
    for i in 0..code_post.len(){
        if code_post[i] == '['{
            nested_level += 1;
            bracket_left.push(vec!(nested_level,i as i32));
            bracket_right.push(0);
        }
        else if code_post[i] == ']'{
            let mut x: usize =  bracket_left.len() -1;
            #[allow(unused_comparisons)]
            'scan_for_match: while x >= 0 {
                if  bracket_left[x][0] == nested_level{
                    bracket_right.push(bracket_left[x][1]);
                    break 'scan_for_match;
				}
                x -= 1;
			}
            nested_level -= 1;
        }
        else{
            bracket_right.push(-2);
        }
    }
    return bracket_right;
}

fn get_config(args: &Vec<String>)-> ConfigStruct{ //Command line interface tool
    let mut config: ConfigStruct = ConfigStruct::new();
    let mut args_pointer: usize = 1;
    let mut arg: String;
    let help_text = "
How to use: 
    rust-bf [OPTIONS, any order]
Min-required:
    rust-bf -c [CodeFilename]
EG:
    rust-bf -c code.bf -i 53,2 -oa
Switches:
    -h   | --help -> This help text
    -c   | --code-file -> Name/path of the BF code file
    -i   | --inputs -> Preset inputs, comma separated
    -dcc | --disable-code-comp -> Disables the code compression algorithm which will slow the program down
    -dlc | --disable-loop-caching -> Disables the multi-threaded Loop cache algorithm which will massively slower
                                     BUT in 1 in a 1,000,000 loops, the program will hang.
                                     So if your code is freezing, try using this option.
    -oa  | --output-in-ascii -> BF outputs are in ascii (And inputs)
    -od  | --output-in-decimal -> BF outputs are in decimal (Default, as it is the superior flavor)
    -v   | --verbose -> All debug output
    -q   | --quiet -> Just the BF program output
    -s   | --silent -> No output at all

Notes:
    There is minimum error checking for maximum speed. You are on your own.

    It is recommended to make your program in another tool, as this one dose not show your bf code memory,
    but then, once done, you can run it using this one and watch it compute faster than what should be possible.
    ";
    if args.len() == 1 {
        log(&config,format!("{}",help_text),2);
        process::exit(0);
    }
    while args_pointer < args.len() {
        log(&config,format!("Processing arg {}",args_pointer),3);
        arg = args[args_pointer].clone();
        match arg.as_str() {
            "-h" | "--help" => {println!("{}",help_text); process::exit(0)},
            "-dcc" | "--disable-code-comp" => config.code_compression = false,
            "-dlc" | "--disable-loop-caching" => config.code_loop_cache = false,
            "-oa" | "--output-in-ascii" => config.output_type = 'a',
            "-od" | "--output-in-decimal" => config.output_type = 'd',
            "-c" | "--code-file" => {args_pointer+=1; config.code =  process_bf(&args[args_pointer].clone())},
            "-i" | "--inputs" => {args_pointer+=1; config.inputs = get_inputs(&args[args_pointer].clone(),&config);},
            "-v" | "--verbose" => config.print_level = 3,
            "-q" | "--quiet" => config.print_level = 1,
            "-s" | "--silent" => config.print_level = 0,
            _ => throw_error(10, format!("Unknown option \"{}\"\n use -h --help to see possible options",&arg),&config)
        }
        args_pointer+=1;
    }
    if config.code.len() == 0 {
        throw_error(10, String::from("Code empty or not set."),&config);
    }
    log(&config,format!("Config has been processed: {:#?}",config),3);
    return config;
}

fn throw_error(error_code: i32,message: std::string::String, config: &ConfigStruct){
    log(&config,format!("ERROR: Code: {}, Message: {}",error_code,message),1);
    process::exit(error_code);
}

fn log(config: &ConfigStruct,message: String, log_level: i32) { //For the silent, quiet, verbose tags to work.
    let global_log = config.print_level.clone();
    if log_level <= global_log {
        println!("{}",message);
    }
}
fn log_without_newline(config: &ConfigStruct,message: String, log_level: i32) {//Effectively same as above ^
    let global_log = config.print_level.clone();
    if log_level <= global_log {
        print!("{}",message);
    }
}
fn get_commandline_input (config: &ConfigStruct) -> i64 { //When the BF code requests more inputs than user supplied on the commandline
    log(&config,format!("Please enter input for program: "),2);
    let _=stdout().flush();
    let mut input = String::new();
    match io::stdin().read_line(&mut input) {
        Ok(_) => {
        }
        Err(error) => log(&config,format!("error: {}", error),1),
    }
    if config.output_type == 'a' {
        let mut result: i64 = 0;
        for current_char in input.trim().chars() {
            result += current_char as u8 as i64;
        }
        log(&config,format!("ascii to int -> {}", result),2);
        return result;
    }
    else {
        if !input.trim().parse::<i64>().is_err(){
            return input.trim().parse::<i64>().unwrap();
        }
        else{
            throw_error(5,String::from(format!("Input is not a number (i64)")),&config);
            return 0;
        }
    }
}

fn add_to_usize(usize_num: usize, i32_num: i32) -> usize{ //Adding a negative number to a usize is not okay apparently to rust
    if i32_num.is_negative() {
        return usize_num - i32_num.wrapping_abs() as usize;
    } else {
        return usize_num + i32_num as usize;
    }
}

#[derive(Debug)]
#[derive(Clone)]
pub struct LoopCacheMeta { //Data Obj for the loop cache algorithm
    instructions: Vec<Vec<i32>>,
    control_pointer: i32,
    code_pointer: i32,
    memory_pointer: i32,
    loop_starting_loc: i32,
}
impl LoopCacheMeta {
    pub fn change_memory(&mut self, amount: i32) {
        let mut instruction: Vec<i32> = vec!();
        instruction.push(self.memory_pointer);
        instruction.push(amount.clone());
        self.instructions.push(instruction);
        return;
    }
    pub fn new() -> LoopCacheMeta{
        return LoopCacheMeta {
            instructions: vec!(),
            code_pointer: 0,
            control_pointer: 0,
            memory_pointer: 0,
            loop_starting_loc: 0,
        }
    }
}

#[derive(Debug)]
#[derive(Clone)]
pub struct ConfigStruct {
    code: Vec<char>,
    inputs: Vec<i64>,
    braces: Vec<i32>,
    print_level: i32,
    code_compression: bool,
    code_loop_cache: bool,
    output_type: char,
}
impl ConfigStruct {
    pub fn new() -> ConfigStruct {
        return ConfigStruct {
            code: vec!(),
            inputs: vec!(),
            braces: vec!(),
            print_level: 2,
            code_compression: true,
            code_loop_cache: true,
            output_type: 'd',
        }
    }
}