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
    //println!("BF code:\n{}",file_contents);
    let code_pre: Vec<char> = file_contents.chars().collect();
    let mut code_post: Vec<char> = vec![];
    
    code_post = regex_scan(code_pre);
    let code_print: String  = code_post.into_iter().collect();
    println!("Code post scaning: {}",code_print);
}
fn regex_scan(code_pre: Vec<char>) -> Vec<char>{
    let regex_code = Regex::new("^[\\[\\]<>+-.,,]$").unwrap();
    let mut code_post = vec![];
    for i in 0..code_pre.len(){
        let current_char = code_pre[i];
        if regex_code.is_match(current_char.encode_utf8(&mut [4])){
            code_post.push(current_char);
        }
        
    }
    return code_post;
}

fn throw_error(error_code: i32,message: std::string::String){
    println!("The program encounted a error:");
    println!("Code: {} Message: {}",error_code,message);
    process::exit(error_code);
}

