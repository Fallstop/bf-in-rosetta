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
        println!("How to use: main [filename]");
        let error_message = format!("Args not correct, 1 expected, {} recived", args.len());
        throw_error(10, error_message);
        
    }
    let filename = &args[1];
    let file_contents = fs::read_to_string(filename)
        .expect("Something went wrong reading the file");
    //println!("BF code:\n{}",file_contents);
    let code_pre: Vec<char> = file_contents.chars().collect();
    let code_post: Vec<char>;
    
    code_post = match_braces(regex_scan(code_pre));
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

fn match_braces(code_post: Vec<char>)-> Vec<char>{
    let mut nested_level: i8 = 0;
    for i in 0..code_post.len(){
        if code_post[i].encode_utf8(&mut [1]) == "["{
            nested_level -=- 1;
            println!("Found Left braket, nested level: {}",nested_level)
        }
        else if code_post[i].encode_utf8(&mut [1]) == "]"{
            
            println!("Found Left braket, nested level: {}",nested_level);
            nested_level -= 1;
        }
    }
    return code_post;
}

fn throw_error(error_code: i32,message: std::string::String){
    println!("The program encounted a error:");
    println!("Code: {} Message: {}",error_code,message);
    process::exit(error_code);
}

