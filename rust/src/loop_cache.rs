use std::num::Wrapping;

use crate::brainfuck_lexer::BFT;

#[derive(Debug, Clone)]
pub enum LoopCacheStatus {
    NotAvailable,
    Available(usize),
    Unknown
}


pub fn loop_cache_control(caching_reference: &mut Vec<LoopCacheStatus>, code_pointer: &mut usize, code: &[BFT], caching_data: &mut Vec<LoopCacheMeta>, memory: &mut Vec<Wrapping<i128>>, memory_pointer: &mut usize) {
    let current_cache_status = &caching_reference[*code_pointer];
    match current_cache_status {
        LoopCacheStatus::Unknown => {
            caching_reference[*code_pointer] = LoopCacheStatus::NotAvailable;
            let mut code_pointer_local = *code_pointer + 1;
            let mut current_cache: LoopCacheMeta = LoopCacheMeta::new();
            let mut code_char = code[code_pointer_local].to_owned();
            let mut able_to_be_cached: bool = true;
            let starting_position = code_pointer_local;
            caching_reference[starting_position] = LoopCacheStatus::NotAvailable;
            while able_to_be_cached {
                match code_char {
                    BFT::Move(count) => current_cache.memory_pointer += count as i128,
                    BFT::MemChange(count) => current_cache.change_memory(count as i128),
                    _ => {
                        able_to_be_cached = false;
                    }
                }
                code_pointer_local += 1;
                code_char = code[code_pointer_local].to_owned();
                if let BFT::LoopEnd(_) = code_char {
                    break;
                }
            }
    
            current_cache.control_pointer = current_cache.memory_pointer as i128;
            if current_cache.control_pointer != 0 {
                able_to_be_cached = false;
            }
            if able_to_be_cached {
                current_cache.code_pointer = code_pointer_local as i128;
                current_cache.loop_starting_loc = starting_position as i128;
                caching_data.push(current_cache.clone());
                caching_reference[starting_position - 1] = LoopCacheStatus::Available(caching_data.len()); //One more than actual index
                use_loop_cache(
                    &caching_data[caching_data.len() as usize - 1],
                    memory,
                    memory_pointer,
                    code_pointer,
                );
            }
    
        },
        LoopCacheStatus::Available(x) => {
            use_loop_cache(
                &caching_data[x - 1],
                memory,
                memory_pointer,
                code_pointer,
            );
        },
        _ => {}
    }
}


fn use_loop_cache(
    caching_data: &LoopCacheMeta,
    memory: &mut Vec<Wrapping<i128>>,
    memory_pointer: &mut usize,
    code_pointer: &mut usize,
) {
    let mut i: usize = 0;
    let control_memory = memory[*memory_pointer + caching_data.control_pointer as usize];
    while i < caching_data.instructions.len() {
        while (caching_data.instructions[i].0 + *memory_pointer as i128) as usize
            >= memory.len() - 1
        {
            memory.push(Wrapping(0));
        }
        memory[(caching_data.instructions[i].0 + *memory_pointer as i128) as usize] +=
            Wrapping(caching_data.instructions[i].1 as i128 * control_memory.0);
        i += 1;
    }
    memory[*memory_pointer + caching_data.control_pointer as usize] = Wrapping(0);
    *memory_pointer += caching_data.memory_pointer as usize;
    *code_pointer = caching_data.code_pointer as usize;
}


#[derive(Debug, Clone)]
pub struct LoopCacheMeta {
    //Data Obj for the loop cache algorithm
    instructions: Vec<(i128, i128)>,
    control_pointer: i128,
    code_pointer: i128,
    memory_pointer: i128,
    loop_starting_loc: i128,
}
impl LoopCacheMeta {
    pub fn change_memory(&mut self, amount: i128) {
        self.instructions.push((self.memory_pointer, amount));
    }
    pub fn new() -> LoopCacheMeta {
        LoopCacheMeta {
            instructions: vec![],
            code_pointer: 0,
            control_pointer: 0,
            memory_pointer: 0,
            loop_starting_loc: 0,
        }
    }
}

impl Default for LoopCacheMeta {
    fn default() -> Self {
        LoopCacheMeta::new()
    }
}
