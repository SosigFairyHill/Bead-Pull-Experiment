#-----------------------------------
# Name: Stepper Motor
#
# Author: matt.hawkins
#
# Created: 11/07/2012
# Copyright: (c) matt.hawkins 2012
#-----------------------------------
#!/usr/bin/env python
 
# Import required libraries
import time
import RPi.GPIO as GPIO

GPIO.setwarnings(False)
 
# Use Board pin references
# instead of BCM GPIO references
GPIO.setmode(GPIO.BOARD)
GPIO.cleanup() 
# Define GPIO signals to use
# Pins 15,22,16,11
# GPIO14,GPIO15,GPIO18,GPIO23
StepPins = [8,10,12,16]

# Define GPIO pins to use
# for interfacing with
# the Tektronics scope
# Use GPIO17
startScan = 11
 
# Set all output pins
for pin in StepPins:
  print "Setup pins"
  GPIO.setup(pin,GPIO.OUT)
  GPIO.output(pin, False)

GPIO.setup(startScan, GPIO.OUT)
GPIO.output(startScan, True)

# Define some settings
StepCounter = 0
WaitTime = 0.001
StepLimit = 103
NumMeasurements = 95

# Define simple sequence
StepCount1 = 4
Seq1 = []
Seq1 = range(0, StepCount1)
Seq1[0] = [1,0,0,0]
Seq1[1] = [0,1,0,0]
Seq1[2] = [0,0,1,0]
Seq1[3] = [0,0,0,1]
 
# Define advanced sequence
# as shown in manufacturers datasheet
StepCount2 = 8
Seq2 = []
Seq2 = range(0, StepCount2)
Seq2[0] = [1,0,0,0]
Seq2[1] = [1,1,0,0]
Seq2[2] = [0,1,0,0]
Seq2[3] = [0,1,1,0]
Seq2[4] = [0,0,1,0]
Seq2[5] = [0,0,1,1]
Seq2[6] = [0,0,0,1]
Seq2[7] = [1,0,0,1]

StepCount3 = 8
Seq3 = []
Seq3 = range(0, StepCount3)
Seq3[0] = [1,0,0,0]
Seq3[1] = [1,0,0,1]
Seq3[2] = [0,0,0,1]
Seq3[3] = [0,0,1,1]
Seq3[4] = [0,0,1,0]
Seq3[5] = [0,1,1,0]
Seq3[6] = [0,1,0,0]
Seq3[7] = [1,1,0,0]
 
# Choose a sequence to use
Seq = Seq3
StepCount = StepCount3

# Define the total number of steps
# TotalSteps = 0

# Pulse the scan pin to trigger scan
# on the falling edge
GPIO.output(startScan, True)
time.sleep(0.05)
GPIO.output(startScan, False)

start = time.time()

# Start loop for number of measurements
for i in range(1, NumMeasurements):

  TotalSteps = 0

  # Start stepping loop
  while TotalSteps < StepLimit:
    
    for pin in range(0, 4):
      xpin = StepPins[pin]
      if Seq[StepCounter][pin]!=0:
        print " Step %i Enable %i" %(StepCounter,xpin)
        GPIO.output(xpin, True)
      else:
        GPIO.output(xpin, False)
        
    StepCounter += 1
    TotalSteps += 1
        
    print TotalSteps
        
    # If we reach the end of the sequence
    # start again
    if (StepCounter==StepCount):
      StepCounter = 0
    if (StepCounter < 0):
      StepCounter = StepCount
            
    # Wait before moving on
    time.sleep(WaitTime)

  # Wait for the scan to finish before continuing
  # time.sleep(scanWait)
print time.time() - start
