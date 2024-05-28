using System;

namespace CPU_6502.Utils;

public class Convert
{
	public static void ToBinary(Byte n, String outString)
	{
		for(int i = 0; i < 7; i++)
		{
			if(n & 1 << (7 - i) == 0)
				outString.Append("0");
			else
				outString.Append("1");
		}
	}
}