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

