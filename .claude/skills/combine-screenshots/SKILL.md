---
name: combine-screenshots
description: Combine multiple HDR AVIF screenshots into one by keeping the first image in full and appending the subtitle strip from each subsequent image below it. Use when the user wants to merge anime screenshots with subtitles.
user-invocable: true
allowed-tools: Bash, Read, Glob
argument-hint: <main-image> <subtitle-image>...
---

Combine multiple HDR AVIF screenshots into a single image. The first image is kept in full, and the subtitle region from each subsequent image is cropped and appended below in order.

## Arguments

All arguments are image paths. If bare filenames (no `/`), resolve relative to the current working directory.

- `$0` (required): The main image, kept in full.
- `$1`, `$2`, ... (at least one required): Subtitle source images. Only the bottom strip (subtitle region) of each is cropped and appended below.

## Steps

1. **Parse arguments.** Collect all arguments as an ordered list of image paths. There must be at least 2. Resolve bare filenames relative to the current working directory.

2. **Find a reference combined image.** Search the same directory as the inputs for an existing AVIF file whose basename contains `-` (the naming convention for combined images, e.g., `17.58-17.59.avif`). Use it to calculate the subtitle strip height. If multiple candidates exist, pick the first one found. If none exist, ask the user for a reference image path or an explicit subtitle height in pixels.

3. **Probe dimensions.** Use `ffprobe` to get the height of:
   - The main image (`main_h`)
   - The reference combined image (`ref_h`)
   - Compute: `subtitle_h = ref_h - main_h`
   - Validate `subtitle_h > 0`; abort if not.

4. **Probe HDR metadata.** Use `ffprobe` on the main image to read `color_space`, `color_transfer`, and `color_primaries`. These will be re-applied via the `setparams` filter.

5. **Build the ffmpeg filter graph.** For N input images (indices 0 through N-1):
   - Input 0 is used as-is: `[0:v]`
   - For each input i (1 through N-1), crop its subtitle strip from the bottom:
     `[i:v]crop=<width>:<subtitle_h>:0:<crop_y>[sub_i]`
     where `crop_y = image_height - subtitle_h`
   - Stack all parts vertically:
     `[0:v][sub_1][sub_2]...vstack=inputs=N,setparams=color_primaries=<p>:color_trc=<t>:colorspace=<cs>[out]`

6. **Run ffmpeg.**

   ```bash
   ffmpeg -y \
     -i <image_0> -i <image_1> ... -i <image_N-1> \
     -filter_complex "<filter_graph>" \
     -map "[out]" \
     -c:v libaom-av1 -crf 20 -still-picture 1 \
     <output-path>
   ```

7. **Output filename.** Strip `.avif` from the first and last input filenames, join with `-`, append `.avif`. Middle filenames are omitted. Place in the same directory.
   - 2 images: `23.19.avif` + `23.22.avif` → `23.19-23.22.avif`
   - 3 images: `23.19.avif` + `23.20.avif` + `23.21.avif` → `23.19-23.21.avif`

8. **Verify.** Run `ffprobe` on the output to confirm:
   - Width matches source images.
   - Height equals `main_h + subtitle_h * (N - 1)`.
   - HDR metadata (`color_space`, `color_transfer`, `color_primaries`) is preserved.
   - Report the result.
