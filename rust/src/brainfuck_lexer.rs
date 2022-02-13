use std::{fs};


#[derive(Debug, Clone, PartialEq, Copy)]
pub enum BFT {
    MemChange(i128),
    Move(i32),
    Print,
    Read,
    LoopStart(Option<usize>),
    LoopEnd(usize),
}

pub fn load_bf(uri: &str, read_from_file: bool) -> Vec<BFT> {
    //Read from file and remove non-command characters
    let file_contents: String;
    if read_from_file {
        file_contents = fs::read_to_string(uri).expect("Something went wrong reading the file");
    } else {
        file_contents = uri.to_string();
    }
    lex_bf(&file_contents)
}

fn lex_bf(input: &str) -> Vec<BFT> {

    let mut only_bf: Vec<char> = vec![];
    for current_char in input.chars() {
        if "+-,.<>[]".contains(current_char) {
            only_bf.push(current_char);
        }
    }

    // Keeps track of the bracket pairs
    let mut bracket_stack: Vec<usize> = vec![];

    let mut code_pointer = 0;
    let mut code_compression_tally = 0;
    let mut tokens: Vec<BFT> = vec![];
    while code_pointer < only_bf.len() {
        let current_char = only_bf[code_pointer];
        let new_token = match current_char {
            ',' => BFT::Read,
            '.' => BFT::Print,
            '[' => {
                // Add to stack, accounting for code being compressed
                bracket_stack.push(code_pointer - code_compression_tally);

                BFT::LoopStart(None)
            },
            ']' => {
                let index = match bracket_stack.pop() {
                    Some(x) => x,
                    None => panic!("Unmatched ] bracket, check your brackets!"),
                };
                if tokens[index]==BFT::LoopStart(None) {
                    tokens[index] = BFT::LoopStart(Some(code_pointer - code_compression_tally));
                } else {
                    panic!("Unmatched ] bracket, check your brackets!");
                }

                BFT::LoopEnd(index)
            } ,
            _ => {
                // Only compressible characters now

                let mut forward_looking = 1;
                while forward_looking + code_pointer < only_bf.len() {
                    if only_bf[code_pointer + forward_looking] == current_char {
                        forward_looking += 1;
                    } else {
                        break;
                    }
                }

                // adjust search to deal with skipping
                code_pointer += forward_looking - 1;
                code_compression_tally += forward_looking - 1;

                match current_char {
                    '+' => BFT::MemChange(forward_looking as i128),
                    '-' => BFT::MemChange(-(forward_looking as i128)),
                    '<' => BFT::Move(-(forward_looking as i32)),
                    '>' => BFT::Move(forward_looking as i32),
                    _ => panic!("Unrecognized character"),
                }

            }
        };
        tokens.push(new_token);
        code_pointer += 1;
    }
    tokens
}

#[cfg(test)]
mod tests {

    use crate::brainfuck_lexer::BFT;

    use super::lex_bf;

    #[test]
    fn empty_case() {
        assert_eq!(lex_bf(&""), vec![]);
    }

    #[test]
    fn token_series() {
        assert_eq!(lex_bf(&"><+-.,[]"), vec![BFT::Move(1), BFT::Move(-1), BFT::MemChange(1), BFT::MemChange(-1), BFT::Print, BFT::Read, BFT::LoopStart(Some(7)), BFT::LoopEnd(6)]);
    }

    #[test]
    fn code_compression() {
        assert_eq!(lex_bf(&">>>><<<<++++----"), vec![BFT::Move(4), BFT::Move(-4), BFT::MemChange(4), BFT::MemChange(-4)]);
    }

    #[test]
    fn bracket_pairing() {
        assert_eq!(lex_bf(&"++[++[-]-]"), vec![BFT::MemChange(2), BFT::LoopStart(Some(7)), BFT::MemChange(2), BFT::LoopStart(Some(5)), BFT::MemChange(-1), BFT::LoopEnd(3), BFT::MemChange(-1), BFT::LoopEnd(1)]);
    }

    #[test]
    fn extra_characters() {
        assert_eq!(lex_bf(&"owo + \n"), vec![BFT::MemChange(1)]);
    }
}