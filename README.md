# About Me

Hi. I am Ankur and I have interest in reverse engineering.

To do reverse engineering, I must understand how low level systems are engineered in the first place. That's why, I have taken a methodical approach to learn systems first.

I started on **May 01, 2025** with the basics of x64-assembly (intel syntax, `as` assembler). The highlight of this month was understanding how subtraction actually works so that I can understand why `0-1` in binary is 1. It is not that I can't do subtraction. I just don't know how it is done.

In June 2025, I searched a lot but found no pathway. Maybe I didn't searched enough. Anyways. Since then, I have stopped searching for pathways and started taking help from AI. I like and use ChatGPT only.

I decided to write tiny C binaries and analyze them using readelf and objdump. I started this from **June 21, 2025** and continued it until **December 16, 2025**. I started by analyzing **hello world**.
  - It took me 35 days to do that, starting from **June 21, 2025** to **July 24, 2025**. It and eye opening. Even though I only explored it on surface level, it was interesting and way complicated.
  - The journey was filled with complexity, agitation, frustration, irritation and fury. Systems are complex and I got a taste of it.
  - This is where I found there is something called ELF and build-execution model.

After that, I wrote an elf-parser to parse my hello world elf into a C-style dump. I got this idea around 5 or 6 July, and I found pax-utils/dumpelf but I still wanted to make it myself. The project can be found at [aggrawal-ankur/elfdump-v1](https://github.com/aggrawal-ankur/elf-dumpv1). It took me 10 days to build it.

These are all the things I've learned and did from August 04, 2025 to November 18, 2025. These are not strictly in order.

1. I dove further into x64 Assembly. The goal was to understand how basic C constructs translate to assembly. It was done in continuation of my pursuit of writing tiny C binaries to understand low level systems. I used `-O0` with `gcc` to understand the **intent** a C to Asm translation. I also polished the existing notes from May 2025. 
2. Conventions (syscall, function call, kernel, C, register usage, stack, red zone)
3. Why the main() should never be of type void. My introduction to ISO C Standards documents
4. Polished my notes of binary number system from May and corrected a few things.
5. How the illusion of data types is created and followed. Storage classes, linkages, how accessibility and lifetimes are enforced.
6. How the dynamic linker perform symbol resolution and relocations.
7. Virtual memory. User and kernel space distinction.
8. 4-level paging, on surface.
9. Page walk && Address resolution (on surface).
10. What enables debugging? What are the foundations gdb stands on? ptrace, breakpoints, faults, interrupts, single step, trap flag, signals and exceptions.
11. Dynamic memory allocation using dlmalloc.
12. Linux Processes and lifecycle (creation, process image swapping, execve, wait and exit) below the surface level details. Created a program to simulate another program as process. No threads for now.
13. ELF-spec (TISv1.1, TISv1.2, SysV ABI v4.1, gABI4.1+ and psABI amd64).
14. Read docs that made no sense; took help from ChatGPT to understand concepts and asked so many questions to find my way.
15. Dove deeper into compilation, used LLVM to see the abstract syntax tree and the LLVM IR under different optimization levels. Only surface, not in-depth though.

---

Now I was searching for the next thing and I got across the idea of an open system of learning, where constraints are natural, not forced. The more I dive, the deeper it gets.

Most of the programming content on YouTube is not what I like. What I do like is **Tsoding Daily**. On **December 18, 2025**, I saw a video of 2m 15s, where he explained how we can implement dynamic arrays in C. I loved that and worked on implementing it. I implemented dynamic arrays and strings in 6 days. They were nice.

I was thinking about the next step and chose to work on a "user space execution environment" project, which was aimed at revealing parts of the Linux kernel's program loading and execution mechanics to user space.
  - The project was great, but not the right fit for me. I am not great at working the way it demanded. I tried my best for 19 days, until I collapsed.
  - At this time, I was fighting a lot of circumstantial instability, which contributed to accumulated mental stress.
  - No peers, no one to talk with, contributed to the worst combination, where I soaked up everything until I couldn't.
  - I started exploding from new year alone. Wasted a lot of time here.

# Few Notes

Honestly, I did committed everything on GitHub, but my need to organize everything has often destroyed those artifacts.
  - [aggrawal-ankur/gitbook](https://github.com/aggrawal-ankur/gitbook/commits/main/?after=006d21929f2024d7b345cbc474fd3d9ea6d4410e+419). I committed to this repo starting from June 23, 25.
  - That's my knowledge-base repo, the latest one I commit to. [aggrawal-ankur/local-knowledge-base](https://github.com/aggrawal-ankur/local-knowledge-base).

Because I don't have any path, I end up wasting a lot of time, energy and attention in things that don't yield any results. I am forming and strengthening my intuition organically, and it is not easy.

No one likes slow progress, but I changed that for myself. Systems demand calmness to understand them, so I have to be slow. Whenever I hurried, I only wasted. Shiny objects, instant gratification, and shortcuts, I am not of those types.

All the progress I have made in understanding low level systems has been preserved in markdown notes. They used to be 600-700 lines long, while the average ones hang around 400-500 lines. That changed when I started seeing knowledge as an **interconnected web of nodes**. That really transformed my worldview of knowledge.
  - I started feeling this in September 2025 and tried to implement it a lot, which is one reason why I wasted a lot of my time around September-November.
  - I worked on my static website, which I eventually stopped because it was tiring to fake things I didn't belong to.
  - Then I switched to a local-only knowledge-base, committed at [aggrawal-ankur/local-knowledge-base](https://github.com/aggrawal-ankur/local-knowledge-base). That's when I started breaking down my existing notes into atomic files, trying to make the "nodes". Later I tried to build a system around it, but I failed. I've still not dropped that idea, I am just early. I am waiting to get a hang on the idea, before I go implement it this time.

My 35 days hello world pursuit helped me dissolve my fear of looking at vast x64-assembly. I am still far from extracting insights from plain assembly, which I'm working on.

I am fairly complicated. ***I am learning to learn by learning low level systems***. I am not just exploring systems, but myself too, which is why I often get stuck into mental issues which accumulate a lot of stress in me. That's another reason why it took me so long to reach here.

---

I started writing this on **January 10, 2026**, just after dealing with a lot of stress. But I was interrupted as my old schoolmates decided to meet and yeah. The pain in my body has been wild in a few days. Sleep was getting disturbed both in night and day. So, I was in a pretty disturbed state, both physically and mentally.

Finally, I decided to take a break for an unspecified period of time. No laptop. I started stretching again. I stretched in night and it improved my physical condition a lot, but that's just the start.

**January 11, 2026**, soaring pain in whole body, especially the back. Wasted time on YouTube and watched IND vs NZ. That's how I passed my day. Even no book reading because I knew I will find something that will tell me **I have figured it out and I will open the laptop again.**

**January 12, 2026**, which is today, I am going through physical body pain already, but something forced me to open the laptop and get things going.

Let's come to present now.

# RE YOUR OWN CREATION

An idea that has been floating in my mind since August 2025 is to write my own artifacts and reverse engineer them.

Earlier I thought to do that with my elf-parser project, but now I have built a better one. I am talking about my dynamic containers project.

A lot of things can be done, and it can really become a great portfolio project as well.
