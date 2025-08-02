# FLAC Album Splitter

A bash script that automatically splits single FLAC music album files into individual song tracks using CUE sheet information.

## Why This Tool Exists

When digitizing an LP or ripping a CD to lossless format, the result is usually a single large FLAC file containing the entire music album, accompanied by a CUE sheet that defines individual song track boundaries. Popular ripping software like EAC (Exact Audio Copy), dBpoweramp, Whipper, and Rip Station often create these FLAC+CUE pairs to preserve perfect audio quality. While this format preserves the original recording perfectly, it's not convenient for modern music players that expect individual song files.

This script bridges that gap by:
- **Splitting** large music album files into individual song tracks
- **Preserving** audio quality (lossless FLAC-to-FLAC conversion)
- **Organizing** files with consistent naming (`01 - Song Title.flac`)
- **Sanitizing** filenames for cross-platform compatibility

## Features

- 🎵 **Lossless splitting** using shntool
- 📁 **Recursive processing** - automatically finds and processes all FLAC+CUE pairs in an entire directory tree
- 🔄 **Smart duplicate detection** (won't re-split already processed albums)
- 🖥️ **NTFS compatibility** (sanitizes problematic characters in track names)
- 🛡️ **Safe operation** (renames originals to `.del` instead of deleting)
- 📊 **Clear progress feedback** with status messages

## NTFS Filename Compatibility

The script automatically sanitizes CUE file song titles to ensure compatibility with Windows NTFS filesystems by replacing problematic characters:

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

### Installation of prerequisites on Ubuntu/Debian:
```bash
sudo apt-get install shntool flac
```

### Installation of prerequisites on macOS (with Homebrew):
```bash
brew install shntool flac
```

### Installation of prerequisites on Fedora/RHEL:
```bash
sudo dnf install shntool flac
```

## Installation

After installing the prerequisites above, you need to make the script available on your system:

### Option 1: System-wide installation (recommended)
```bash
sudo cp split_flac.sh /usr/local/bin/split_flac
sudo chmod +x /usr/local/bin/split_flac
```

### Option 2: User-specific installation (Ubuntu/most Linux distros)
```bash
mkdir -p ~/.local/bin
cp split_flac.sh ~/.local/bin/split_flac
chmod +x ~/.local/bin/split_flac
```

Make sure `~/.local/bin` is in your PATH (it usually is by default on modern Linux distributions).

## Usage

The power of this script lies in its recursive processing capability. Simply navigate to the top-level directory containing your music collection and run:

```bash
split_flac
```

The script will automatically:
- Traverse the entire directory tree recursively
- Find all music album FLAC+CUE file pairs at any depth
- Process each album it discovers
- Skip directories that have already been processed

This means you can organize your music collection like this:
```
Music/
├── Artist 1/
│   ├── Album A/
│   │   ├── Album A.flac
│   │   └── Album A.cue
│   └── Album B/
│       ├── Album B.flac
│       └── Album B.cue
└── Artist 2/
    └── Album C/
        ├── Album C.flac
        └── Album C.cue
```

And process everything with a single command from the `Music/` directory.

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
├── 01 - Opening Song.flac
├── 02 - Second Song.flac
├── 03 - Another Song.flac
├── Album Name.flac.del
└── Album Name.cue.del
```

## Safety Features

- **Non-destructive**: Original files are renamed to `.del`, not deleted
- **Skip protection**: Won't re-process directories that already contain split song tracks
- **Error handling**: Reports failures and leaves originals untouched on errors

## Cleanup

After verifying the split song tracks work correctly, you can remove the backup files:

```bash
find . -name "*.del" -delete
```

## License

MIT License - see the script header for full details.

## Contributing

Issues and pull requests welcome! This script was created to solve a common problem in digital music archiving and is compatible with FLAC+CUE files created by EAC, dBpoweramp, Whipper, Rip Station, and other popular ripping software.

## Alternative Names Considered

- `cue2tracks.sh`
- `flac_album_splitter.sh` 
- `split_cue_flac.sh`

The current name `split_flac.sh` was chosen for simplicity and clarity.

## Note

We have occasionally seen recordings consisting of .wv/.cue pairs (WavPack). This script currently does not split these. However, the underlying 'shntool' command that we are using supports the .wv format as well. The script could be modified to support .wv extensions, and the WavPack codecs can be installed with 'sudo apt-get install wavpack'.
