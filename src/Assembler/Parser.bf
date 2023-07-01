using System;
using System.IO;
using System.Collections;

namespace CPU_6502.Assembler;



public static class Parser
{
	public static var relatives = new List<String>() {"BMI", "BPL"};

	public static ~this()
	{
		delete relatives;
	}

	public static Result<(List<ASTNode>, (Word, String)), String> ReadLines(String path, bool verbose = false)
	{
		String text = scope .();
		List<ASTNode> l = new .();
		var r = File.ReadAllText(path, text);
		Word startAdd = 0x0200;
		String interruptLabel = new .();
		switch(r)
		{
		case .Err(let err):
			if (verbose)
			 	Console.WriteLine($"Error: {err}. Remember the working directory is {Directory.GetCurrentDirectory(.. scope .())}");
			return .Err("cant find file");
		case .Ok:
			int i = 0;
			text.ToUpper();
			for (let val in text.Split('\n'))
			{
				var val;
				if (val.StartsWith(';'))
					continue;
				if (val.Contains(';'))
				{
					for(int v = 0; v < val.Length; v++)
					{
						if(val[v] == ';')
						{
							val.RemoveToEnd(v);
							break;
						}
					}
				}


				if(val.Contains(".org") || val.Contains(".ORG"))
				{
					if(verbose)
						Console.WriteLine("Found .org");

					int j = 0;
					for (let split in val.Split(' '))
						if(j++ == 1)
						{
							var s = scope String(split);
							s.Remove(0);
							var o = Int32.Parse(s, System.Globalization.NumberStyles.HexNumber);
							switch (o)
							{
							case .Ok(let st):
								if(verbose)
									Console.WriteLine($".org {st}");
								if (st > 0xffff)
									return .Err("Number must not be greater than 0xFFFF");
								startAdd = (Word)st;
							case .Err:
								return .Err("Error parsing number");
							}
						}
					if(verbose)
						Console.WriteLine($"{i}: .org {startAdd}");
					i++;
					continue;
				}

				if(val.Contains(".brk") || val.Contains(".BRK"))
				{
					if (verbose)
						Console.WriteLine("Found .brk");
				 	List<String> lbls = scope List<String>();
					defer lbls.ClearAndDeleteItems();
					for (var split in val.Split(' '))
						if (!split.IsEmpty)
							lbls.Add(new .(split));

					if (lbls.Count != 2)
						return .Err(".brk must have only one label");
					delete interruptLabel;
					interruptLabel = new .(lbls[1]);
					if (verbose)
						Console.WriteLine($"brk label: {interruptLabel}");
					if(verbose)
						Console.WriteLine($"{i}: .brk label: {interruptLabel}");
					i++;
					continue;
				}

				if(val.IsWhiteSpace)
					continue;
				if (verbose)
					Console.WriteLine($"{i}: {val}");
				var inst = ParseLine(scope String(val), verbose);
				switch (inst)
				{
				case .Err(let err):
					if(verbose)
						Console.WriteLine(err);
					return .Err("Error while Parsing");

				case .Ok(let ins):
					if(verbose)
						Console.WriteLine($"Instruction: {ins.instruction}, Argument: {ins.argument}");
					l.Add(ins);
				}
			}
			return .Ok((l, (startAdd, interruptLabel)));
		}
	}

	public static Result<ASTNode, String> ParseLine(String line, bool verbose = false)
	{
		var line;
		List<String> l = scope .();
		defer l.ClearAndDeleteItems(); // defer is really neat
		String label = "";
		List<String> la = scope .();
		defer la.ClearAndDeleteItems();

		if(line.Contains(':')) // we got label
		{


			for(var las in line.Split(':'))
				la.Add(new String(las));
			if (la.Count != 2)
				return .Err("Line may only contain one label");
			label = la[0];
			if(verbose)
				Console.WriteLine($"Label: {label}");
			line = la[1];
			if(verbose)
				Console.WriteLine($"Without label: {line}");
		}
		
		//if(verbose)
			//Console.WriteLine($"line after parse: {la[1]}");
		if (verbose && label.Length > 0)
			Console.WriteLine($"label: {label}");

		for (var s in line.Split(' '))
		{
			if(s.Length > 0)
			{
				if (verbose)
					Console.WriteLine($"adding \"{s}\" ");
				l.Add(new String(s));
			}
		}

		if (l.Count > 2 || l.Count == 0)
			return .Err("More than 2 blocks or 0 blocks");

		if(l.Count == 1) //
		{
			return .Ok(InstructionToASTNode(Instruction(l[0], .Implied), .None, label, true));
		}
		else if (l.Count == 2)
		{
			var result = GetArgument(l[0], l[1], verbose);
			switch(result)
			{
			case .Err(let err):
				return .Err(err);
			case .Ok(let val):
				var (arg, op) = val;
				var ins = InstructionToASTNode(Instruction(l[0], op), arg, label, true);
				switch (ins)
				{
				case .Ok(let val5): return .Ok(val5);
				case .Err: return .Err("Instruction not found");
				}
			}
		}
		
		return .Ok(new .(0)); // FIXME
	}

	public static Result<ASTNode, String> InstructionToASTNode(Instruction i, Argument a, String l, bool verbose = false)
	{
		var r = AST.codes.GetValue(i);
		switch (r)
		{
		case .Err:
			return .Err("Instruction not found");
		case .Ok(let val):
			return .Ok(new .(val.instruction, a, l, verbose));
		}
	}

