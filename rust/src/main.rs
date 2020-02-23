use std::env;
use std::fs;
use regex::Regex;
use std::process;

fn main() {
    
    println!("\n\nRunning\n");
    let args: Vec<String> = env::args().collect();
    process_bf(args);
    
}

fn process_bf(args: Vec<String>){
    if args.len() != 2  {
        let error_message = format!("Args not correct, 1 expected, {} recived", args.len());
        throw_error(10, error_message);
        
    }
    let filename = &args[1];
    let file_contents = fs::read_to_string(filename)
        .expect("Something went wrong reading the file");
    println!("BF code:\n{}",file_contents);
    let code_pre: Vec<char> = file_contents.chars().collect();
    let regex_code = Regex::new("~[[]<>+-.,,]~").unwrap();
    for i in 0..code_pre.len(){
        let current_char = code_pre[i];
        assert!(regex_code.is_match(current_char));
    }
}

fn throw_error(error_code: i32,message: std::string::String){
    println!("The program encounted a error:");
    println!("Code: {} Message: {}",error_code,message);
    process::exit(error_code);
}

