using System;

namespace CPU_6502;

typealias Byte = uint8;
typealias Word = uint16;

struct Bit
{
	public bool bit;

	public this(bool a) => this.bit = a;
	

	public this(uint8 a)
	{
		if (a == 0)
			this.bit = false;
		else
			this.bit = true;
	}

	public static operator Bit (uint8 a) => .(a);

	public static operator Bit(bool b) => .(b);
}

struct Memory
{
	const uint32 MAX_MEM = 1024 * 64; // 64 Kb
	public Byte[MAX_MEM] data;

	public void Initialize() mut
	{
		for (uint32 i = 0; i < MAX_MEM; i++)
			this.data[i] = 0;
	}

	public Byte this[uint32 i]
	{
		get => data[i];
		set mut => data[i] = value;
	}

	public void WriteWord(Word val, uint32 addr, ref uint32 cycles) mut
	{
		//Console.WriteLine($"Writing word {val} at address {addr}...");
		this.WriteWord(val, addr);
		cycles -= 2;
	}

	public void WriteWord(Word val, uint32 addr) mut
	{
		//Console.WriteLine($"Writing word {val} at address {addr}...");
		data[addr] = (Byte)val;
		data[addr + 1] = (Byte)(val >> 8);
	}
}



class CPU
{

	//typealias Bit = bool; // sorry, no bits in beef
	// 64Kb memory | 16-bit address bus | 256 byte (0x0000-0x00FF) Zero Page | System Stack (0x0100-0x01FF)
	// 0xFFFA/B -> non-maskable interrupt handler | 0xFFFC/D -> power on reset | 0xFFFE/F BRK/interrupt request handler

	public Word PC; // Program Counter
	public Byte SP; // Stack Pointer // SHOULD BE BYTE

	public Byte A, X, Y; // Registers



	public Bit C, Z, I, D, B, V, N; // Processor status flags

	// opcodes
	public const Byte
		INS_LDA_IM = 0xA9,  /// Load Accumulator Immediate
		INS_LDA_ZP = 0xA5,  /// Load Accumulator Zero Page
		INS_LDA_ZPX = 0xB5, /// Load Accumulator Zero Page X

		INS_JSR = 0x20;     /// Jump to Subroutine

	

	public void Reset(ref Memory mem)
	{ // should code this but we emulate for now
		PC = 0xFFFC; // reset vector
		SP = (Byte)0x0100;
		C = Z = I = D = B = V = N = 0;
		A = X = Y = 0;
	}

	public Byte ReadByte(ref uint32 cycles, Byte address, ref Memory mem)
	{
		Byte data = mem[address]; 
		cycles--;
		return data;
	}

	public Byte FetchByte(ref uint32 cycles, ref Memory mem) // will rework to work with ReadByte
	{
		Byte data = mem[this.PC]; 
		this.PC++;
		cycles--;
		return data;
	}

	public Word FetchWord(ref uint32 cycles, ref Memory mem)
	{
		// 6502 is little endian
		Word data = mem[this.PC]; // Low byte
		this.PC++;
		cycles--;

		data |= ((Word)mem[this.PC]) << 8; // High byte
		this.PC++;
		cycles--;

		//Console.WriteLine($"Fetched word {data}...");

		return data;
	}


	void SetLDAFlags()
	{
		this.Z = this.A == 0;
		this.N = this.A & 0b10000000;
	}

	public void Execute(uint32 cycles, ref Memory mem)
	{
		var cycles;
		while(cycles > 0)
		{
			Byte instruction = this.FetchByte(ref cycles, ref mem);

			switch(instruction)
			{
			case INS_LDA_IM:
			do { // just in case i need to do stuff with scopes, doesn't add complexity
				Byte val = this.FetchByte(ref cycles, ref mem);
				this.A = val;
				this.SetLDAFlags();
			}

			case INS_LDA_ZP:
			do{
				Byte ZeroPageAddress = this.FetchByte(ref cycles, ref mem);
				this.A = this.ReadByte(ref cycles, ZeroPageAddress, ref mem);
				this.SetLDAFlags();
			}

			case INS_LDA_ZPX:
			do {
				Byte ZeroPageAddress = this.FetchByte(ref cycles, ref mem);
				ZeroPageAddress += this.X; cycles--; // cause we added
				this.A = this.ReadByte(ref cycles, ZeroPageAddress, ref mem);
				this.SetLDAFlags();
			}

			case INS_JSR:
			do{ // absolute mode, so need 16 bits
				Word jumpAddr = FetchWord(ref cycles, ref mem);
				mem.WriteWord(this.PC - 1, this.SP, ref cycles);
				this.PC = jumpAddr;
				this.SP++;
				cycles--;
			}

			}
		}
	}
}