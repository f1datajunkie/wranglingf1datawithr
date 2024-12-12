# Appendix Two - FIA Timing Sheets

This appendix describes the timing sheets published by the FIA for each Grand Prix. The information is published as a series of PDF documents.

## Downloading the FIA timing sheets for a particular race

The approach I have taken to downloading the timing sheets and other race weekend press releases from the FIA website is a two pass process. In the first pass, a python screenscraper identifies all the links to PDF documents contained in grand prix event information page and pops them into a temporary file (*doclinks.txt*). *The URL of the event information page needs to be added to the python program file*: 

<<(code/fia-downloadlinks.py)

Run the program from the command line as follows:

    python fia-downloadlinks.py

From the command line, I then download all the documents whose link addresses are contained in that file:

    wget -i big_2014_doclinks.txt