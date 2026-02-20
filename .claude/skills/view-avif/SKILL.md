---
name: view-avif
description: View AVIF images by converting them to WebP in a temp directory. Use when you need to read or view AVIF files that Claude Code cannot natively display.
user-invocable: true
allowed-tools: Bash, Read, Glob
argument-hint: <image-path>...
---

View one or more AVIF images by converting them to WebP via ImageMagick, then reading the converted files.

## Limitations

- **HDR to SDR tone-mapping.** AVIF files with HDR metadata (BT.2020, PQ / HLG transfer) are tone-mapped to SDR during conversion, since WebP does not support HDR. Colors and highlights will not be accurate to the original. This is acceptable for identifying scene content, reading subtitles, and understanding composition.
- **Downscaled for preview.** Images wider than 1920px are resized to 1920px width (preserving aspect ratio) to reduce file size and token cost.

## Arguments

All arguments are AVIF image paths. If bare filenames (no `/`), resolve relative to the current working directory. Glob patterns are also accepted (e.g., `assets/*.avif`).

- `$0` (required): First AVIF image path.
- `$1`, `$2`, ... (optional): Additional AVIF image paths.

## Steps

1. **Resolve paths.** Expand any glob patterns. Verify each file exists and has an `.avif` extension.

2. **Create temp directory.**

   ```bash
   mkdir -p /tmp/claude-avif-preview
   ```

3. **Convert each AVIF to WebP.** For each input file, convert using ImageMagick with downscaling:

   ```bash
   magick <input.avif> -resize '1920x>' /tmp/claude-avif-preview/<basename>.webp
   ```

   - `-resize '1920x>'` only shrinks images wider than 1920px; smaller images are untouched.
   - Use the original filename's basename (replacing `.avif` with `.webp`) to keep track of which file is which.

4. **Read each converted WebP.** Use the Read tool on each `/tmp/claude-avif-preview/<basename>.webp` file. This displays the image content to the conversation.

5. **Clean up.** Remove the temp files after reading:

   ```bash
   rm /tmp/claude-avif-preview/<basename>.webp
   ```

6. **Report.** State which images were displayed. If any conversions failed, report the errors.
