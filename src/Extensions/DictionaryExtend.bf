namespace System.Collections;

extension Dictionary<TKey, TValue>
{
	public Result<TKey> GetKey(TValue val) where bool: operator TValue == TValue
	{
		for(let key in this.Keys)
			if(val == this.GetValue(key))
				return key;
		return .Err;
	}
}