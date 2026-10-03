**assessment2**



**Assessment 2: Fuzzing WavPack with AFLsmart**



**Overview**



This repository contains the fuzzing setup, seed corpus, dictionary, Peach Pit,

crash evidence and reproduction script for Assessment 2. The target is WavPack

5.1.0, fuzzed via an ASAN-instrumented build (`wavpack\_asan`) inside the

Docker environment provided for this assessment (`isys90125a2`).



Two campaigns were run in parallel:



\- \Encoder campaign:\*\* AFLsmart against `wavpack` (the encoder CLI), using

&#x20; the WAV Peach Pit and dictionary in this repo.



\- Decoder campaign:\*\* AFL-style fuzzing against `wvunpack` (the decoder

&#x20; CLI), using `.wv` seeds generated from the same source WAV files. This

&#x20; targets the realistic "malicious `.wv` file" attack scenario. Not included

&#x20; in this repo's required structure, but referenced in the report.



**Directory structure**



fuzzing/



seeds/ — 11 seed WAV files, truncated to first 2,000 PCM frames

(see "Seed selection" below for why)



dictionary/ — wav.dict, the stock AFLsmart WAV dictionary



peach\_pit/ — wav.xml, the Peach Pit WAV format model



crashes/ — crash\_0.wav, the PoC for the one confirmed vulnerability



run\_fuzzing.sh — reproduces the exact encoder fuzzing command



evidence/



afl\_status\_\*.png — AFL status screenshots at various points in the run



crash\_0\_asan.txt — ASAN stack trace for the crash



evidence\_crash\_0\_asan\_screenshot.png — screenshot of the same trace



evidence\_coverage\_summary.png — lcov coverage summary



**Reproducing the campaign**



1\. Build and run the provided Docker image (see the assessment's own

&#x20;  `docker/` README for `docker build`/`docker run` instructions).



2\. Inside the container, copy this repo's `fuzzing/` contents into

&#x20;  `/home/fuzzer/` (or adjust paths in `run\_fuzzing.sh` to point at this

&#x20;  repo's location).



3\. Run:



```bash

chmod +x fuzzing/run\_fuzzing.sh

./fuzzing/run\_fuzzing.sh fuzzing/seeds /home/fuzzer/out

This runs AFLsmart for up to 24 hours (timeout 24h), writing output to

the given directory. Stop early with Ctrl-C at any time. AFL saves its

queue and crashes incrementally, so partial runs are still valid.

4\. To reproduce the crash directly without re-running the campaign:

./WavPack/cli/wavpack\_asan -y fuzzing/crashes/crash\_0.wav -o /tmp/x



Seed selection

The original seed corpus (11 WAV files, \~600–890 KB each) produced extremely

slow fuzzing (\~0.1 execs/sec). Each seed was truncated to its first 2,000 PCM

frames (keeping valid RIFF/WAVE headers), reducing files to \~4–8 KB and

raising throughput to 200–470 execs/sec. This is the corpus included here.

Known limitation: Peach structure-aware mutation

AFLsmart invokes Peach with -inputFilePath=/-outputFilePath= options

(per afl-fuzz.c), but the Peach binary installed in the provided Docker

image does not recognise these options, despite the AFLsmart patch

(peach-3.0.202.patch) defining them. As a result, out/chunks/, where

Peach would normally write structurally-repaired inputs, remained empty

throughout the campaign. This is documented in detail in the report's Setup

section. Practical effect: the campaign ran as coverage-guided AFL with a

format-aware dictionary, rather than fully structure-aware Peach fuzzing.

Findings summary

One confirmed, reproducible vulnerability: an unchecked, signed-integer

allocation size in ParseRiffHeaderConfig (riff.c:289) when handling

unrecognised RIFF chunks. Full analysis, stack trace, and CVSS v3.1 scoring

are in the written report.



**AI use declaration**

\[I acknowledge the use of Claude (Anthropic) during the preparation of this assessment.
I used Claude to assist with setting up the assignment and planning out what tasks were needed to be done.
I also used it to figure out why certain commands were not working and why
the AFLsmart tool was not executing as fast as it should have been.
This was also used in aid for my report writing,
as I had lots of screenshots and commands to put into the report,
so the AI assisted me in keeping my evidence in order, to make it
easier for me to insert it into my report. A record of prompts and outputs is available upon request.]

Research References
https://github.com/aflsmart/aflsmart (AFLsmart, n.d.)
https://github.com/AFLplusplus/AFLplusplus  (AFLplusplus, n.d.)
https://peachtech.gitlab.io/peach-fuzzer-community/v3/PeachQuickStart.html(Peach Tech, 2021) 
https://www.wavpack.com/WavPack5FileFormat.pdf  (Bryant, 2020)
https://www.first.org/cvss/calculator/3.1 (Forum of Incident Response and Security Teams, n.d.)
https://clang.llvm.org/docs/AddressSanitizer.html (The Clang Team, n.d.)





