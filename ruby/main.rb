module BrainFuck
INC = 0
DEC = 1
IN  = 2
OUT = 3
SLF = 4
SRT = 5
SJP = 6
JNZ = 7
TOKEN_INDEX = %w(+ - , . < > [ ]).freeze
end

def open_file(path)
  puts "Opening file #{path}"
  file = File.open path, 'r'
  ret = file.read
  file.close
  ret
rescue StandardError => e
  puts "Can not open file: #{path}, Error #{e}, Type#{e.class}"
end

def parse(source)
  puts "Parsing code: #{source}"
  brrr = source.split ''
  list = []
  brrr.each do |a|
    case a
    when '+'
      list.append BrainFuck::INC
    when '-'
      list.append BrainFuck::DEC
    when '.'
      list.append BrainFuck::OUT
    when ','
      list.append BrainFuck::IN
    when '>'
      list.append BrainFuck::SRT
    when '<'
      list.append BrainFuck::SLF
    when '['
      list.append BrainFuck::SJP
    when ']'
      list.append BrainFuck::JNZ
    end
  end
  print 'Parsed output: '
  list.each { |a| print BrainFuck::TOKEN_INDEX[a] }
  print "\n"
  $stdout.flush
  list
end

def input
  print '>>> '
  $stdout.flush
  i = $stdin.gets
  puts ''
  i.to_i
end

def execute(source)
  tokens = parse source
  i = 0
  memory_size = 30_000
  memory_size = memory_size.freeze
  memory = Array.new(memory_size) { |i| 0 }
  memory_pointer = 0
  braces = []
  puts 'Executing'
  while i < tokens.length
    # puts "Current position: #{i}, Token: #{BrainFuck::TOKEN_INDEX[tokens[i]]}, Memory Pointer: #{memory_pointer}"
    case tokens[i]
    when BrainFuck::INC
      memory[memory_pointer] += 1
    when BrainFuck::DEC
      memory[memory_pointer] -= 1
    when BrainFuck::IN
      memory[memory_pointer] = input
    when BrainFuck::OUT
      puts "Output: #{memory[memory_pointer]}"
    when BrainFuck::SLF
      memory_pointer -= 1
      memory_pointer = memory_size - 1 if memory_pointer.negative?
    when BrainFuck::SRT
      memory_pointer += 1
      memory_pointer = 0 if memory_pointer > memory_size
    when BrainFuck::SJP
      braces.push i - 1
    when BrainFuck::JNZ
      if memory[memory_pointer] != 0
        i = braces.pop
      else
        _ = braces.pop
      end
    end
    # (0..10).each { |brrr| print "#{memory[brrr]}, " }
    # print "\n"
    # $stdout.flush
    i += 1
  end
  puts 'Done'
end

def execute_csv(source, inputs)
  tokens = parse source
  input_pointer = 0
  input = parse_csv(input)
  i = 0
  memory_size = 30_000
  memory_size = memory_size.freeze
  memory = Array.new(memory_size) { |i| 0 }
  memory_pointer = 0
  braces = []
  puts 'Executing'
  while i < tokens.length
    case tokens[i]
    when BrainFuck::INC
      memory[memory_pointer] += 1
    when BrainFuck::DEC
      memory[memory_pointer] -= 1
    when BrainFuck::IN
      memory[memory_pointer] = input[input_pointer] if input_pointer < input.length else puts "Error not enough inputs provided, falling back to console input"; input
    when BrainFuck::OUT
      puts "Output: #{memory[memory_pointer]}"
    when BrainFuck::SLF
      memory_pointer -= 1
      memory_pointer = memory_size - 1 if memory_pointer.negative?
    when BrainFuck::SRT
      memory_pointer += 1
      memory_pointer = 0 if memory_pointer > memory_size
    when BrainFuck::SJP
      braces.push i - 1
    when BrainFuck::JNZ
      if memory[memory_pointer] != 0
        i = braces.pop
      else
        _ = braces.pop
      end
    end
    i += 1
  end
  puts 'Done'
end

if ARGV.empty?
  puts 'Expected at lease 1 argument got none'
  exit -1
end

sources = open_file ARGV[0]
if ARGV.length < 1
  execute sources
  exit 0
end

inputs = open_file ARGV[1]

execute_csv sources, inputs