using System;
using System.Collections;

namespace CPU_6502.Assembler;

class Assembly
{
	public Word startAddress;
	public List<ASTNode> code;

	public this(String path)
	{
		var r = Parser.ReadLines(path);
		if (r case .Ok(let val))
			(this.code, this.startAddress) = val;

	}

	public ~this()
	{
		delete this.code;
	}

	public void Add(ASTNode a) => code.Add(a);

	public Byte[64 * 1024] Export()
	{
		Byte[64 * 1024] r = .();
		int i = this.startAddress - 1;

		Console.WriteLine($"startpos: {startAddress}");

		r[CPU.resetVector] = (Byte)startAddress;
		Console.WriteLine($"low byte: {r[CPU.resetVector]}");
		r[CPU.resetVector + 1] = (Byte)(startAddress >> 8);
		Console.WriteLine($"high byte: {r[CPU.resetVector + 1]}");


		for (var inst in this.code)
		{
			i++;
			r[i] = inst.instruction;
			switch(inst.argument)
			{
			case .Byte(let b):
				 i++;
				r[i] = b;
			case .Word(let w):
				i++;
				r[i] = (Byte)w;
				i++;
				r[i] = (Byte)(w >> 8);
			case .None:
			}
		}
		return r;
	}
}