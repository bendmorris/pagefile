package pagefile;

import sys.io.File;
import sys.io.FileInput;
import sys.io.FileOutput;
import sys.io.FileSeek;
import sys.FileSystem;

class PageFile
{
	static var BEGIN:FileSeek = FileSeek.SeekBegin;

	public static function load(path:String):PageFile
	{
		var file = new PageFile(path);
		file.readFileHeader();
		return file;
	}

	public static function create(path:String):PageFile
	{
		if (FileSystem.exists(path))
		{
			FileSystem.deleteFile(path);
		}
		var file = new PageFile(path);
		file.header = new FileHeader();
		file.writeFileHeader();
		return file;
	}

	public var pageSize:Int;
	public var pageHeaderSize:Int;
	public var pageDataSize(get, never):Int;
	inline function get_pageDataSize() return pageSize - pageHeaderSize;

	var path:String;
	var header:FileHeader;

	function new(path:String, pageSize:Int = 0x100, ?pageHeaderSize:Int = 0x10)
	{
		this.path = path;
		this.pageSize = pageSize;
		this.pageHeaderSize = pageHeaderSize;
	}

	public function readFileHeader()
	{
		var handle = File.read(path, true);
		header = FileHeader.read(handle);
		handle.close();
	}

	public function writeFileHeader()
	{
		var handle = File.update(path, true);
		handle.seek(0, BEGIN);
		header.write(handle);
		handle.close();
	}

	public function getReadHandle(page:Int = 0):FileInput
	{
		var handle = File.read(path, true);
		handle.seek(page * pageSize + pageHeaderSize, BEGIN);
		return handle;
	}

	public function getWriteHandle(page:Int = 0):FileOutput
	{
		var handle = File.update(path, true);
		handle.seek(page * pageSize + pageHeaderSize, BEGIN);
		return handle;
	}

	public function getFreePage():PageHeader
	{
		var header = new PageHeader();
		header.page = this.header.nextPage++;
		writeFileHeader();
		writePageHeader(header, true);
		return header;
	}

	public function getPageHeader(page:Int):PageHeader
	{
		var handle = File.read(path, true);
		handle.seek(page * pageSize, BEGIN);
		var header = PageHeader.read(handle);
		handle.close();
		// TODO: assert page number
		return header;
	}

	public function writePageHeader(header:PageHeader, truncate:Bool = false)
	{
		var handle = File.update(path, true);
		handle.seek(header.page * pageSize, BEGIN);
		header.write(handle);
		if (truncate)
		{
			handle.seek((header.page + 1) * pageSize - 1, BEGIN);
			handle.writeByte(0);
		}
		handle.close();
	}

	public function getPageReader(page:Int):PageReader
	{
		return new PageReader(this, page);
	}

	public function getPageWriter(page:Int):PageWriter
	{
		return new PageWriter(this, page);
	}

	public function recyclePage(page:Int)
	{
		inline function cachePage(prev:Int, next:Int)
		{
			if (prev == 0)
			{
				// this is the first cached free page
				var reader = getPageReader(page);
				reader.header.nextPage = next;
				this.header.freePageCache = page;
				writePageHeader(reader.header, true);
				reader.close();
				writeFileHeader();
			}
			else
			{
				// update previous page to point to this one
				var reader = getPageReader(prev);
				reader.header.nextPage = page;
				writePageHeader(reader.header);
				reader.close();
				// update this page to point to previous page's next page
				var reader = getPageReader(page);
				reader.header.nextPage = next;
				writePageHeader(reader.header);
				reader.close();
			}
		}

		var prev:Int = 0,
			current = header.freePageCache;
		while (true)
		{
			if (current <= 0 || page < current)
			{
				cachePage(prev, current);
				break;
			}
			else
			{
				var reader = getPageReader(page);
				prev = current;
				current = reader.header.nextPage;
				reader.close();
			}
		}
	}
}
