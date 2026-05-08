# Latinator
 
Whitaker's Words on Steroids: reverse-engineered, re-architected, rewritten, expanded. 
Noun and Verb tables, Lewis & Short Dictionary lookup. Now with added macrons!
---

This is intended to be a Delphi/Latin Community project, so Pull Requests are not only welcome but invited and encouraged.

---
William A. Whitaker (1936–2010) was a Colonel in the United States Air Force (USAF). While working at the Defense Advanced Research Projects Agency (DARPA), he chaired the High Order Language Working Group. This group was responsible for the development of the computer language ADA. WW was an accomplished Latinist who created "Whitaker's Words," a [still] widely used Latin-to-English and English-to-Latin translation program. 

WW did a remarkable job of codifying, to a large extent, the entire Latin language, including its adaptation through the ages.
WW's "Words" is especially remarkable given the severe DOS hardware/memory constraints he was working under at the time.

---

## So why Latinator, then?

That's kind of you to ask, thank you.

Two main reasons:
1. The Code
- WW's ADA code has become something of a "black box". It is highly convoluted and whilst not entirely "impenetrable", it is certainly approaching it
- Although some attempts have been made to reorganise the code into more logical units, the code itself appears unchanged in those projects
- Websites that use WW's "Words" program appear to either be running cut-down Latin-to-English only versions, and without all the user options, or entirely "as is"
- It was amended and re-amended many many times over the ten years of its development and like all such software projects the code suffered for it
- WW had to engineer/architect some "less than ideal" shortcuts in order to fit everything into the 640KB (yes kilobytes!!) of memory and onto 1.5MB floppy disks for distribution
- Because of all the above, and more, although WW's work is preserved as an executable program, his codification of Latin is, for all practical purposes, as good as lost in its current form

2. Context
- One criticism frequently levelled at "Whitaker's Words" is that when translating Latin words into English, it doesn't take the context of the Latin words into consideration
- It uses Whitaker's one-to-one dictionary entry of a Latin word to an English summary line which contains one or more very brief [possible] meanings
- It is then left entirely to the user to decide which of the various meanings of a Latin word might be being used in the phrase they wanted to be translated

### Latinator
Consequently, to address the second criticism first, Latinator incorporates the full Lewis & Short Latin Dictionary in a format exclusive to Latinator.
In addition to the original brief English definition of a Latin word derived from the Whitaker's Words data, you get full access to the entire entry from Lewis & Short including examples (quotes) of where and how that word has been used by various Classical Latin authors.

I wanted to rewrite Whitaker's Words in Delphi so that his work could be further preserved, but also transferred and re-architected more appropriately for 21st Century hardware: CPUs, SDDs and memory.
In doing so, I also wanted to make his codification of Latin more accessible to a modern audience who are adept at either Latin or Delphi or both.
His codification can then be corrected/improved/expanded, as appropriate, depending on the expertise of those who want to get involved.
In its ADA form, with the data files he left, I don't see this ever happening.

We can also add additional Latin-English and English-Latin functionality that WW could never have added due the hardware constraints he was working under.
For example, given a Latin noun or any form of a Latin verb, Latinator will already generate the noun declension table or verb conjugation table (see screenshots below).

My aim is to, over time, make Latinator a really useful and well-known general-purpose tool for students of Latin, of which I am one (a student of Latin, I mean, not a useful and well-known tool :P)
Latinator, and its author, will always explicitly credit William Whitaker for the inspiration his remarkable work is to this project.

To that end then, I have made a number of subtle but significant changes:
- I have adapted his original data files so that they are fixed-column
- This allows them to be "sucked", unparsed, straight from SDD files into Windows memory in milliseconds, as indexed Delphi records
- 

The ADA code has been completely [see footnote] reverse-engineered and rewritten in Delphi

footnote: I still regularly check whether I got everything

---

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

"nn" will give you the noun declension table for a given Latin noun:
<img width="1226" height="392" alt="image" src="https://github.com/user-attachments/assets/83106a56-cb14-4493-8bb2-9b3aac11d31d" />

There is provision in the code for using the US order of noun cases (Nominative, Genitive....) which will be implemented later.

"vv" will give you the verb conjugation table for the form of the verb you supply:
<img width="1226" height="296" alt="image" src="https://github.com/user-attachments/assets/52aae8e3-5ab5-4f15-b952-5eb64c97de0a" />

<img width="1221" height="300" alt="image" src="https://github.com/user-attachments/assets/cb8883b1-b7d9-407c-9b67-573ae4e7b90f" />

<img width="1228" height="315" alt="image" src="https://github.com/user-attachments/assets/987da20b-3899-40c6-9e2e-eb511b4a5596" />


The functionality to add the appropriate macrons is currently at the prototype stage but the "proof of concept" has been successful:
<img width="1225" height="204" alt="image" src="https://github.com/user-attachments/assets/b313dab3-fbe6-422a-b628-fd6a4de7e3cf" />

---
**NOTES**
- You can run Latinator.exe in GUI mode by creating a shortcut to the .exe and including a "GUI" parameter
- However, this currently needs some work and is waiting for the TLatin class to be stable :D
<img width="329" height="107" alt="image" src="https://github.com/user-attachments/assets/cf77413e-b60c-48b1-85f2-61e637ce416c" />
<img width="642" height="488" alt="image" src="https://github.com/user-attachments/assets/2ec13696-58c6-45ef-8c7f-86956547ac6d" />

---

**OPTIMIZATION**
- currently, no explicit performance optimization is implemented over and above writing Delphi code which should be inherently high-performance: any further tweaking of the code or architecture to make it faster will be done, only if necessary, when the TLatin class is complete
- performance is excellent on my machine, however it's a ROG Strix G814JI with 32GB of RAM and an i9-13980HX processor so I accept that results elsewhere may vary 
- wwData.dat is automatically unpacked the first time that Latinator.exe is run and expands from 36MB to 820MB
