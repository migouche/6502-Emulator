namespace System
{
	extension Test
	{
		public static void AssertEq<T>(T value, T expected, String error = Compiler.CallerExpression[0], String filePath = Compiler.CallerFilePath, int line = Compiler.CallerLineNum) where bool: operator T == T
		{
			if(expected != value)
			{
				if (Runtime.CheckErrorHandlers(scope Runtime.AssertError(.Test, error, filePath, line)) == .Ignore)
					return;
				String failStr = scope .()..AppendF("AssertEq failed: Expected value {} but got {}: {} at line {} in {}", expected, value,  error, line, filePath);
				Internal.[Friend]Test_Error(failStr);
			}
		}
	}
}

/*
public static void Assert(bool condition, String error = Compiler.CallerExpression[0], String filePath = Compiler.CallerFilePath, int line = Compiler.CallerLineNum) 
{
	if (!condition)
	{
		if (Runtime.CheckErrorHandlers(scope Runtime.AssertError(.Test, error, filePath, line)) == .Ignore)
			return;
		String failStr = scope .()..AppendF("Assert failed: {} at line {} in {}", error, line, filePath);
		Internal.[Friend]Test_Error(failStr);
	}
}
*/


