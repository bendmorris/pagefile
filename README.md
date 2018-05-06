**pagefile** is an interface that makes it easy to create files consisting of multiple fixed-size pages. It provides the PageReader and PageWriter classes to easily read from or write to discontiguous sets of pages.

For example, if you have a game world that is too large to hold in memory at once:

- Write a map of (Tile ID => Page #) on Page 1.
- Every time you need a tile that you've never seen before, generate it and call `PageFile.getFreePage()` to get the next available page. Write your new tile to disk and keep it in memory.
- Keep the most recent N tiles visited in memory; when a tile gets stale, write its current state to disk and remove it from memory.
- When you come back to that tile, look it up in the index on page 1, and load that page back into memory.

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
