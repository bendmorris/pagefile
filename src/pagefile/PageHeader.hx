package pagefile;

import haxe.io.Input;
import haxe.io.Output;

class PageHeader
{
	public static function read(input:Input):PageHeader
	{
		var header = new PageHeader();
		header.page = input.readInt32();
		header.nextPage = input.readInt32();
		return header;
	}

	public var page:Int = 0;
	public var nextPage:Int = 0;

	public function new() {}

	public function write(output:Output)
	{
		output.writeInt32(page);
		output.writeInt32(nextPage);
	}
}
