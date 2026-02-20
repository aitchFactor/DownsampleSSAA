# DownsampleSSAA

Customisable downsampling for ReShade by PthoEastCoast and _aitchFactor

This fork of DownsampleSSAA was designed for use with N64 ports like Ship of Harkinian and 2Ship. The blur factor calculation has been retuned to leave integer scaled images unblurred at the default setting (1.0) while anti-aliasing everything else. However, some finagling is required for best results:
 - **Sampling offsets need to be aligned correctly.**
 - The downsampled resolution has to be the same as the intended display resolution of the integer scaled content.
 - The output resolution should be an integer scale of the original resolution. (Otherwise, slight blurring will occur.)

Additional settings have also been added for use with CRT filters like Sony Megatron - particularly, separate options for horizontal and vertical up/down-sampling. My favourite setting so far is to downsample vertically, keep the horizontal resolution native but blur it to the same clarity as the original resolution. Unnecessarily complex? Maybe. But it's worth it to me. See the included presets for a couple of examples, although keep in mind that they are intended for 1440p display of 240p content.

### Comparisons
Nearest neighbour
<img width="2560" height="1440" alt="soh 2025-11-30 00-46-47" src="https://github.com/user-attachments/assets/b3acc17f-3ea5-4aa0-8a0b-90812be74c4a" /> <img width="2560" height="1440" alt="soh 2025-11-30 00-25-18" src="https://github.com/user-attachments/assets/88e629d9-15aa-423d-a82c-e76e1e9fbe91" /> 
No downsampling
<img width="2560" height="1440" alt="soh 2025-11-30 00-40-35" src="https://github.com/user-attachments/assets/4b3ca761-ed5b-4b87-95c8-9bb730f2b298" /> <img width="2560" height="1440" alt="soh 2025-11-30 00-23-27" src="https://github.com/user-attachments/assets/757f6a28-83b9-4fc7-8e5f-45cb11d3e3c8" />  
CRT setup with Sony Megatron
<img width="2560" height="1440" alt="soh 2025-11-30 00-45-22" src="https://github.com/user-attachments/assets/077a7653-6eb2-45a7-9dee-3a15a7e038fc" /> <img width="2560" height="1440" alt="soh 2025-11-30 00-51-58" src="https://github.com/user-attachments/assets/b15b13da-ef2d-4f6d-8722-1f6edf7617ae" />

## Addendum - using with Dolphin
It is deceptively hard to make Dolphin output pixel-perfect video (The GameCube and Wii themselves natively outputted non-square, non-aligned pixels). Without additional ReShade shaders, it doesn't seem possible to have perfectly clean, nearest-neighbour scaled pixels that are correctly aligned to DownsampleSSAA, since the various nearest-neighbour-like scaling options also force a non-integer scale on the output. However, for a cleanly scaled output that matches the resolution of your monitor (allowing aligned, anti-aliased output with DownsampleSSAA) I was able to get satisfactory results with a monitor with an integer scale resolution of 480p (mine is 1440p) and the following settings: 
- Post-Processing Effect set to `integer_scaling`, with "Use non-integer width" and "Scale width to fit 16:9" enabled. 
- Output Resampling set to Default. (All other options seemingly override the `integer_scaling` effect.)
- Once the above two settings are set, change Internal Resolution to the largest size that fits on your display.
- Set DownsampleSSAA's `VerticalResolution` to 480 and `VerticalBlur` to 1.
- Set `HorizontalResolution` to the width of your display.
- Set `Horizontal Blur` to the scale of your display relative to 480p, or higher if you prefer.

You can expect the results to look like this. The black border is normal, since many games internally render fewer than 480 horizontal lines.
<img width="2560" height="1440" alt="Screenshot 2026-02-20 180907" src="https://github.com/user-attachments/assets/75dc78e1-093c-4e9a-81d2-911892b757c2" />

Note that I have only so far tested games with widescreen support. Non-widescreen games likely require different settings.
