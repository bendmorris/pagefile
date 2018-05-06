package pagefile;

import haxe.io.Output;
import sys.io.FileInput;
import sys.io.FileOutput;

class PageWriter extends Output
{
	var file:PageFile;
	var page:Int = 0;
	var cursor:Int = 0;
	var header:PageHeader;
	var writeHandle:FileOutput;
	var defunct:Bool = false;

	public function new(file:PageFile, page:Int)
	{
		this.file = file;
		this.page = page;
		header = file.getPageHeader(page);
		writeHandle = file.getWriteHandle(page);
	}

	override public function writeByte(c:Int)
	{
		if (defunct)
		{
			throw "attempt to write to recycled page";
		}
		if (cursor++ >= file.pageDataSize)
		{
			// get new page
			if (header.nextPage > 0)
			{
				page = header.nextPage;
			}
			else
			{
				var newHeader = file.getFreePage();
				header.nextPage = newHeader.page;
				file.writePageHeader(header);
				header = newHeader;
				page = header.page;
			}
			writeHandle.close();
			writeHandle = file.getWriteHandle(page);
			cursor -= file.pageDataSize;
		}
		writeHandle.writeByte(c);
	}

	public function recycle()
	{
		file.recyclePage(page);
		defunct = true;
	}

	override public function close()
	{
		writeHandle.close();
	}
}
