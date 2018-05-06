package pagefile;

import haxe.io.Eof;
import haxe.io.Input;
import sys.io.FileInput;

class PageReader extends Input
{
	static var eof = new Eof();

	var file:PageFile;
	var page:Int = 0;
	var cursor:Int = 0;
	@:allow(pagefile.PageFile) var header:PageHeader;
	var readHandle:FileInput;
	var defunct:Bool = false;

	public function new(file:PageFile, page:Int)
	{
		this.file = file;
		this.page = page;
		header = file.getPageHeader(page);
		readHandle = file.getReadHandle(page);
	}

	override public function readByte():Int
	{
		if (defunct)
		{
			throw "attempt to read from recycled page";
		}
		if (cursor++ >= file.pageDataSize)
		{
			if (header.nextPage > 0)
			{
				readHandle.close();
				page = header.nextPage;
				header = file.getPageHeader(page);
				readHandle = file.getReadHandle(page);
			}
		}
		return readHandle.readByte();
	}

	public function recycle()
	{
		file.recyclePage(page);
		defunct = true;
	}

	override public function close()
	{
		readHandle.close();
	}
}
