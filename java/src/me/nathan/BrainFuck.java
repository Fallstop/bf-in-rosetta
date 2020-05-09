package me.nathan;

public enum BrainFuck {
	INC("+"),
	DEC("-"),
	IN(","),
	OUT("."),
	SLF(">"),
	SRT("<"),
	SJP("["),
	JNZ("]");

	private String token;

	BrainFuck(String token) {
		this.token = token;
	}

	public String getToken() {
		return this.token;
	}
}
