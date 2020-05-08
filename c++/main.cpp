#include <iostream>
#include <fstream>
#include <string>
#include <stdlib.h>
#include <vector>
#include <chrono>
#include <regex>

enum BrainFuck {
    PLUS = 0,
    MINUS = 1,
    LEFT = 2,
    RIGHT = 3,
    OUT = 4,
    IN = 5,
    LBRACE = 6,
    RBRACE = 7,
};
const std::string token_index[] = {"+", "-", "<", ">", ".", ",", "[", "]"};

std::string read_file(const char * file_path);
void execute(std::string);
void execute(std::string, std::string);
int input();
std::vector<BrainFuck> parse(std::string&);
std::vector<int> parse_csv(std::string&);

int main(int argc, char** argv) {
    // Checking to see if enough arguments were specified
    if (argc < 2) {
        std::cout << "Expected 2 arguments, got " << argc - 1 << std::endl;
        std::cout << "Usage: bf [sourcefile] <csvinput>" << std::endl;
        return -1;
    }

    // Read the source file
    auto file = read_file(argv[1]);


    // Check to see if CSV file needs parsing
    if (argc < 3) {
        execute(file);
	} else {
    	std::string input_file = read_file(argv[2]);
		auto start = std::chrono::high_resolution_clock::now();
    	execute(file, input_file);
		auto end = std::chrono::high_resolution_clock::now();
		std::chrono::duration<double> diff = end - start;
		std::cout << "Done\nExecution time: " << diff.count() * 1000000 << "ns" << std::endl;
    }

    return 0;
}

std::string read_file(const char * file_path) {
    // Open the specified file
    std::ifstream file;
    file.open(file_path);

    // Check to see if the file was opened
    if (!file) {
        fprintf(stderr, "Error opening file %s\n", file_path);
        exit(-1);
    }

    // Read in the file
    std::string line;
    std::string source_file;

    while (std::getline(file, line)) {
        source_file.append(line);
    }

    return source_file;
}

void execute(std::string source_file) {
    std::vector<BrainFuck> tokens = parse(source_file);

    const int memory_size = 30000;
    unsigned char memory[memory_size] = {0};
    int mp = 0;
	std::vector<int> braces{};

	std::cout << "Executing" << std::endl;

	int i = 0;
	while (i < tokens.size()) {
		BrainFuck token = tokens.at(i);
		if (token == PLUS) {
			memory[mp]++;
		} else if (token == MINUS) {
			memory[mp]--;
		} else if (token == IN) {
			memory[mp] = input();
		} else if (token == OUT) {
			 std::cout << (int) memory[mp] << std::endl;
		} else if (token == LEFT) {
			mp--;
			if (mp < 0) {
				mp = memory_size - 1;
			}
		} else if (token == RIGHT) {
			mp++;
			if (mp > memory_size) {
				mp = 0;
			}
		} else if (token == LBRACE) {
			braces.push_back(i - 1);
		} else if (token == RBRACE) {
			if (memory[mp] != 0) {
				i = braces.back();
				braces.pop_back();
			} else {
				braces.pop_back();
			}
		}
		i++;
	}
	std::cout << "Done" << std::endl;
}

void execute(std::string source_file, std::string inputs) {
	std::vector<BrainFuck> tokens = parse(source_file);
	std::vector<int> input = parse_csv(inputs);
	const int memory_size = 30000;
	unsigned int memory[memory_size] = {0};
	int mp = 0;
	int ip = 0;
	std::vector<int> braces{};

	std::cout << "Executing" << std::endl;

	int i = 0;
	while (i < tokens.size()) {
		BrainFuck token = tokens.at(i);
		if (token == PLUS) {
			memory[mp]++;
		} else if (token == MINUS) {
			memory[mp]--;
		} else if (token == IN) {
			try {
				memory[mp] = input.at(ip);
				ip++;
			} catch (std::out_of_range ex) {
				memory[mp] = ::input();
			}
		} else if (token == OUT) {
			std::cout << (int) memory[mp] << std::endl;
		} else if (token == LEFT) {
			mp--;
			if (mp < 0) {
				mp = memory_size - 1;
			}
		} else if (token == RIGHT) {
			mp++;
			if (mp > memory_size) {
				mp = 0;
			}
		} else if (token == LBRACE) {
			braces.push_back(i - 1);
		} else if (token == RBRACE) {
			if (memory[mp] != 0) {
				i = braces.back();
				braces.pop_back();
			} else {
				braces.pop_back();
			}
		}
		i++;
	}
	std::cout << "Done" << std::endl;
}

int input() {
    std::string input;
    std::getline(std::cin, input);
    return std::stoi(input);
}

std::vector<BrainFuck> parse(std::string &source) {
	std::string src(source);
	std::vector<BrainFuck> vec;
	std::cout << "Parsing: " << src << std::endl;
	src = std::regex_replace(src, std::regex(R"([a-zA-Z0-9\\'"?/}{)(*&\^%$#@! ]+)"), "");

	for (char tok : src) {
		switch (tok) {
			case '+':
				vec.push_back(PLUS);
				break;
			case '-':
				vec.push_back(MINUS);
				break;
			case '<':
				vec.push_back(LEFT);
				break;
			case '>':
				vec.push_back(RIGHT);
				break;
			case ',':
				vec.push_back(IN);
				break;
			case '.':
				vec.push_back(OUT);
				break;
			case '[':
				vec.push_back(LBRACE);
				break;
			case ']':
				vec.push_back(RBRACE);
				break;
			default:
				break;
		}
	}

	std::cout << "Parsed code: " << std::flush;

	for (BrainFuck tok : vec) {
		std::cout << token_index[tok] << std::flush;
	}

	std::cout << std::endl;

    return vec;
}

std::vector<int> parse_csv (std::string& source) {
	std::string src(source);
	src = std::regex_replace(src, std::regex(R"([A-Za-z<>_\-\+;:'"./? ]+)"), "");
	std::cout << "Parsing " << source << std::endl;

	std::vector<int> vec;
	std::string delimiter = ",";

	size_t pos = 0;
	std::string token;
	while ((pos = src.find(delimiter)) != std::string::npos) {
		token = src.substr(0, pos);
		std::stringstream ss;
		ss << token;
		int i = 0;
		ss >> i;
		std::cout << i << std::endl;
		vec.push_back(i);
		src.erase(0, pos + delimiter.length());
	}

	if (vec.size() == 0 && src.length() != 0) {
		std::stringstream ss;
		ss << src;
		int i = 0;
		ss >> i;
		vec.push_back(i);
	}

	for (int i : vec) {
		std::cout << i << ", " << std::flush;
	}

	std::cout << std::endl;

	return vec;
}