	public static Result<(Argument, OpMode), String> GetArgument(String instName, String argName, bool verbose = false)
	{
		if(argName == "A" || argName == "a")
		{
			return .Ok((.None, .Accumulator));
		}
		switch(argName[0])
		{
		case '#': // should be immediate
			argName.Remove(0); // more checks please :)
			if (argName[0] != '$')
				return .Err("All numbers must begin with $, so they are hex");
			argName.Remove(0);
			int n = Int32.Parse(argName, System.Globalization.NumberStyles.HexNumber);
			if (n > 0xFF)
				return .Err($"number must not be greater than 0xFF");
			return .Ok((.Byte((Byte)n), .Immediate));
		case '$': // direct memory addressing
			argName.Remove(0);
			argName.Replace(" ", "");
			List<String> l = scope .();
			defer l.ClearAndDeleteItems();

			for (var val in argName.Split(','))
				l.Add(new String(val));

			var r_mem = Int32.Parse(l[0], System.Globalization.NumberStyles.HexNumber);
			if (r_mem case .Err(let err))
				return .Err("Error parsing number");
			int mem = 0;
			if (r_mem case .Ok(let val))
				mem = val;

			
			if (l.Count == 1)
			{
				if (mem <= 0xFF)
					return .Ok((.Byte((Byte)mem), .ZeroPage));
				if (mem <= 0xFFFF)
					return .Ok((.Word((Word)mem), .Absolute));
				return .Err("Value must not be greater than 0xFFFF to be absolute or 0xFF to be ZeroPage");
				
			}
			else if (l.Count == 2)
			{

				if (l[1] == "x" || l[1] == "X")
				{
					if (mem <= 0xFF)
						return .Ok((.Byte((Byte)mem), .ZeroPageX));
					if (mem <= 0xFFFF)
						return .Ok((.Word((Word)mem), .AbsoluteX));
					return .Err("Value must not be greater than 0xFFFF to be absolute or 0xFF to be ZeroPage");
				}
				else if (l[1] == "y" || l[1] == "Y")
				{
					if (mem <= 0xFF)
						return .Ok((.Byte((Byte)mem), .ZeroPageY));
					if (mem <= 0xFFFF)
						return .Ok((.Word((Word)mem), .AbsoluteY));
					return .Err("Value must not be greater than 0xFFFF to be absolute or 0xFF to be ZeroPage");
				}
				else
					return .Err("Instruction may only be indexed by x or y");
			}
		case '(':
			if(!argName.Contains(')'))
				return .Err("Instruction must close parenthesis");

			argName.Replace(" ", "");
			List<String> l = scope .();
			List<String> l2 = scope .();
			defer l.ClearAndDeleteItems();
			defer l2.ClearAndDeleteItems();

			for (var val in argName.Split("(", ")"))
			{
				if(val.Length > 0)
					l.Add(new String(val));
			}

			if (l[0][0] != '$')
				return .Err("Number must begin with '$' so that it is Hex");
			l[0].Remove(0);
			
			if (l.Count == 1)
			{
				
				if(l2.Count == 1)
				{
					var r = Int32.Parse(l2[0], System.Globalization.NumberStyles.HexNumber);
					switch (r)
					{
					case .Err:
						return .Err("Error Parsing number");
					case .Ok(let val3):
						if (val3 > 0xFFFF)
							return .Err("Number may not be greater than 0xFFFF");
						return .Ok((.Word((Word)val3), .AbsoluteIndirect));
					}
				}
				for(var val2 in l[0].Split(','))
					l2.Add(new String (val2));
				if(l2.Count > 2)
					return .Err("Indirect Addressing must be indexed by one or no registers");
				if (l2[1] != "x" && l2[1] != "X")
					return .Err("Indexing Zero Page in Indirect Addressing may only be indexed by X");
				var r = Int32.Parse(l2[0], System.Globalization.NumberStyles.HexNumber);
				switch(r)
				{
				case .Err(let err):
					return .Err("Error parsing number");
				case .Ok(let val3):
					if (val3 > 0xFFFF)
						return .Err("Number may not be greater than 0xFFFF");
					return .Ok((.Word((Word)val3), .ZeroPageIndirectX));
				}
				
			}

			if(l.Count == 2)
			{
				for(var val2 in l[1].Split(','))
					if(val2.Length > 0)
						l2.Add(new String (val2));

				if(l2[0] != "y" && l2[0] != "Y")
					return .Err("Indexing Absolute position in Indirect Zero Paging may only be indexed by Y");
				var r = Int32.Parse(l[0], System.Globalization.NumberStyles.HexNumber);
				switch (r)
				{
				case .Err:
					return .Err("Error parsing number");
				case .Ok(let val4):
					if (val4 > 0xFFFF)
						return .Err("Number may not be greater than 0xFFFF");
					return .Ok((.Word((Word)val4), .ZeroPageInirectY));
				}

			}
		default: // should be a label
			if (verbose)
				Console.WriteLine($"returning label {argName}");

			if(relatives.Contains(instName))
			{
				if(verbose)
					Console.Write($"{instName} in relative instructions");
				return .Ok((.Label(.(new .(argName), .Relative)), .Relative));
			}

			Console.WriteLine($"{instName} not in relative instructions");

			return .Ok((.Label(.(new .(argName), .Absolute)), .Absolute));
			
		}

		return .Err("Unknown Parsing Error");
	}
}