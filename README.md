**pagefile** is an interface that makes it easy to create files consisting of multiple fixed-size pages. It provides the PageReader and PageWriter classes to easily read from or write to discontiguous sets of pages.

This requires the [`sys.io.File.update`](https://github.com/HaxeFoundation/haxe/commit/476d180548630cef93ebc635175ef80eefde5176) method which is currently available in Haxe development builds.

To use:

```haxe
import pagefile.PageFile;

// Create the file if it doesn't exist
var myFile = new PageFile("/tmp/filepath");

// Get an Output for writing to the next available page. If you write past the
// next page boundary, a new page will be allocated automatically and linked to
// this one.
var writer = myFile.getFreePage();
writer.writeByte(5);
writer.close();

// Open an Input for a specific page. The Input will automatically seek to the
// next page as necessary.
var reader = myFile.getPageReader(1);
trace(reader.readByte());
reader.close()
```
