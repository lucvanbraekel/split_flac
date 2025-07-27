# FLAC Album Splitter

A bash script that automatically splits single FLAC album files into individual tracks using CUE sheet information.

## Why This Tool Exists

Many vinyl LP and CD rips come as single large FLAC files accompanied by CUE sheets that define track boundaries. While this format preserves the original recording perfectly, it's not convenient for modern music players that expect individual track files.

This script bridges that gap by:
- **Splitting** large FLAC albums into individual tracks
- **Preserving** audio quality (lossless FLAC-to-FLAC conversion)
- **Organizing** files with consistent naming (`01 - Track Name.flac`)
- **Sanitizing** filenames for cross-platform compatibility

## Features

- 🎵 **Lossless splitting** using shntool
- 📁 **Recursive processing** of directory trees
- 🔄 **Smart duplicate detection** (won't re-split already processed albums)
- 🖥️ **NTFS compatibility** (sanitizes problematic characters in track names)
- 🛡️ **Safe operation** (renames originals to `.del` instead of deleting)
- 📊 **Clear progress feedback** with status messages

## NTFS Filename Compatibility

The script automatically sanitizes CUE file track titles to ensure compatibility with Windows NTFS filesystems by replacing problematic characters:

| Character | Replacement | Reason |
|-----------|-------------|---------|
| `?` `*` `<` `>` `\|` `/` `\` `:` | `-` | Reserved/illegal in Windows filenames |
| Curly quotes (`'` `'`) | `-` | Encoding issues across systems |

This ensures your music library works seamlessly whether you're on Linux, macOS, or Windows.

## Prerequisites

The script requires these tools to be installed:

- **shntool** - for splitting audio files
- **flac** - for FLAC codec support
- Standard Unix tools (`sed`, `find`, `basename`, etc.)

### Installation on Ubuntu/Debian:
```bash
sudo apt-get install shntool flac
```

### Installation on macOS (with Homebrew):
```bash
brew install shntool flac
```

### Installation on Fedora/RHEL:
```bash
sudo dnf install shntool flac
```

## Usage

1. Place the script in a directory containing FLAC+CUE file pairs
2. Make it executable:
   ```bash
   chmod +x split_flac.sh
   ```
3. Run it:
   ```bash
   ./split_flac.sh
   ```

The script will:
- Find all `.cue` files in the current directory and subdirectories
- Look for matching `.flac` or `.FLAC` files
- Split each album into numbered tracks: `01 - Song Title.flac`
- Rename processed originals with `.del` extension

## File Structure

**Before:**
```
Album/
├── Album Name.flac
└── Album Name.cue
```

**After:**
```
Album/
├── 01 - Opening Track.flac
├── 02 - Second Song.flac
├── 03 - Another Track.flac
├── Album Name.flac.del
└── Album Name.cue.del
```

## Safety Features

- **Non-destructive**: Original files are renamed to `.del`, not deleted
- **Skip protection**: Won't re-process directories that already contain split tracks
- **Error handling**: Reports failures and leaves originals untouched on errors

## Cleanup

After verifying the split tracks work correctly, you can remove the backup files:

```bash
find . -name "*.del" -delete
```

## License

MIT License - see the script header for full details.

## Contributing

Issues and pull requests welcome! This script was created to solve a common problem in digital music archiving.

## Alternative Names Considered

- `cue2tracks.sh`
- `flac_album_splitter.sh` 
- `split_cue_flac.sh`

The current name `split_flac.sh` was chosen for simplicity and clarity.
