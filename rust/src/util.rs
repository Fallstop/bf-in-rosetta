use std::process;

use crate::config::ConfigStruct;

pub fn log(config: &ConfigStruct, message: &str, log_level: i64) {
    //For the silent, quiet, verbose tags to work.
    let global_log = config.print_level;
    if log_level <= global_log {
        println!("{}", message);
    }
}
pub fn log_without_newline(config: &ConfigStruct, message: &str, log_level: i64) {
    //Effectively same as above ^
    let global_log = config.print_level;
    if log_level <= global_log {
        print!("{}", message);
    }
}

pub fn throw_error(error_code: i32, message: std::string::String, config: &ConfigStruct) {
    log(
        config,
        &format!("ERROR: Code: {}, Message: {}", error_code, message),
        1,
    );
    process::exit(error_code);
}