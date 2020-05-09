package me.nathan;

import java.io.File;
import java.util.ArrayList;
import java.util.Scanner;
import java.util.Stack;

public class Main {
	public static void main(String[] args) {
		if (args.length < 1) {
			System.err.println("Expected more than one argument");
			System.err.println("Usage: [interpreter] [source_file] <csv_file>");
			System.exit(-1);
		}

		String file = openFile(args[0]);

		if (args.length == 1) {
			execute(file);
		} else {
			String inputs = openFile(args[1]);
			execute(file, inputs);
		}
		System.out.println("Done!");
	}

	public static String openFile(String path) {
		File file = new File(path);

		try {
			Scanner scanner = new Scanner(file);
			StringBuilder str = new StringBuilder();

			while (scanner.hasNext()) {
				str.append(scanner.nextLine());
			}

			scanner.close();
			return str.toString();
		} catch (Exception ignored) {
			System.err.println("Error, cant open file " + file.getAbsolutePath());
			System.exit(-1);
		}

		return "";
	}

	public static void execute(String str) {
		ArrayList<BrainFuck> source = parse(str);
		final int ms = 30000;
		char memory[] = new char[ms];
		for (int i = 0; i < ms - 1; i++) {
			memory[i] = 0;
		}

		int mp = 0;

		int i = 0;

		Stack<Integer> braces = new Stack<>();

		while (i < source.size()) {
			BrainFuck token = source.get(i);
			if(token == BrainFuck.IN) {
				System.out.print(">>> ");
				memory[mp] = (char) new Scanner(System.in).nextInt();
			} else if (token == BrainFuck.OUT) {
				System.out.println((int) memory[mp]);
			} else if (token == BrainFuck.SLF) {
				mp++;
				if (mp >= ms) {
					mp = 0;
				}
			} else if (token == BrainFuck.SRT) {
				mp--;
				if (mp < 0) {
					mp = ms - 1;
				}
			} else if (token == BrainFuck.DEC) {
				memory[mp]--;
			} else if (token == BrainFuck.INC) {
				memory[mp]++;
			} else if (token == BrainFuck.SJP) {
				braces.push(i - 1);
			} else if (token == BrainFuck.JNZ){
				if (memory[mp] != 0) {
					i = braces.pop();
				} else {
					braces.pop();
				}
			}

			i++;
		}
	}

	public static void execute(String src, String input) {
		ArrayList<BrainFuck> source = parse(src);
		ArrayList<Integer> inputs = parseCSV(input);

		final int ms = 30000;
		char memory[] = new char[ms];
		for (int i = 0; i < ms - 1; i++) {
			memory[i] = 0;
		}

		int mp = 0;

		int i = 0;

		int input_pointer = 0;

		Stack<Integer> braces = new Stack<>();

		while (i < source.size()) {
			BrainFuck token = source.get(i);
			if(token == BrainFuck.IN) {
				try {
					memory[mp] = (char) inputs.get(input_pointer).intValue();
					System.out.println("Inputting " + inputs.get(input_pointer).intValue());
					input_pointer++;
				} catch (Exception ignored) {
					System.err.print("Error: not enough inputs, falling back to console input");
					System.out.print(">>> ");
					memory[mp] = (char) new Scanner(System.in).nextInt();
				}
			} else if (token == BrainFuck.OUT) {
				System.out.println((int) memory[mp]);
			} else if (token == BrainFuck.SLF) {
				mp++;
				if (mp >= ms) {
					mp = 0;
				}
			} else if (token == BrainFuck.SRT) {
				mp--;
				if (mp < 0) {
					mp = ms - 1;
				}
			} else if (token == BrainFuck.DEC) {
				memory[mp]--;
			} else if (token == BrainFuck.INC) {
				memory[mp]++;
			} else if (token == BrainFuck.SJP) {
				braces.push(i - 1);
			} else if (token == BrainFuck.JNZ){
				if (memory[mp] != 0) {
					i = braces.pop();
				} else {
					braces.pop();
				}
			}

			i++;
		}
	}

	public static ArrayList<BrainFuck> parse(String src) {
		System.out.println("Reading source code: " + src);
		ArrayList<BrainFuck> list = new ArrayList<>();
		for (int i = 0; i < src.length(); i++) {
			char c = src.charAt(i);
			switch (c) {
				case '+':
					list.add(BrainFuck.INC);
					break;
				case '-':
					list.add(BrainFuck.DEC);
					break;
				case '.':
					list.add(BrainFuck.OUT);
					break;
				case ',':
					list.add(BrainFuck.IN);
					break;
				case '<':
					list.add(BrainFuck.SLF);
					break;
				case '>':
					list.add(BrainFuck.SRT);
					break;
				case '[':
					list.add(BrainFuck.SJP);
					break;
				case ']':
					list.add(BrainFuck.JNZ);
					break;
				default:
					break;
			}
		}

		System.out.print("Parsed: ");

		for (BrainFuck token : list) {
			System.out.print(token.getToken());
		}

		System.out.print("\n");

		return list;
	}

	public static ArrayList<Integer> parseCSV(String src) {
		ArrayList<Integer> list = new ArrayList<>();

		src = src.replaceAll("[a-zA-Z \"':;!@#$%^/><.\"[\"\"]\" ]+", "");
		String[] inputs = src.split(",");
		if (inputs.length < 1 && src.length() != 0) {
			try {
				int item = Integer.parseInt(src);
				list.add(item);
			} catch (Exception ignored) {

			}
		} else {
			for (String value : inputs) {
				try {
					int i = Integer.parseInt(value);
					list.add(i);
				} catch (Exception ignored) {
					System.err.println("Error parsing " + value + " to int");
				}
			}
		}
		return list;
	}
}
