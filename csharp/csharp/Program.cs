using System;
using System.IO;
using System.Text;
using System.Collections;
using System.Collections.Generic;

namespace csharp
{
    public class Program
    {
        static String[] token_index = {"+", "-", ",", ".", "<", ">", "[", "]"};
        
        public static void Main(String[] args)
        {
            if (args.Length < 1)
            {
                Console.Error.WriteLine("Error: Expected at least 1 argument got none");
                Console.Error.WriteLine("Usage: mono [brainfuck_executable] [source_file] <csv_inputs>");
                System.Environment.Exit(-1);
            }

            String file = OpenFile(args[0]);

            Execute(file);
        }

        static String OpenFile(String source) 
        {
            try
            {
                using (FileStream fs = File.Open(source, FileMode.Open))
                {
                    byte[] b = new byte[1024];
                    UTF8Encoding temp = new UTF8Encoding(true);
                    StringBuilder sb = new StringBuilder();
                    while (fs.Read(b, 0, b.Length) > 0)
                    {
                        sb.Append(temp.GetString(b));
                    }
                    return sb.ToString();
                }
            } 
            catch (Exception ex)
            {
                Console.Error.WriteLine($"Error: Unable to read file {source}");
                System.Environment.Exit(-1);
                return "";
            }
        }

        static void Execute(String source)
        {
            ArrayList src = Parse(source);
            const int memorySize = 3000;
            char[] memory = new char[memorySize];
            for (int i = 0; i < memorySize - 1; i++)
            {
                memory[i] = '\0';
            }

            int memoryPointer = 0;
            int codePointer = 9;
            Stack braces = new Stack();
            while (codePointer < src.Count)
            {
                BrainFuck token = (BrainFuck) src[codePointer];
                switch (token)
                {
                    case BrainFuck.INC:
                        memory[memoryPointer]++;
                        break;
                    case BrainFuck.DEC:
                        memory[memoryPointer]--;
                        break;
                    case BrainFuck.SLF:
                        memoryPointer--;
                        break;
                    case BrainFuck.SRT:
                        memoryPointer++;
                        if (memoryPointer > memorySize)
                        {
                            memoryPointer = 0;
                        }

                        break;
                    case BrainFuck.IN:
                        memory[memoryPointer] = Input();
                        break;
                    case BrainFuck.OUT:
                        Console.WriteLine((int) memory[memoryPointer]);
                        break;
                    case BrainFuck.SJP:
                        braces.Push(codePointer - 1);
                        break;
                    case BrainFuck.JNZ:
                        if (memory[codePointer] != 0)
                        {
                            codePointer = (int) braces.Pop();
                        }
                        else
                        {
                            braces.Pop();
                        }
                        break;
                }

                codePointer++;
            }
        }

        static ArrayList Parse(String source)
        {
            ArrayList code = new ArrayList();

            Console.WriteLine($"Parsing code: {source}");

            foreach (char c in source.ToCharArray())
            {
                switch (c)
                {
                    case '+':
                        code.Add(BrainFuck.INC);
                        break;
                    case '-':
                        code.Add(BrainFuck.DEC);
                        break;
                    case '[':
                        code.Add(BrainFuck.SJP);
                        break;
                    case ']':
                        code.Add(BrainFuck.JNZ);
                        break;
                    case '>':
                        code.Add(BrainFuck.SRT);
                        break;
                    case '<':
                        code.Add(BrainFuck.SLF);
                        break;
                    case '.':
                        code.Add(BrainFuck.OUT);
                        break;
                    case ',':
                        code.Add(BrainFuck.IN);
                        break;
                    default:
                        break;
                }
            }
            
            Console.Write("Parsed code ");
            foreach (BrainFuck c in code)
            {
                Console.Write(token_index[(int) c]);
            }
            Console.Write("\n");
            return code;
        }

        static char Input()
        {
            while (true)
            {
                try
                {
                    Console.Write(">>> ");
                    String line = Console.ReadLine();
                    return (char) Int32.Parse(line);
                }
                catch (Exception)
                {
                    Console.WriteLine("Please enter a number");
                }
            }
        }
    }
}
