using System;
using System.IO;
using System.Collections;

namespace CPU_6502.Assembler;



public static class Parser
{
	public static Result<(List<ASTNode>, Word), String> ReadLines(String path, bool verbose = false)
	{
		String text = scope .();
		List<ASTNode> l = new .();
		var r = File.ReadAllText(path, text);
		Word startAdd = 0x0200;
		switch(r)
		{
		case .Err(let err):
			if (verbose)
			 	Console.WriteLine($"Error: {err}. Remember the working directory is {Directory.GetCurrentDirectory(.. scope .())}");
			return .Err("cant find file");
		case .Ok:
			int i = 0;
			for (let val in text.Split('\n'))
			{
				if(i++ == 0 && (val.Contains(".org") || val.Contains(".ORG")))
				{
					Console.WriteLine(".org");
					int j = 0;
					for (let split in val.Split(' '))
						if(j++ == 1)
						{
							var s = scope String(split);
							s.Remove(0);
							var o = Int32.Parse(s, System.Globalization.NumberStyles.HexNumber);
							if(o case .Ok(let st))
							{
								Console.WriteLine($"st: {st}");
								startAdd = (Word)st;
							}
						}
					if(verbose)
						Console.WriteLine($"{i}: .org {startAdd}");
					continue;

				}
				if(val.IsWhiteSpace)
					continue;
				if (verbose)
					Console.WriteLine($"{i}: {val}");
				var inst = ParseLine(scope String(val));
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
			return .Ok((l, startAdd));
		}
	}

	public static Result<ASTNode, String> ParseLine(String line)
	{
		List<String> l = scope .();
		defer l.ClearAndDeleteItems(); // defer is really neat
		for (var s in line.Split(' '))
		{
			l.Add(new String(s));
		}

		if (l.Count > 2 || l.Count == 0)
			return .Err("More than 2 blocks or 0 blocks");

		if(l.Count == 1) //
		{
			return InstructionToASTNode(Instruction(l[0], .Implied), .None);
		}
		else if (l.Count == 2)
		{
			var result = GetArgument(l[1]);
			switch(result)
			{
			case .Err(let err):
				return .Err(err);
			case .Ok(let val):
				var (arg, op) = val;
				return InstructionToASTNode(Instruction(l[0], op), arg);
			}
		}
		
		return .Ok(ASTNode(0)); // FIXME
	}

	public static Result<ASTNode, String> InstructionToASTNode(Instruction i, Argument a)
	{
		var r = AST.codes.GetValue(i);
		switch (r)
		{
		case .Err:
			return .Err("Instruction not found");
		case .Ok(let val):
			return .Ok(ASTNode(val.instruction, a));
		}
	}

	public static Result<(Argument, OpMode), String> GetArgument(String s)
	{
		switch(s[0])
		{
		case '#': // should be immediate
			s.Remove(0); // more checks please :)
			if (s[0] != '$')
				return .Err("All numbers must begin with $, so they are hex");
			s.Remove(0);
			int n = Int32.Parse(s, System.Globalization.NumberStyles.HexNumber);
			if (n > 0xFF)
				return .Err($"number must not be greater than 0xFF");
			return .Ok((.Byte((Byte)n), .Immediate));
		case '$': // direct memory addressing
			s.Remove(0);
			s.Replace(" ", "");
			List<String> l = scope .();
			defer l.ClearAndDeleteItems();

			for (var val in s.Split(','))
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
			if(!s.Contains(')'))
				return .Err("Instruction must close parenthesis");

			s.Replace(" ", "");
			List<String> l = scope .();
			List<String> l2 = scope .();
			defer l.ClearAndDeleteItems();
			defer l2.ClearAndDeleteItems();

			for (var val in s.Split("(", ")"))
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
			
		}

		return .Err("Unknown Parsing Error");
	}
}