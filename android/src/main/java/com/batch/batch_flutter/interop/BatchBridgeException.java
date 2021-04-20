package com.batch.batch_flutter.interop;

/**
 * Exception representing internal bridge errors
 */
class BridgeException extends Exception
{
	BridgeException(String cause)
	{
		super(cause);
	}

	BridgeException(String cause, Throwable source)
	{
		super(cause, source);
	}
}
