package pagefile;

import haxe.io.Input;
import haxe.io.Output;

class FileHeader
{
	public static function read(input:Input):FileHeader
	{
		var header = new FileHeader();
		header.version = input.readInt32();
		header.nextPage = input.readInt32();
		header.freePageCache = input.readInt32();
		return header;
	}

	public var version:Int = 1;
	public var nextPage:Int = 1;
	public var freePageCache:Int = 0;

	public function new() {}

	public function write(output:Output)
	{
		output.writeInt32(version);
		output.writeInt32(nextPage);
		output.writeInt32(freePageCache);
	}
}
