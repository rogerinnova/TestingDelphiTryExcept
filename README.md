# Testing Delphi Try Except
 Testing the impact of Try Except End in Delphi Across Platforms.

## Background 
There have been a number of comments  on the Australian Delphi User Group Forum stating that  Exceptions are very expensive in terms of performance.

I had assumed that Try Except would have a similar cost to Try Finally except in the case when an exception occurs and the exception parameters need to be marshalled. 

The discussion also claimed that Win32, try-finally and try-except are expensive compared to Win64 where  try-except is a lot less expensive, as MS designed them better.

One member (Paul McGee) provided a GitHub (https://github.com/pmcgee69/Exceptions-Cost-in-Delphi) example program to measure the impact. This program however tests the “Cost” of raising the exception while what worried me was the impact on performance of including the “catch”.


I use try - excepts as a means of isolating and understanding problems in systems often placing a break point in the on except code. It has been my practice to leave these catches in the code for future reference.
This Example takes Paul’s approach and packages it in Firemonkey so that it can be run on other platforms. I then included a comparison between code with an insane amount of try-excepts with the same code unhindered but in a test where no  exceptions are raised

## Conclusion
My minimal testing yields 
Performance penalty of inserting Try Except Blocks (at an insane rate)  Android 25%  Windows 32  70% Windows 64 50% which is not a significant given the potential diagnostic return.

 
