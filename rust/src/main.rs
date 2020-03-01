use std::env;
use std::fs;
use regex::Regex;
use std::process;
//use std::{thread, time};


fn main() {
    
    println!("\n\nRunning\n");
    let args: Vec<String> = env::args().collect();
    let code: Vec<char> = process_bf(&args);
    let inputs: Vec<i64>;
    inputs = get_inputs(&args);
    let braces: Vec<Vec<i32>>;
    braces = match_braces(&code);
    macro_scan(&code);
    run_bf(code,braces,inputs);
    
}

fn process_bf(args: &Vec<String>) -> Vec<char>{
    if args.len() < 2  {
        println!("How to use: main [filename] [inputs]");
        let error_message = format!("Args not correct, 1 expected, {} recived", args.len());
        throw_error(10, error_message);
        
    }
    let filename = &args[1];
    let file_contents = fs::read_to_string(filename)
        .expect("Something went wrong reading the file");
    //println!("BF code:\n{}",file_contents);
    let code_pre: Vec<char> = file_contents.chars().collect();
    let code_post: Vec<char>;
    
    code_post = regex_scan(code_pre);
    

    return code_post;
}
fn macro_scan(code: &Vec<char>){
    
    let mut macro_list: Vec<u32>=vec!();
    let mut char_list: Vec<char>=vec!('0','0','0');
    for i in 1..code.len()-1{
        char_list[0] = code[i-1];
        char_list[1] = code[i];
        char_list[2] = code[i+1];
        
        if equal_vec(&char_list){
              println!("Found macro location");
		}
	}

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
fn equal_vec(arr: &Vec<char>) -> bool {
    arr.iter().min() == arr.iter().max()
}

fn run_bf(code: Vec<char>,braces: Vec<Vec<i32>>,inputs: Vec<i64>){
    println!("Running bf code");
    let mut memory: Vec<i64> = vec!(0);
    let mut memory_pointer: usize = 0;
    let mut code_pointer: usize = 0;
    let mut inputs_pointer: usize = 0;
    
    while code_pointer < code.len()  as usize{
        let code_char: char = code[code_pointer];
        match code_char {
            '.' => println!("{}",memory[memory_pointer]),
            ',' => {memory[memory_pointer] = inputs[inputs_pointer]; inputs_pointer +=1; },
            '>' => memory_pointer+=1,
            '<' => memory_pointer-=1,
            '+' => memory[memory_pointer] += 1,
            '-' => memory[memory_pointer] -= 1,
            ']' => {if memory[memory_pointer] != 0 {
                        code_pointer = braces[code_pointer][2] as usize;    
                    }},
            _ => (),

		}
        code_pointer+=1;
        while memory_pointer >= memory.len()-1{
            memory.push(0);  
        }
        //thread::sleep(time::Duration::from_millis(50));
    }
    println!("BF excution done");
}
fn get_inputs(args: &Vec<String>)-> Vec<i64>{
    let mut inputs: Vec<i64> = vec![];
    for i in 2..args.len(){
        inputs.push(args[i].parse::<i64>().unwrap());
	}
    println!("Inputs: {:?}",inputs);
    return inputs;
}
fn match_braces(code_post: &Vec<char>)-> Vec<i32>{
    let mut nested_level: i32 = 0;
    let mut bracket_left: Vec<Vec<i32>> = vec!();
    let mut bracket_right: Vec<i32> = vec!();
    for i in 0..code_post.len(){
        if code_post[i].encode_utf8(&mut [1]) == "["{
            nested_level += 1;
            bracket_left.push(vec!(0,nested_level,i as i32));
            bracket_right.push(i as i32);
        }
        else if code_post[i].encode_utf8(&mut [1]) == "]"{
            let mut x: usize =  bracket_left.len() -1;
            #[allow(unused_comparisons)]
            'scan_for_match: while x >= 0 {
                if  bracket_left[x][1] == nested_level{
                    bracket_right.push(bracket_left[x][2]);
                    break 'scan_for_match;
				}
                x -= 1;
			}
            nested_level -= 1;
        }
        else{
            bracket_right.push(0); //Space filler, makes code running faster beacuse it elements find, and uses the code index as the array index
        }
    }
    return bracket_right;
}

fn throw_error(error_code: i32,message: std::string::String){
    println!("The program encounted a error:");
    println!("Code: {} Message: {}",error_code,message);
    process::exit(error_code);
}

