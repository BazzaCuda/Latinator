# Latinator
 
Whitaker's Words on Steroids: re-engineered, rewritten, expanded. 
Noun and Verb tables, Lewis & Short Dictionary lookup. Now with added macrons!
---

This is intended to be a Delphi/Latin Community project, so Pull Requests are not only welcome but invited and encouraged.

Run Latinator.exe directly from your file manager software, not from a command prompt, as it creates its own console window.
A GUI version will follow once the full Latin-English and English-Latin engine/pipeline is deemed acceptable and fully reliable.

Entering a single word will give you both the Whitaker's Words and the full Lewis & Short Dictionary entries:
<img width="1222" height="675" alt="image" src="https://github.com/user-attachments/assets/13ebc417-f1e3-462d-a2d9-c015752f9547" />

Entering a series of Latin words will give you the Whitaker's Words data for each word
<img width="1225" height="331" alt="image" src="https://github.com/user-attachments/assets/21fdccd7-73bb-4ce9-8f4a-6ec449600691" />

There are several built-in console commands, for example:

"ww" will give you just the Whitaker's Words entries for the Latin words that follow:
<img width="1226" height="681" alt="image" src="https://github.com/user-attachments/assets/dc4e0956-dced-4eba-bf1b-f1d0aee06905" />

"ls" will give you just the Lewis & Short Dictionary entry for the Latin word that follows:
<img width="1222" height="676" alt="image" src="https://github.com/user-attachments/assets/d8f31064-e15a-4ac5-ac9f-126d0d78ea0c" />

"nn" will give you the noun declension table for a given Latin word:
<img width="1226" height="392" alt="image" src="https://github.com/user-attachments/assets/83106a56-cb14-4493-8bb2-9b3aac11d31d" />

There is provision in the code for using the US order of noun cases (Nominative, Genitive....) which will be implemented later.

"vv" will give you the verb conjugation table for the form of the verb you supply:
<img width="1226" height="296" alt="image" src="https://github.com/user-attachments/assets/52aae8e3-5ab5-4f15-b952-5eb64c97de0a" />

<img width="1221" height="300" alt="image" src="https://github.com/user-attachments/assets/cb8883b1-b7d9-407c-9b67-573ae4e7b90f" />

<img width="1228" height="315" alt="image" src="https://github.com/user-attachments/assets/987da20b-3899-40c6-9e2e-eb511b4a5596" />


The functionality to add the appropriate macrons is currently at the prototype stage:
<img width="1225" height="204" alt="image" src="https://github.com/user-attachments/assets/b313dab3-fbe6-422a-b628-fd6a4de7e3cf" />


**NOTES**
- You can run Latinator.exe in GUI mode by creating a shortcut to the .exe and including a "GUI" parameter
- However, this currently needs some work and is waiting for the TLatin class to be stable :D
<img width="329" height="107" alt="image" src="https://github.com/user-attachments/assets/cf77413e-b60c-48b1-85f2-61e637ce416c" />
<img width="642" height="488" alt="image" src="https://github.com/user-attachments/assets/2ec13696-58c6-45ef-8c7f-86956547ac6d" />

**OPTIMIZATION**
- currently, no performance optimization is implemented: this will be done, if necessary, when the TLatin class is complete
- performance is excellent on my machine, however it's a ROG Strix G814JI with 32GB of RAM and an i9-13980HX processor so I accept that results elsewhere may vary 

